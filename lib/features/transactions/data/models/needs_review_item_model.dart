import 'package:isar/isar.dart';

part 'needs_review_item_model.g.dart';

@collection
class NeedsReviewItemModel {
  NeedsReviewItemModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String cardId;

  late String senderId;
  late String rawSmsBody;
  late DateTime receivedAt;
  String? parseError;
}
