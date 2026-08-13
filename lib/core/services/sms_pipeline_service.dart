import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/cards/domain/sms_parser.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import 'app_preferences_service.dart';
import 'sms_process_result.dart';

class SmsPipelineService {
  SmsPipelineService({
    required CardsRepository cardsRepository,
    required TransactionsRepository transactionsRepository,
    required CategoriesRepository categoriesRepository,
    required AppPreferencesService preferencesService,
  })  : _cardsRepository = cardsRepository,
        _transactionsRepository = transactionsRepository,
        _categoriesRepository = categoriesRepository,
        _preferencesService = preferencesService;

  final CardsRepository _cardsRepository;
  final TransactionsRepository _transactionsRepository;
  final CategoriesRepository _categoriesRepository;
  final AppPreferencesService _preferencesService;
  static const _uuid = Uuid();

  bool get supportsSmsReading => Platform.isAndroid;

  Future<List<String>> _customIgnoreList() {
    return _preferencesService.customSmsIgnoreList();
  }

  Future<List<String>> _activeDefaultIgnoreList() async {
    final disabled = await _preferencesService.disabledDefaultSmsIgnoreList();
    return SmsParser.effectiveDefaultIgnorePhrases(disabledPhrases: disabled);
  }

  /// Process one incoming / inbox SMS.
  Future<SmsProcessResult> processIncomingSms({
    required String senderId,
    required String body,
    DateTime? receivedAt,
  }) async {
    if (!supportsSmsReading) return const SmsProcessResult.none();
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return const SmsProcessResult.none();

    final customIgnore = await _customIgnoreList();
    final activeDefaults = await _activeDefaultIgnoreList();

    if (SmsParser.shouldIgnoreSms(
      trimmedBody,
      extraIgnorePhrases: customIgnore,
      enabledDefaultIgnorePhrases: activeDefaults,
    )) {
      return const SmsProcessResult.none();
    }

    if (await _transactionsRepository.existsByRawSmsBody(trimmedBody)) {
      return const SmsProcessResult.none();
    }

    final cards = await _cardsRepository.getCards(activeOnly: true);
    if (cards.isEmpty) return const SmsProcessResult.none();

    CardModel? card = _matchCard(cards, senderId: senderId, body: trimmedBody);
    card ??= await _matchCardByRule(cards, trimmedBody, receivedAt);
    if (card == null) return const SmsProcessResult.none();

    final rule = await _ruleForCard(card, sampleBody: trimmedBody);
    return processSms(
      card: card,
      rule: rule,
      senderId: senderId,
      body: trimmedBody,
      receivedAt: receivedAt,
      customIgnorePhrases: customIgnore,
      activeDefaultIgnorePhrases: activeDefaults,
    );
  }

  Future<SmsProcessResult> processSms({
    required CardModel card,
    required SmsParsingRuleModel rule,
    required String senderId,
    required String body,
    DateTime? receivedAt,
    List<String>? customIgnorePhrases,
    List<String>? activeDefaultIgnorePhrases,
  }) async {
    final customIgnore = customIgnorePhrases ?? await _customIgnoreList();
    final activeDefaults =
        activeDefaultIgnorePhrases ?? await _activeDefaultIgnoreList();

    if (SmsParser.shouldIgnoreSms(
      body,
      extraIgnorePhrases: customIgnore,
      enabledDefaultIgnorePhrases: activeDefaults,
    )) {
      return const SmsProcessResult.none();
    }

    final lowerBody = body.toLowerCase();
    final excludes = <String>{
      ...activeDefaults,
      ...customIgnore,
      ...rule.excludeKeywords,
    };
    if (excludes.any(
      (e) => e.trim().isNotEmpty && lowerBody.contains(e.toLowerCase()),
    )) {
      return const SmsProcessResult.none();
    }

    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: rule.amountPattern,
      placePattern: rule.placePattern,
      datePattern: rule.datePattern,
      fallbackDate: receivedAt ?? DateTime.now(),
    );

