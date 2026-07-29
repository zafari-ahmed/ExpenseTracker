import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> showThresholdAlert({
    required String category,
    required int percent,
    required double monthlyLimit,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'threshold_alerts',
        'Threshold Alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _plugin.show(
      1001,
      'Category threshold reached',
      '$category spend is at $percent% of your limit (${monthlyLimit.toStringAsFixed(0)}).',
      details,
    );
  }

  Future<void> showBillReminder({
    required String cardName,
    required int leadDays,
    required int billDate,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'bill_reminders',
        'Bill Reminders',
        importance: Importance.defaultImportance,
      ),
    );
    await _plugin.show(
      2001,
      'Bill reminder',
      '$cardName bill date is on day $billDate (lead: $leadDays days).',
      details,
    );
  }
}
