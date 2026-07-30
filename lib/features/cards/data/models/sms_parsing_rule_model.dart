import 'package:isar_community/isar.dart';

part 'sms_parsing_rule_model.g.dart';

@collection
class SmsParsingRuleModel {
  SmsParsingRuleModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = '';

  @Index()
  late String cardId;

  late String sampleMessage;
  late String amountPattern;
  late String placePattern;
  String? datePattern;
  List<String> excludeKeywords = <String>[];
}
