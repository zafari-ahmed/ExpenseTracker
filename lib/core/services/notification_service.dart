import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../notifications/notification_messages.dart';

class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static bool _initialized = false;

  static const channelExpense = 'expense_alerts';
  static const channelThreshold = 'threshold_alerts';
  static const channelBill = 'bill_reminders';

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelExpense,
          NotificationMessages.channelExpenseName,
          description: NotificationMessages.channelExpenseDescription,
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelThreshold,
          NotificationMessages.channelThresholdName,
          description: NotificationMessages.channelThresholdDescription,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelBill,
          NotificationMessages.channelBillName,
          description: NotificationMessages.channelBillDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
  }

  Future<void> showExpenseAdded({
    required String transactionId,
    required double amount,
    required String category,
    String place = '',
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelExpense,
        NotificationMessages.channelExpenseName,
        channelDescription: NotificationMessages.channelExpenseDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.show(
      _idFromString('expense_$transactionId'),
      NotificationMessages.expenseAddedTitle,
      NotificationMessages.expenseAdded(
        amount: amount,
        category: category,
        place: place,
      ),
      details,
    );
  }

  Future<void> showThresholdAlert({
    required String categoryId,
    required String category,
    required int percent,
    required double spent,
    required double monthlyLimit,
    required bool exceeded,
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelThreshold,
        NotificationMessages.channelThresholdName,
        channelDescription: NotificationMessages.channelThresholdDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final title = exceeded
        ? NotificationMessages.thresholdExceededTitle
        : NotificationMessages.thresholdWarningTitle;
    final body = exceeded
        ? NotificationMessages.thresholdExceeded(
            category: category,
            percent: percent,
            spent: spent,
            limit: monthlyLimit,
          )
        : NotificationMessages.thresholdWarning(
            category: category,
            percent: percent,
            spent: spent,
            limit: monthlyLimit,
          );

    await _plugin.show(
      _idFromString('threshold_$categoryId'),
      title,
      body,
      details,
    );
  }

  Future<void> showBillReminder({
    required String cardId,
    required String cardName,
    required int billDate,
    required int daysUntil,
  }) async {
    await init();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelBill,
        NotificationMessages.channelBillName,
        channelDescription: NotificationMessages.channelBillDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.show(
      _idFromString('bill_${cardId}_${DateTime.now().year}_${DateTime.now().month}'),
      NotificationMessages.billReminderTitle,
      NotificationMessages.billReminder(
        cardName: cardName,
        billDate: billDate,
        daysUntil: daysUntil,
      ),
      details,
    );
  }

  static int _idFromString(String value) {
    return value.hashCode & 0x7fffffff;
  }
}
