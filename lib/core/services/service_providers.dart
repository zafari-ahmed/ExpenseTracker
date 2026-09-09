import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../database/isar_instance.dart';
import 'app_preferences_service.dart';
import 'backup_service.dart';
import 'bill_reminder_service.dart';
import 'notification_dispatcher.dart';
import 'notification_service.dart';
import 'onboarding_service.dart';
import 'permission_service.dart';
import 'sms_pipeline_service.dart';
import 'threshold_alert_service.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final appPreferencesServiceProvider = Provider<AppPreferencesService>((ref) {
  return AppPreferencesService();
});

final backupServiceProvider = FutureProvider<BackupService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return BackupService(isar);
});

final billReminderServiceProvider = FutureProvider<BillReminderService>((ref) async {
  final cardsRepo = await ref.watch(cardsRepositoryProvider.future);
  final notifications = ref.watch(notificationServiceProvider);
  final preferences = ref.watch(appPreferencesServiceProvider);
  return BillReminderService(
    cardsRepository: cardsRepo,
    notificationService: notifications,
    preferencesService: preferences,
  );
});

final notificationDispatcherProvider =
    FutureProvider<NotificationDispatcher>((ref) async {
  final categoryRepo = await ref.watch(categoriesRepositoryProvider.future);
  final txRepo = await ref.watch(transactionsRepositoryProvider.future);
  final cardsRepo = await ref.watch(cardsRepositoryProvider.future);
  final notifications = ref.watch(notificationServiceProvider);
  final preferences = ref.watch(appPreferencesServiceProvider);
  final billReminders = await ref.watch(billReminderServiceProvider.future);
  return NotificationDispatcher(
    notificationService: notifications,
    preferencesService: preferences,
    categoriesRepository: categoryRepo,
    transactionsRepository: txRepo,
    cardsRepository: cardsRepo,
    billReminderService: billReminders,
  );
});

final smsPipelineServiceProvider = FutureProvider<SmsPipelineService>((ref) async {
  final cardsRepo = await ref.watch(cardsRepositoryProvider.future);
  final txRepo = await ref.watch(transactionsRepositoryProvider.future);
  final catRepo = await ref.watch(categoriesRepositoryProvider.future);
  final prefs = ref.watch(appPreferencesServiceProvider);
  return SmsPipelineService(
    cardsRepository: cardsRepo,
    transactionsRepository: txRepo,
    categoriesRepository: catRepo,
    preferencesService: prefs,
  );
});

final thresholdAlertServiceProvider = FutureProvider<ThresholdAlertService>((ref) async {
  final dispatcher = await ref.watch(notificationDispatcherProvider.future);
  return ThresholdAlertService(notificationDispatcher: dispatcher);
});
