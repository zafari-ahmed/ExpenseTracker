import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

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
    final needle = place.toLowerCase().trim();
    if (needle.isEmpty) {
      return getByName('Uncategorized');
    }
    final categories = await getCategories();

    // Prefer longer keyword matches so "kfc" wins over short accidental hits.
    CategoryModel? best;
    var bestLen = 0;
    for (final category in categories) {
      for (final keyword in category.keywords) {
        final key = keyword.toLowerCase().trim();
        if (key.isEmpty) continue;
        if (needle.contains(key) && key.length > bestLen) {
          best = category;
          bestLen = key.length;
        }
      }
    }
    if (best != null) {
      return best;
    }
    return getByName('Uncategorized');
  }

  /// Saves [place] as a keyword on [categoryName] so future SMS auto-categorize.
  /// Also removes the same keyword from other categories to avoid conflicts.
  Future<void> learnPlaceForCategory({
    required String place,
    required String categoryName,
  }) async {
    final keyword = place.trim().toLowerCase();
    if (keyword.isEmpty) return;
    if (categoryName.trim().isEmpty ||
        categoryName.trim().toLowerCase() == 'uncategorized') {
      return;
    }

    final categories = await getCategories();
    CategoryModel? target;
    for (final category in categories) {
      final isTarget =
          category.name.trim().toLowerCase() == categoryName.trim().toLowerCase();
      if (isTarget) {
        target = category;
        continue;
      }
      final had = category.keywords.any(
        (k) => k.trim().toLowerCase() == keyword,
      );
      if (!had) continue;
      category.keywords = category.keywords
          .where((k) => k.trim().toLowerCase() != keyword)
          .toList();
      await upsertCategory(category);
    }

    target ??= await getByName(categoryName);
    if (target == null) return;

    final already = target.keywords.any(
      (k) => k.trim().toLowerCase() == keyword,
    );
    if (!already) {
      target.keywords = <String>[...target.keywords, keyword];
      await upsertCategory(target);
    }
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
