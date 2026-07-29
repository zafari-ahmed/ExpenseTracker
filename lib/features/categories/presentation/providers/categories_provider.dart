import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/category_model.dart';
import '../../data/models/category_threshold_model.dart';
import '../../data/repositories/categories_repository.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = await ref.watch(categoriesRepositoryProvider.future);
  return repo.getCategories();
});

final thresholdsProvider = FutureProvider<List<CategoryThresholdModel>>((ref) async {
  final repo = await ref.watch(categoriesRepositoryProvider.future);
  return repo.getThresholds();
});

final categoryMutationsProvider = Provider<CategoryMutations>((ref) {
  return CategoryMutations(ref);
});

class CategoryMutations {
  CategoryMutations(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> upsert(CategoryModel model) async {
    final repo = await _ref.read(categoriesRepositoryProvider.future);
    if (model.id.isEmpty) {
      model.id = _uuid.v4();
    }
    await repo.upsertCategory(model);
    _ref.invalidate(categoriesProvider);
  }

  Future<void> delete(String id) async {
    final repo = await _ref.read(categoriesRepositoryProvider.future);
    await repo.deleteCategory(id);
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(thresholdsProvider);
  }

  Future<void> upsertThreshold(CategoryThresholdModel model) async {
    final repo = await _ref.read(categoriesRepositoryProvider.future);
    if (model.id.isEmpty) {
      model.id = _uuid.v4();
    }
    await repo.upsertThreshold(model);
    _ref.invalidate(thresholdsProvider);
    // Dashboard threshold cards depend on this.
    _ref.invalidate(categoriesProvider);
  }
}
