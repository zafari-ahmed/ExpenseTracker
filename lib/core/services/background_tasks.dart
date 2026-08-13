import 'package:workmanager/workmanager.dart';

import 'notification_runtime.dart';

const billReminderTaskName = 'bill_reminder_check';

@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == billReminderTaskName) {
      try {
        await runStandaloneBillReminders();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  });
}

Future<void> registerBackgroundNotificationTasks() async {
  await Workmanager().registerPeriodicTask(
    billReminderTaskName,
    billReminderTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );
}
