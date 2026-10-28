import 'package:isar_community/isar.dart';

part 'transaction_model.g.dart';

enum TransactionSource {
  sms,
  manual,
  smsEdited,
  notification,
  notificationEdited;

  bool get fromSms => this == sms || this == smsEdited;

  bool get fromNotification =>
      this == notification || this == notificationEdited;

  bool get fromAuto => fromSms || fromNotification;
}

@collection
class TransactionModel {
  TransactionModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String cardId;

  late double amount;
  late String place;
  late String description;
  @Index()
  late String category;
  late String rawSmsBody;
  @Index()
  late DateTime transactionDate;
  late DateTime createdAt;
  @enumerated
  late TransactionSource source;
}
