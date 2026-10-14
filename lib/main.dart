import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/routing/app_router.dart';
import 'core/services/background_tasks.dart';
import 'core/services/notification_service.dart';
import 'core/services/onboarding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Workmanager().initialize(backgroundCallbackDispatcher);
  await registerBackgroundNotificationTasks();
  final onboarded = await OnboardingService().isComplete();
  runApp(
    ProviderScope(
      overrides: [
        initialLocationProvider.overrideWithValue(
          onboarded ? '/dashboard' : '/',
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
