import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';
import '../../../../core/utils/period_range.dart';

class NotificationPrefs {
  NotificationPrefs({
    required this.billReminderEnabled,
    required this.thresholdAlertsEnabled,
    required this.summaryPushEnabled,
    required this.expenseAddedNotificationsEnabled,
    required this.billLeadDays,
  });

  final bool billReminderEnabled;
  final bool thresholdAlertsEnabled;
  final bool summaryPushEnabled;
  final bool expenseAddedNotificationsEnabled;
  final int billLeadDays;
}

final notificationPrefsProvider = FutureProvider<NotificationPrefs>((ref) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return NotificationPrefs(
    billReminderEnabled: await prefs.billReminderEnabled(),
    thresholdAlertsEnabled: await prefs.thresholdAlertsEnabled(),
    summaryPushEnabled: await prefs.summaryPushEnabled(),
    expenseAddedNotificationsEnabled:
        await prefs.expenseAddedNotificationsEnabled(),
    billLeadDays: await prefs.billLeadDays(),
  );
});

final spendPeriodModeProvider = FutureProvider<SpendPeriodMode>((ref) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return prefs.spendPeriodMode();
});
