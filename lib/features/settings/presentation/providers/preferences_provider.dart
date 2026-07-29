import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';

class NotificationPrefs {
  NotificationPrefs({
    required this.billReminderEnabled,
    required this.thresholdAlertsEnabled,
    required this.summaryPushEnabled,
    required this.billLeadDays,
  });

  final bool billReminderEnabled;
  final bool thresholdAlertsEnabled;
  final bool summaryPushEnabled;
  final int billLeadDays;
}

final notificationPrefsProvider = FutureProvider<NotificationPrefs>((ref) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return NotificationPrefs(
    billReminderEnabled: await prefs.billReminderEnabled(),
    thresholdAlertsEnabled: await prefs.thresholdAlertsEnabled(),
    summaryPushEnabled: await prefs.summaryPushEnabled(),
    billLeadDays: await prefs.billLeadDays(),
  );
});
