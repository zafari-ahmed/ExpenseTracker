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

    final smsCards = cards
        .where((c) => c.parseSource == CardParseSource.sms)
        .toList(growable: false);
    if (smsCards.isEmpty) return const SmsProcessResult.none();

    final card = _matchCard(smsCards, senderId: senderId);
    if (card == null) return const SmsProcessResult.none();

    final rule = await _cardsRepository.getRuleForCard(card.id);
    if (rule == null || rule.sampleMessage.trim().isEmpty) {
      return const SmsProcessResult.none();
    }

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

  /// Process a bank-app notification for cards with parseSource=notification.
  Future<SmsProcessResult> processIncomingNotification({
    required String packageName,
    required String text,
    DateTime? postedAt,
  }) async {
    if (!Platform.isAndroid) return const SmsProcessResult.none();

    final pkg = packageName.trim();
    final trimmedBody = text.trim();
    if (pkg.isEmpty || trimmedBody.isEmpty) {
      return const SmsProcessResult.none();
    }
    if (pkg == 'com.theexpensetracker.app') {
      return const SmsProcessResult.none();
    }

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
    final notifCards = cards
        .where(
          (c) =>
              c.parseSource == CardParseSource.notification &&
              c.notificationPackage.trim() == pkg,
        )
        .toList(growable: false);
    if (notifCards.isEmpty) return const SmsProcessResult.none();

    final card = _matchNotificationCard(notifCards, body: trimmedBody);
    if (card == null) return const SmsProcessResult.none();

    final lowerBody = trimmedBody.toLowerCase();
    if (!SmsParser.hasStrongExpenseSignal(lowerBody) &&
        !SmsParser.hasExpenseSignal(lowerBody)) {
      return const SmsProcessResult.none();
    }

    final rule = await _cardsRepository.getRuleForCard(card.id);
    final amountPattern =
        rule?.amountPattern.trim().isNotEmpty == true
            ? rule!.amountPattern
            : SmsParser.defaultAmountPatterns.first;
    final placePattern =
        rule?.placePattern.trim().isNotEmpty == true
            ? rule!.placePattern
            : SmsParser.defaultPlacePatterns.first;
    final datePattern = rule?.datePattern;

    if (rule != null) {
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
    }

    final parsed = SmsParser.parse(
      smsBody: trimmedBody,
      amountPattern: amountPattern,
      placePattern: placePattern,
      datePattern: datePattern,
      fallbackDate: postedAt ?? DateTime.now(),
      strict: false,
    );

    if (parsed == null) {
      if (!SmsParser.hasStrongExpenseSignal(lowerBody)) {
        return const SmsProcessResult.none();
      }
      await _transactionsRepository.addNeedsReview(
        cardId: card.id,
        senderId: pkg,
        rawSmsBody: trimmedBody,
        parseError: 'Could not extract amount/place/date from notification',
        receivedAt: postedAt,
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
      ..rawSmsBody = trimmedBody
      ..transactionDate = parsed.transactionDate
      ..createdAt = DateTime.now()
      ..source = TransactionSource.notification;
    await _transactionsRepository.upsertTransaction(tx);

    return SmsProcessResult.expenseAdded(
      transaction: tx,
      cardName: card.cardName,
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

    final sample = rule.sampleMessage.trim();
    if (sample.isEmpty) {
      return const SmsProcessResult.none();
    }
    if (!SmsParser.matchesConfiguredSample(body, sample)) {
      return const SmsProcessResult.none();
    }
    if (!SmsParser.hasStrongExpenseSignal(lowerBody) &&
        !SmsParser.hasExpenseSignal(lowerBody)) {
      return const SmsProcessResult.none();
    }

    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: rule.amountPattern,
      placePattern: rule.placePattern,
      datePattern: rule.datePattern,
      fallbackDate: receivedAt ?? DateTime.now(),
      strict: true,
    );

    if (parsed == null) {
      if (!SmsParser.hasStrongExpenseSignal(lowerBody)) {
        return const SmsProcessResult.none();
      }
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
  }) {
    final senderMatches = cards.where((card) {
      return SmsParser.senderMatches(senderId, card.smsSenderId);
    }).toList();

    if (senderMatches.isEmpty) return null;
    if (senderMatches.length == 1) return senderMatches.first;
    return senderMatches.first;
  }

  /// Prefer the card whose last-4 appears in the notification text.
  CardModel? _matchNotificationCard(
    List<CardModel> cards, {
    required String body,
  }) {
    if (cards.isEmpty) return null;
    if (cards.length == 1) return cards.first;

    final lower = body.toLowerCase();
    CardModel? withDigits;
    for (final card in cards) {
      final digits = card.lastFourDigits?.trim();
      if (digits == null || digits.length < 4) continue;
      if (lower.contains(digits.toLowerCase()) ||
          lower.contains('ending $digits') ||
          lower.contains('ending with $digits') ||
          lower.contains('xx$digits') ||
          lower.contains('*$digits')) {
        withDigits = card;
        break;
      }
    }
    return withDigits ?? cards.first;
  }
}
