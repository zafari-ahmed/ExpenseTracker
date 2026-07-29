import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = '';

  @Index(unique: true, replace: true)
  late String name;

  late String icon;
  List<String> keywords = <String>[];
  late String color;
}
