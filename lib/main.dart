import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/services/background_tasks.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Workmanager().initialize(backgroundCallbackDispatcher);
  await registerBackgroundNotificationTasks();
  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}
