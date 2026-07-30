import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../../core/database/isar_instance.dart';
import '../models/card_model.dart';
import '../models/sms_parsing_rule_model.dart';

class CardsRepository {
  CardsRepository(this._isar);

  final Isar _isar;

  Future<List<CardModel>> getCards({bool activeOnly = false}) async {
    if (activeOnly) {
      return _isar.cardModels.filter().isActiveEqualTo(true).findAll();
    }
    return _isar.cardModels.where().findAll();
  }

  Future<CardModel?> getCardById(String cardId) {
    return _isar.cardModels.filter().idEqualTo(cardId).findFirst();
  }

  Future<void> upsertCard(CardModel card) async {
    await _isar.writeTxn(() async {
      await _isar.cardModels.put(card);
    });
  }

  Future<void> setCardActive(String cardId, bool isActive) async {
    final card = await getCardById(cardId);
    if (card == null) {
      return;
    }

    card.isActive = isActive;
    await upsertCard(card);
  }

  Future<void> deleteCard(String cardId) async {
    final card = await getCardById(cardId);
    if (card == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.smsParsingRuleModels.filter().cardIdEqualTo(cardId).deleteAll();
      await _isar.cardModels.delete(card.isarId);
    });
  }

  Future<SmsParsingRuleModel?> getRuleForCard(String cardId) {
    return _isar.smsParsingRuleModels.filter().cardIdEqualTo(cardId).findFirst();
  }

  Future<void> upsertParsingRule(SmsParsingRuleModel rule) async {
    await _isar.writeTxn(() async {
      await _isar.smsParsingRuleModels.put(rule);
    });
  }
}

final cardsRepositoryProvider = FutureProvider<CardsRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return CardsRepository(isar);
});
