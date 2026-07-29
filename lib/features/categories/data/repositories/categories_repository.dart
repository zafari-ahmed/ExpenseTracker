import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/database/isar_instance.dart';
import '../models/category_model.dart';
import '../models/category_threshold_model.dart';

class CategoriesRepository {
  CategoriesRepository(this._isar);

  final Isar _isar;

  Future<List<CategoryModel>> getCategories() {
    return _isar.categoryModels.where().sortByName().findAll();
  }

  Future<CategoryModel?> getById(String categoryId) {
    return _isar.categoryModels.filter().idEqualTo(categoryId).findFirst();
  }

  Future<CategoryModel?> getByName(String name) {
    return _isar.categoryModels.filter().nameEqualTo(name).findFirst();
  }

  Future<void> upsertCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    final category = await getById(categoryId);
    if (category == null) {
      return;
    }

    await _isar.writeTxn(() async {
      await _isar.categoryThresholdModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .deleteAll();
      await _isar.categoryModels.delete(category.isarId);
    });
  }

  Future<CategoryModel?> autoCategoryFromPlace(String place) async {
    final needle = place.toLowerCase();
    final categories = await getCategories();
    for (final category in categories) {
      final matched = category.keywords.any(
        (keyword) => needle.contains(keyword.toLowerCase()),
      );
      if (matched) {
        return category;
      }
    }
    return getByName('Uncategorized');
  }

  Future<List<CategoryThresholdModel>> getThresholds() {
    return _isar.categoryThresholdModels.where().findAll();
  }

  Future<CategoryThresholdModel?> getThresholdByCategoryId(String categoryId) {
    return _isar.categoryThresholdModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findFirst();
  }

  Future<void> upsertThreshold(CategoryThresholdModel threshold) async {
    await _isar.writeTxn(() async {
      await _isar.categoryThresholdModels.put(threshold);
    });
  }
}

final categoriesRepositoryProvider =
    FutureProvider<CategoriesRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return CategoriesRepository(isar);
});
