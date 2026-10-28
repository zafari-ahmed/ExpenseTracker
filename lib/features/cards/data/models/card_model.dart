import 'package:isar_community/isar.dart';

part 'card_model.g.dart';

enum CardParseSource {
  sms,
  notification,
}

@collection
class CardModel {
  CardModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = '';

  late String bankName;
  late String cardName;
  late String cardIcon;
  String? lastFourDigits;
  late String smsSenderId;
  late int billDate;
  bool isActive = true;
  late DateTime createdAt;

  /// How bank spends are detected for this card. Existing cards default to SMS.
  @enumerated
  CardParseSource parseSource = CardParseSource.sms;

  /// Android package when [parseSource] is notification; empty for SMS.
  String notificationPackage = '';

  /// Display label for the selected app (optional).
  String? notificationAppLabel;
}
