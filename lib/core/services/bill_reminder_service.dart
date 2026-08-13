import '../../features/cards/data/repositories/cards_repository.dart';
import '../utils/period_range.dart';
import 'app_preferences_service.dart';
import 'notification_service.dart';

class BillReminderService {
  BillReminderService({
    required this.cardsRepository,
    required this.notificationService,
    required this.preferencesService,
  });

  final CardsRepository cardsRepository;
  final NotificationService notificationService;
  final AppPreferencesService preferencesService;

  Future<void> checkAndNotify() async {
    final enabled = await preferencesService.billReminderEnabled();
    if (!enabled) return;

    final leadDays = await preferencesService.billLeadDays();
    final cards = await cardsRepository.getCards(activeOnly: true);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final card in cards) {
      final nextBill = _nextBillDate(todayDate, card.billDate);
      final daysUntil = nextBill.difference(todayDate).inDays;
      if (daysUntil > leadDays) continue;

      final periodKey = '${nextBill.year}-${nextBill.month}-${nextBill.day}';
      final already = await preferencesService.billReminderSent(
        cardId: card.id,
        periodKey: periodKey,
      );
      if (already) continue;

      await notificationService.showBillReminder(
        cardId: card.id,
        cardName: card.cardName,
        billDate: card.billDate,
        daysUntil: daysUntil,
      );
      await preferencesService.markBillReminderSent(
        cardId: card.id,
        periodKey: periodKey,
      );
    }
  }

  static DateTime _nextBillDate(DateTime from, int billDay) {
    final dayThisMonth =
        PeriodHelper.clampBillDay(billDay, from.year, from.month);
    var candidate = DateTime(from.year, from.month, dayThisMonth);
    if (from.isAfter(candidate)) {
      final nextMonth = DateTime(from.year, from.month + 1);
      final dayNext =
          PeriodHelper.clampBillDay(billDay, nextMonth.year, nextMonth.month);
      candidate = DateTime(nextMonth.year, nextMonth.month, dayNext);
    }
    return candidate;
  }
}
