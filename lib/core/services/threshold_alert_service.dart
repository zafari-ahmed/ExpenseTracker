import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../utils/period_range.dart';
import 'app_preferences_service.dart';
import 'notification_service.dart';

class ThresholdAlertService {
  ThresholdAlertService({
    required this.categoriesRepository,
    required this.transactionsRepository,
    required this.notificationService,
    required this.preferencesService,
    required this.cardsRepository,
  });

  final CategoriesRepository categoriesRepository;
  final TransactionsRepository transactionsRepository;
  final NotificationService notificationService;
  final AppPreferencesService preferencesService;
  final CardsRepository cardsRepository;

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

    final mode = await preferencesService.spendPeriodMode();
    final cards = await cardsRepository.getCards();
    final billDayByCardId = <String, int>{
      for (final c in cards) c.id: c.billDate,
    };
    final fallbackBillDay = cards.isEmpty ? 1 : cards.first.billDate;
    final selectedMonth = DateTime(forMonth.year, forMonth.month);
    final anchor = PeriodHelper.resolveAnchor(
      selectedMonth: selectedMonth,
      mode: mode,
    );

    final rows = await transactionsRepository.listTransactions(
      category: categoryName,
    );
    final total = rows
        .where(
          (tx) => PeriodHelper.isInPeriod(
            date: tx.transactionDate,
            mode: mode,
            anchor: anchor,
            billDay: billDayByCardId[tx.cardId] ?? fallbackBillDay,
          ),
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);
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
