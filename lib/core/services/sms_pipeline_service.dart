import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/cards/domain/sms_parser.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';

class SmsPipelineService {
  SmsPipelineService({
    required CardsRepository cardsRepository,
    required TransactionsRepository transactionsRepository,
    required CategoriesRepository categoriesRepository,
  })  : _cardsRepository = cardsRepository,
        _transactionsRepository = transactionsRepository,
        _categoriesRepository = categoriesRepository;

  final CardsRepository _cardsRepository;
  final TransactionsRepository _transactionsRepository;
  final CategoriesRepository _categoriesRepository;
  static const _uuid = Uuid();

  bool get supportsSmsReading => Platform.isAndroid;

  /// Process one incoming / inbox SMS. Returns true if a transaction or review
  /// item was created.
  Future<bool> processIncomingSms({
    required String senderId,
    required String body,
    DateTime? receivedAt,
  }) async {
    if (!supportsSmsReading) return false;
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return false;

    // Skip exact duplicates already stored as transactions.
    if (await _transactionsRepository.existsByRawSmsBody(trimmedBody)) {
      return false;
    }

    final cards = await _cardsRepository.getCards(activeOnly: true);
    if (cards.isEmpty) return false;

    final card = _matchCard(cards, senderId: senderId, body: trimmedBody);
    if (card == null) return false;

    final rule = await _ruleForCard(card, sampleBody: trimmedBody);
    await processSms(
      card: card,
      rule: rule,
      senderId: senderId,
      body: trimmedBody,
      receivedAt: receivedAt,
    );
    return true;
  }

  Future<void> processSms({
    required CardModel card,
    required SmsParsingRuleModel rule,
    required String senderId,
    required String body,
    DateTime? receivedAt,
  }) async {
    final lowerBody = body.toLowerCase();
    if (rule.excludeKeywords.any((e) => lowerBody.contains(e.toLowerCase()))) {
      return;
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
      return;
    }

    // Extra dedupe: same card + amount + place + day.
    if (await _transactionsRepository.existsSimilarSmsTransaction(
      cardId: card.id,
      amount: parsed.amount,
      place: parsed.place,
      transactionDate: parsed.transactionDate,
    )) {
      return;
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
      // Fallback: last-4 digits mentioned in SMS body.
      final byDigits = cards.where((card) {
        final digits = card.lastFourDigits?.trim();
        if (digits == null || digits.length < 4) return false;
        return bodyLower.contains(digits.toLowerCase());
      }).toList();
      if (byDigits.length == 1) return byDigits.first;
      return null;
    }

    if (senderMatches.length == 1) return senderMatches.first;

    // Same bank sender for multiple cards → disambiguate by last 4.
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
      ..excludeKeywords = <String>['otp', 'one time', 'verification'];
    await _cardsRepository.upsertParsingRule(rule);
    return rule;
  }

  static String _normalizeSender(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