    if (parsed == null) {
      await _transactionsRepository.addNeedsReview(
        cardId: card.id,
        senderId: senderId,
        rawSmsBody: body,
        parseError: 'Could not extract amount/place/date',
        receivedAt: receivedAt,
      );
      return const SmsProcessResult.needsReview();
    }

    if (await _transactionsRepository.existsSimilarSmsTransaction(
      cardId: card.id,
      amount: parsed.amount,
      place: parsed.place,
      transactionDate: parsed.transactionDate,
    )) {
      return const SmsProcessResult.none();
    }

    final category =
        await _categoriesRepository.autoCategoryFromPlace(parsed.place);

    final tx = TransactionModel()
      ..id = _uuid.v4()
      ..cardId = card.id
      ..amount = parsed.amount
      ..place = parsed.place
      ..description = ''
      ..category = category?.name ?? 'Uncategorized'
      ..rawSmsBody = body
      ..transactionDate = parsed.transactionDate
      ..createdAt = DateTime.now()
      ..source = TransactionSource.sms;
    await _transactionsRepository.upsertTransaction(tx);

    return SmsProcessResult.expenseAdded(
      transaction: tx,
      cardName: card.cardName,
    );
  }

  CardModel? _matchCard(
    List<CardModel> cards, {
    required String senderId,
    required String body,
  }) {
    final addr = _normalizeSender(senderId);
    final bodyLower = body.toLowerCase();

    final senderMatches = cards.where((card) {
      final configured = _normalizeSender(card.smsSenderId);
      if (configured.isEmpty || addr.isEmpty) return false;
      return addr == configured ||
          addr.contains(configured) ||
          configured.contains(addr);
    }).toList();

    if (senderMatches.isEmpty) {
      final byDigits = cards.where((card) {
        final digits = card.lastFourDigits?.trim();
        if (digits == null || digits.length < 4) return false;
        return bodyLower.contains(digits.toLowerCase());
      }).toList();
      if (byDigits.length == 1) return byDigits.first;
      return null;
    }

    if (senderMatches.length == 1) return senderMatches.first;

    for (final card in senderMatches) {
      final digits = card.lastFourDigits?.trim();
      if (digits != null &&
          digits.length >= 4 &&
          bodyLower.contains(digits.toLowerCase())) {
        return card;
      }
    }
    return senderMatches.first;
  }

  Future<CardModel?> _matchCardByRule(
    List<CardModel> cards,
    String body,
    DateTime? receivedAt,
  ) async {
    CardModel? matched;
    var matchCount = 0;
    final fallbackDate = receivedAt ?? DateTime.now();

    for (final card in cards) {
      final rule = await _cardsRepository.getRuleForCard(card.id);
      if (rule == null) continue;

      final parsed = SmsParser.parse(
        smsBody: body,
        amountPattern: rule.amountPattern,
        placePattern: rule.placePattern,
        datePattern: rule.datePattern,
        fallbackDate: fallbackDate,
      );
      if (parsed == null) continue;

      matchCount++;
      matched = card;
      if (matchCount > 1) {
        return null;
      }
    }

    return matchCount == 1 ? matched : null;
  }

  Future<SmsParsingRuleModel> _ruleForCard(
    CardModel card, {
    required String sampleBody,
  }) async {
    final existing = await _cardsRepository.getRuleForCard(card.id);
    if (existing != null) return existing;

    final suggestion = SmsParser.suggestFromSample(sampleBody);
    final rule = SmsParsingRuleModel()
      ..id = _uuid.v4()
      ..cardId = card.id
      ..sampleMessage = sampleBody
      ..amountPattern = suggestion.amountPattern
      ..placePattern = suggestion.placePattern
      ..datePattern = suggestion.datePattern
      ..excludeKeywords = List<String>.from(SmsParser.defaultIgnorePhrases);
    await _cardsRepository.upsertParsingRule(rule);
    return rule;
  }

  static String _normalizeSender(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
