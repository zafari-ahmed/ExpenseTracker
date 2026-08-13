import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/categories/data/models/category_threshold_model.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/models/needs_review_item_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import 'app_preferences_service.dart';
import 'bill_reminder_service.dart';
import 'notification_dispatcher.dart';
import 'notification_service.dart';
import 'sms_pipeline_service.dart';
import 'sms_process_result.dart';

/// Opens DB + notification stack without Riverpod (background isolate safe).
Future<({
  SmsPipelineService pipeline,
  NotificationDispatcher dispatcher,
})> createStandaloneNotificationStack() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.getInstance('expense_tracker_db') ??
      await Isar.open(
        <CollectionSchema<dynamic>>[
          CardModelSchema,
          SmsParsingRuleModelSchema,
          TransactionModelSchema,
          NeedsReviewItemModelSchema,
          CategoryModelSchema,
          CategoryThresholdModelSchema,
        ],
        directory: dir.path,
        name: 'expense_tracker_db',
      );

  final prefs = AppPreferencesService();
  final cardsRepo = CardsRepository(isar);
  final txRepo = TransactionsRepository(isar);
  final catRepo = CategoriesRepository(isar);
  final notifications = NotificationService();
  await notifications.init();

  final billReminders = BillReminderService(
    cardsRepository: cardsRepo,
    notificationService: notifications,
    preferencesService: prefs,
  );

  final dispatcher = NotificationDispatcher(
    notificationService: notifications,
    preferencesService: prefs,
    categoriesRepository: catRepo,
    transactionsRepository: txRepo,
    cardsRepository: cardsRepo,
    billReminderService: billReminders,
  );

  final pipeline = SmsPipelineService(
    cardsRepository: cardsRepo,
    transactionsRepository: txRepo,
    categoriesRepository: catRepo,
    preferencesService: prefs,
  );

  return (pipeline: pipeline, dispatcher: dispatcher);
}

Future<void> handleSmsProcessResult(SmsProcessResult result) async {
  if (result.kind != SmsProcessKind.expenseAdded) return;
  final tx = result.transaction;
  if (tx == null) return;

  final stack = await createStandaloneNotificationStack();
  await stack.dispatcher.onExpenseAddedFromSms(
    transaction: tx,
    cardName: result.cardName ?? 'Card',
  );
}

Future<void> runStandaloneBillReminders() async {
  final stack = await createStandaloneNotificationStack();
  await stack.dispatcher.runBillReminderChecks();
}
