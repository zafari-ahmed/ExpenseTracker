import 'package:isar/isar.dart';

part 'category_threshold_model.g.dart';

@collection
class CategoryThresholdModel {
  CategoryThresholdModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = '';

  @Index(unique: true, replace: true)
  late String categoryId;

  late double monthlyLimit;
  int notifyAtPercent = 80;
}
