import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../features/categories/data/models/category_model.dart';

const _uuid = Uuid();

final List<CategoryModel> defaultCategories = <CategoryModel>[
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Food'
    ..icon = 'restaurant'
    ..color = '#FF7043'
    ..keywords = <String>['food', 'restaurant', 'cafe', 'pizza', 'burger'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Fuel'
    ..icon = 'local_gas_station'
    ..color = '#42A5F5'
    ..keywords = <String>['fuel', 'petrol', 'gas', 'shell', 'ps'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Shopping'
    ..icon = 'shopping_bag'
    ..color = '#AB47BC'
    ..keywords = <String>['mall', 'store', 'shop', 'mart', 'bazaar'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Bills'
    ..icon = 'receipt_long'
    ..color = '#EF5350'
    ..keywords = <String>['bill', 'utility', 'electric', 'water', 'internet'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Groceries'
    ..icon = 'local_grocery_store'
    ..color = '#66BB6A'
    ..keywords = <String>['grocery', 'supermarket', 'fresh', 'market'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Entertainment'
    ..icon = 'movie'
    ..color = '#5C6BC0'
    ..keywords = <String>['cinema', 'movie', 'netflix', 'games', 'music'],
  CategoryModel()
    ..id = _uuid.v4()
    ..name = 'Uncategorized'
    ..icon = 'category'
    ..color = '#90A4AE'
    ..keywords = <String>[],
];

Future<void> seedDefaultCategories(Isar isar) async {
  final existingCount = await isar.categoryModels.count();
  if (existingCount > 0) {
    return;
  }

  await isar.writeTxn(() async {
    await isar.categoryModels.putAll(defaultCategories);
  });
}
