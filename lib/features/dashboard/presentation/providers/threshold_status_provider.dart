import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/category_threshold_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

enum ThresholdLevel {
  ok,
  warning,
  exceeded,
}

class CategoryThresholdStatus {
  const CategoryThresholdStatus({
    required this.categoryId,
    required this.categoryName,
    required this.spent,
    required this.monthlyLimit,
    required this.notifyAtPercent,
    required this.percentUsed,
    required this.level,
  });

  final String categoryId;
  final String categoryName;
  final double spent;
  final double monthlyLimit;
  final int notifyAtPercent;
  final double percentUsed;
  final ThresholdLevel level;

  bool get isHighlighted =>
      level == ThresholdLevel.warning || level == ThresholdLevel.exceeded;
}

final categoryThresholdStatusesProvider =
    FutureProvider<List<CategoryThresholdStatus>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  final thresholds = await ref.watch(thresholdsProvider.future);
  final transactions = await ref.watch(transactionsListProvider.future);

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final monthEnd = DateTime(now.year, now.month + 1);

  final spentByCategory = <String, double>{};
  for (final tx in transactions) {
    if (tx.transactionDate.isBefore(monthStart) ||
        !tx.transactionDate.isBefore(monthEnd)) {
      continue;
    }
    spentByCategory[tx.category] =
        (spentByCategory[tx.category] ?? 0) + tx.amount;
  }

  final categoryById = <String, CategoryModel>{
    for (final c in categories) c.id: c,
  };

  final statuses = <CategoryThresholdStatus>[];
  for (final threshold in thresholds) {
    if (threshold.monthlyLimit <= 0) {
      continue;
    }
    final category = categoryById[threshold.categoryId];
    if (category == null) {
      continue;
    }

    final spent = spentByCategory[category.name] ?? 0;
    final percentUsed = (spent / threshold.monthlyLimit) * 100;
    final ThresholdLevel level;
    if (percentUsed >= 100) {
      level = ThresholdLevel.exceeded;
    } else if (percentUsed >= threshold.notifyAtPercent) {
      level = ThresholdLevel.warning;
    } else {
      level = ThresholdLevel.ok;
    }

    statuses.add(
      CategoryThresholdStatus(
        categoryId: category.id,
        categoryName: category.name,
        spent: spent,
        monthlyLimit: threshold.monthlyLimit,
        notifyAtPercent: threshold.notifyAtPercent,
        percentUsed: percentUsed,
        level: level,
      ),
    );
  }

  statuses.sort((a, b) => b.percentUsed.compareTo(a.percentUsed));
  return statuses;
});
