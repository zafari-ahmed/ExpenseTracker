import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/card_model.dart';
import '../../data/models/sms_parsing_rule_model.dart';
import '../../data/repositories/cards_repository.dart';
import '../../domain/sms_parser.dart';

final cardsListProvider = FutureProvider<List<CardModel>>((ref) async {
  final repo = await ref.watch(cardsRepositoryProvider.future);
  return repo.getCards();
});

final activeCardsProvider = FutureProvider<List<CardModel>>((ref) async {
  final repo = await ref.watch(cardsRepositoryProvider.future);
  return repo.getCards(activeOnly: true);
});

final parsingRuleByCardProvider =
    FutureProvider.family<SmsParsingRuleModel?, String>((ref, cardId) async {
  final repo = await ref.watch(cardsRepositoryProvider.future);
  return repo.getRuleForCard(cardId);
});

final cardMutationsProvider = Provider<CardMutations>((ref) {
  return CardMutations(ref);
});

class CardMutations {
  CardMutations(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> saveCard(CardModel card) async {
    final repo = await _ref.read(cardsRepositoryProvider.future);
    if (card.id.isEmpty) {
      card.id = _uuid.v4();
      card.createdAt = DateTime.now();
    }
    await repo.upsertCard(card);

    // Ensure every card has a usable SMS rule so auto-detect works even if
    // the user skips the sample-SMS configuration screen.
    final existing = await repo.getRuleForCard(card.id);
    if (existing == null) {
      final suggestion = SmsParser.suggestFromSample(
        'Txn: charged at MERCHANT for PKR-1,000.00 on card ending '
        '${card.lastFourDigits ?? '0000'} on 01/Jan/2026.',
      );
      final rule = SmsParsingRuleModel()
        ..id = _uuid.v4()
        ..cardId = card.id
        ..sampleMessage = ''
        ..amountPattern = suggestion.amountPattern
        ..placePattern = suggestion.placePattern
        ..datePattern = suggestion.datePattern
        ..excludeKeywords = List<String>.from(SmsParser.defaultIgnorePhrases);
      await repo.upsertParsingRule(rule);
      _ref.invalidate(parsingRuleByCardProvider(card.id));
    }

    _ref.invalidate(cardsListProvider);
    _ref.invalidate(activeCardsProvider);
  }

  Future<void> deleteCard(String cardId) async {
    final repo = await _ref.read(cardsRepositoryProvider.future);
    await repo.deleteCard(cardId);
    _ref.invalidate(cardsListProvider);
    _ref.invalidate(activeCardsProvider);
  }

  Future<void> saveRule(SmsParsingRuleModel rule) async {
    final repo = await _ref.read(cardsRepositoryProvider.future);
    if (rule.id.isEmpty) {
      rule.id = _uuid.v4();
    }
    await repo.upsertParsingRule(rule);
    _ref.invalidate(parsingRuleByCardProvider(rule.cardId));
  }
}
