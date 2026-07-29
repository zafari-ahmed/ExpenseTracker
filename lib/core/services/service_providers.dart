import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import 'app_preferences_service.dart';
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

final smsPipelineServiceProvider = FutureProvider<SmsPipelineService>((ref) async {
  final cardsRepo = await ref.watch(cardsRepositoryProvider.future);
  final txRepo = await ref.watch(transactionsRepositoryProvider.future);
  final catRepo = await ref.watch(categoriesRepositoryProvider.future);
  return SmsPipelineService(
    cardsRepository: cardsRepo,
    transactionsRepository: txRepo,
    categoriesRepository: catRepo,
  );
});

final thresholdAlertServiceProvider = FutureProvider<ThresholdAlertService>((ref) async {
  final categoryRepo = await ref.watch(categoriesRepositoryProvider.future);
  final txRepo = await ref.watch(transactionsRepositoryProvider.future);
  final notification = ref.watch(notificationServiceProvider);
  final preferences = ref.watch(appPreferencesServiceProvider);
  return ThresholdAlertService(
    categoriesRepository: categoryRepo,
    transactionsRepository: txRepo,
    notificationService: notification,
    preferencesService: preferences,
  );
});
