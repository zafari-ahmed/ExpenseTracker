import 'package:isar/isar.dart';

part 'card_model.g.dart';

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
}
