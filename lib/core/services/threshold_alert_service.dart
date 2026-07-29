import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import 'app_preferences_service.dart';
import 'notification_service.dart';

class ThresholdAlertService {
  ThresholdAlertService({
    required this.categoriesRepository,
    required this.transactionsRepository,
    required this.notificationService,
    required this.preferencesService,
  });

  final CategoriesRepository categoriesRepository;
  final TransactionsRepository transactionsRepository;
  final NotificationService notificationService;
  final AppPreferencesService preferencesService;

  Future<void> checkForCategoryThreshold({
    required String categoryName,
    required DateTime forMonth,
  }) async {
    final enabled = await preferencesService.thresholdAlertsEnabled();
    if (!enabled) {
      return;
    }

    final category = await categoriesRepository.getByName(categoryName);
    if (category == null) {
      return;
    }
    final threshold = await categoriesRepository.getThresholdByCategoryId(category.id);
    if (threshold == null || threshold.monthlyLimit <= 0) {
      return;
    }

    final monthStart = DateTime(forMonth.year, forMonth.month);
    final monthEnd = DateTime(forMonth.year, forMonth.month + 1).subtract(const Duration(milliseconds: 1));
    final rows = await transactionsRepository.listTransactions(
      category: categoryName,
      fromDate: monthStart,
      toDate: monthEnd,
    );
    final total = rows.fold<double>(0, (sum, tx) => sum + tx.amount);
    final percent = ((total / threshold.monthlyLimit) * 100).floor();
    if (percent >= threshold.notifyAtPercent) {
      await notificationService.showThresholdAlert(
        category: categoryName,
        percent: percent,
        monthlyLimit: threshold.monthlyLimit,
      );
    }
  }
}
