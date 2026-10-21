import 'notification_dispatcher.dart';

class ThresholdAlertService {
  ThresholdAlertService({
    required this.notificationDispatcher,
  });

  final NotificationDispatcher notificationDispatcher;

  Future<void> checkForCategoryThreshold({
    required String categoryName,
    required DateTime forMonth,
  }) async {
    await notificationDispatcher.checkThresholdForCategory(
      categoryName: categoryName,
    );
  }
}
