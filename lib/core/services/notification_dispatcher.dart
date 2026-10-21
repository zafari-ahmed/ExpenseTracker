import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../utils/period_range.dart';
import 'app_preferences_service.dart';
import 'bill_reminder_service.dart';
import 'notification_service.dart';

/// Sends local push notifications after SMS import, thresholds, and bill dates.
class NotificationDispatcher {
  NotificationDispatcher({
    required this.notificationService,
    required this.preferencesService,
    required this.categoriesRepository,
    required this.transactionsRepository,
    required this.cardsRepository,
    required this.billReminderService,
  });

  final NotificationService notificationService;
  final AppPreferencesService preferencesService;
  final CategoriesRepository categoriesRepository;
  final TransactionsRepository transactionsRepository;
  final CardsRepository cardsRepository;
  final BillReminderService billReminderService;

  Future<void> onExpenseAddedFromSms({
    required TransactionModel transaction,
    required String cardName,
  }) async {
    final enabled = await preferencesService.expenseAddedNotificationsEnabled();
    if (!enabled) return;

    await notificationService.showExpenseAdded(
      transactionId: transaction.id,
      amount: transaction.amount,
      category: transaction.category,
      place: transaction.place,
    );

    await _maybeThresholdAlert(categoryName: transaction.category);
  }

  Future<void> checkThresholdForCategory({required String categoryName}) async {
    await _maybeThresholdAlert(categoryName: categoryName);
  }

  Future<void> onManualExpenseAdded({
    required TransactionModel transaction,
  }) async {
    final enabled = await preferencesService.expenseAddedNotificationsEnabled();
    if (!enabled) return;

    await notificationService.showExpenseAdded(
      transactionId: transaction.id,
      amount: transaction.amount,
      category: transaction.category,
      place: transaction.place,
    );

    await _maybeThresholdAlert(categoryName: transaction.category);
  }

  Future<void> _maybeThresholdAlert({required String categoryName}) async {
    final enabled = await preferencesService.thresholdAlertsEnabled();
    if (!enabled) return;

    final category = await categoriesRepository.getByName(categoryName);
    if (category == null) return;

    final threshold =
        await categoriesRepository.getThresholdByCategoryId(category.id);
    if (threshold == null || threshold.monthlyLimit <= 0) return;

    final mode = await preferencesService.spendPeriodMode();
    final cards = await cardsRepository.getCards();
    final billDayByCardId = {for (final c in cards) c.id: c.billDate};
    final fallbackBillDay = cards.isEmpty ? 1 : cards.first.billDate;
    final now = DateTime.now();
    final anchor = PeriodHelper.resolveAnchor(
      selectedMonth: DateTime(now.year, now.month),
      mode: mode,
    );

    final rows = await transactionsRepository.listTransactions(
      category: categoryName,
    );
    final spent = rows
        .where(
          (tx) => PeriodHelper.isInPeriod(
            date: tx.transactionDate,
            mode: mode,
            anchor: anchor,
            billDay: billDayByCardId[tx.cardId] ?? fallbackBillDay,
          ),
        )
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final percent = ((spent / threshold.monthlyLimit) * 100).floor();
    if (percent < threshold.notifyAtPercent) return;

    final exceeded = percent >= 100;
    final bucket = exceeded ? 100 : threshold.notifyAtPercent;
    final alreadySent = await preferencesService.thresholdAlertSent(
      categoryId: category.id,
      bucket: bucket,
      periodKey: _periodKey(mode, anchor),
    );
    if (alreadySent) return;

    await notificationService.showThresholdAlert(
      categoryId: category.id,
      category: categoryName,
      percent: percent,
      spent: spent,
      monthlyLimit: threshold.monthlyLimit,
      exceeded: exceeded,
    );

    await preferencesService.markThresholdAlertSent(
      categoryId: category.id,
      bucket: bucket,
      periodKey: _periodKey(mode, anchor),
    );

    // If exceeded, also allow a separate warning bucket earlier in the period.
    if (exceeded && threshold.notifyAtPercent < 100) {
      await preferencesService.markThresholdAlertSent(
        categoryId: category.id,
        bucket: threshold.notifyAtPercent,
        periodKey: _periodKey(mode, anchor),
      );
    }
  }

  Future<void> runBillReminderChecks() async {
    await billReminderService.checkAndNotify();
  }

  String _periodKey(SpendPeriodMode mode, DateTime anchor) {
    final period = PeriodHelper.forMode(
      mode: mode,
      anchor: anchor,
      billDay: 1,
    );
    return '${period.start.millisecondsSinceEpoch}';
  }
}
