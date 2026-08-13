import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/service_providers.dart';
import 'core/services/sms_listener_service.dart';
import 'core/theme/app_theme.dart';

class ExpenseTrackerApp extends ConsumerStatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  ConsumerState<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends ConsumerState<ExpenseTrackerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapSms();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _bootstrapSms() async {
    if (!Platform.isAndroid) return;
    try {
      await ref.read(smsBootstrapProvider.future);
      final dispatcher = await ref.read(notificationDispatcherProvider.future);
      await dispatcher.runBillReminderChecks();
    } catch (e) {
      debugPrint('SMS bootstrap failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      ref.read(smsListenerServiceProvider).syncInbox();
      ref.read(notificationDispatcherProvider.future).then(
            (dispatcher) => dispatcher.runBillReminderChecks(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Keep SMS bootstrap alive while app runs.
    ref.watch(smsBootstrapProvider);
    ref.watch(smsSyncTickProvider);

    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
