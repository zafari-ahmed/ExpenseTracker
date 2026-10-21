import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/cards/domain/sms_parser.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import 'data_refresh.dart';
import 'service_providers.dart';
import 'sms_listener_service.dart';

/// Sample debit SMS used so Play reviewers can verify SMS-to-expense
/// tracking on a device that has no Pakistani bank messages.
abstract final class ReviewerDemoSms {
  static const senderId = 'HBL-BANK';
  static const lastFour = '4521';
  static const body =
      'HBL Alert: Txn: charged at FOODPANDA for PKR-1,250.00 on card ending 4521 on 07/Oct/2026.';
}

class ReviewerDemoService {
  ReviewerDemoService(this._ref);

  final WidgetRef _ref;
  static const _uuid = Uuid();

  /// Creates a demo card (if needed) and runs the real SMS pipeline on a
  /// sample bank debit message so a transaction appears in the dashboard.
  Future<bool> importSampleDebitSms() async {
    final cardsRepo = await _ref.read(cardsRepositoryProvider.future);
    var cards = await cardsRepo.getCards(activeOnly: true);
    CardModel card;
    if (cards.isEmpty) {
      card = CardModel()
        ..id = _uuid.v4()
        ..bankName = 'HBL'
        ..cardName = 'Demo debit card'
        ..cardIcon = 'theme:0|account_balance'
        ..lastFourDigits = ReviewerDemoSms.lastFour
        ..smsSenderId = ReviewerDemoSms.senderId
        ..billDate = 1
        ..isActive = true
        ..createdAt = DateTime.now();
      await cardsRepo.upsertCard(card);

      final suggestion =
          SmsParser.suggestFromSample(ReviewerDemoSms.body);
      final rule = SmsParsingRuleModel()
        ..id = _uuid.v4()
        ..cardId = card.id
        ..sampleMessage = ReviewerDemoSms.body
        ..amountPattern = suggestion.amountPattern
        ..placePattern = suggestion.placePattern
        ..datePattern = suggestion.datePattern
        ..excludeKeywords = List<String>.from(SmsParser.defaultIgnorePhrases);
      await cardsRepo.upsertParsingRule(rule);
    } else {
      card = cards.first;
    }

    var rule = await cardsRepo.getRuleForCard(card.id);
    if (rule == null) {
      final suggestion = SmsParser.suggestFromSample(ReviewerDemoSms.body);
      rule = SmsParsingRuleModel()
        ..id = _uuid.v4()
        ..cardId = card.id
        ..sampleMessage = ReviewerDemoSms.body
        ..amountPattern = suggestion.amountPattern
        ..placePattern = suggestion.placePattern
        ..datePattern = suggestion.datePattern
        ..excludeKeywords = List<String>.from(SmsParser.defaultIgnorePhrases);
      await cardsRepo.upsertParsingRule(rule);
    }

    final pipeline = await _ref.read(smsPipelineServiceProvider.future);
    final result = await pipeline.processSms(
      card: card,
      rule: rule,
      senderId: card.smsSenderId.isEmpty
          ? ReviewerDemoSms.senderId
          : card.smsSenderId,
      body: ReviewerDemoSms.body,
      receivedAt: DateTime.now(),
    );

    invalidateLocalDataProviders(_ref);
    _ref.invalidate(transactionsListProvider);
    _ref.read(smsSyncTickProvider.notifier).state++;
    return result.created;
  }
}
