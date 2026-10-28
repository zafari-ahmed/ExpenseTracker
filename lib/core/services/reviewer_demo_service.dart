import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/cards/domain/sms_parser.dart';
import '../../features/cards/presentation/providers/cards_provider.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import 'data_refresh.dart';
import 'service_providers.dart';
import 'sms_listener_service.dart';
import 'sms_process_result.dart';

/// Sample debit wording for Play reviewers / empty-state demo.
/// Not tied to a real bank sender — only used as parse input.
abstract final class ReviewerDemoSms {
  static const body =
      'Alert: Txn: charged at FOODPANDA for PKR-1,250.00 on card ending 1234 on 07/Oct/2026.';
}

enum ReviewerDemoImportResult {
  created,
  alreadyExists,
  failed,
}

class ReviewerDemoService {
  ReviewerDemoService(this._ref);

  final WidgetRef _ref;
  static const _uuid = Uuid();

  /// If the user has no cards, creates a generic sample card
  /// (BANK NAME / CARD NAME / 1234). If they already have a card, adds the
  /// sample expense onto that card without changing their SMS format.
  Future<ReviewerDemoImportResult> importSampleDebitSms() async {
    final cardsRepo = await _ref.read(cardsRepositoryProvider.future);
    final txRepo = await _ref.read(transactionsRepositoryProvider.future);

    final active = await cardsRepo.getCards(activeOnly: true);
    final CardModel card;
    if (active.isEmpty) {
      card = await _createGenericSampleCard(cardsRepo);
    } else {
      card = active.first;
    }

    // One-off rule for this sample only — never overwrites the card's saved
    // SMS format when the user already configured a real bank sample.
    final demoRule = _demoRuleFor(card.id);

    if (await txRepo.existsByRawSmsBody(ReviewerDemoSms.body)) {
      return ReviewerDemoImportResult.alreadyExists;
    }

    final pipeline = await _ref.read(smsPipelineServiceProvider.future);
    final result = await pipeline.processSms(
      card: card,
      rule: demoRule,
      senderId: card.smsSenderId.trim().isEmpty ? '1234' : card.smsSenderId,
      body: ReviewerDemoSms.body,
      receivedAt: DateTime.now(),
    );

    invalidateLocalDataProviders(_ref);
    _ref.invalidate(transactionsListProvider);
    _ref.invalidate(cardsListProvider);
    _ref.invalidate(activeCardsProvider);
    _ref.read(smsSyncTickProvider.notifier).state++;

    if (result.kind == SmsProcessKind.expenseAdded) {
      return ReviewerDemoImportResult.created;
    }
    if (await txRepo.existsByRawSmsBody(ReviewerDemoSms.body) ||
        await txRepo.existsSimilarSmsTransaction(
          cardId: card.id,
          amount: 1250,
          place: 'FOODPANDA',
          transactionDate: DateTime(2026, 10, 7),
        )) {
      return ReviewerDemoImportResult.alreadyExists;
    }
    return ReviewerDemoImportResult.failed;
  }

  Future<CardModel> _createGenericSampleCard(CardsRepository cardsRepo) async {
    final card = CardModel()
      ..id = _uuid.v4()
      ..bankName = 'BANK NAME'
      ..cardName = 'CARD NAME'
      ..cardIcon = 'theme:0|account_balance'
      ..lastFourDigits = '1234'
      ..smsSenderId = '1234'
      ..billDate = 1
      ..isActive = true
      ..parseSource = CardParseSource.sms
      ..notificationPackage = ''
      ..createdAt = DateTime.now();
    await cardsRepo.upsertCard(card);

    final rule = _demoRuleFor(card.id);
    rule.id = _uuid.v4();
    await cardsRepo.upsertParsingRule(rule);
    return card;
  }

  SmsParsingRuleModel _demoRuleFor(String cardId) {
    final suggestion = SmsParser.suggestFromSample(ReviewerDemoSms.body);
    return SmsParsingRuleModel()
      ..id = ''
      ..cardId = cardId
      ..sampleMessage = ReviewerDemoSms.body
      ..amountPattern = suggestion.amountPattern
      ..placePattern = suggestion.placePattern
      ..datePattern = suggestion.datePattern
      ..excludeKeywords = List<String>.from(SmsParser.defaultIgnorePhrases);
  }
}
