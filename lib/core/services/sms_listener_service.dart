import 'dart:io';

import 'package:another_telephony/telephony.dart' as telephony;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/models/sms_parsing_rule_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/categories/data/models/category_threshold_model.dart';
import '../../features/categories/data/repositories/categories_repository.dart';
import '../../features/transactions/data/models/needs_review_item_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/repositories/transactions_repository.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import '../database/isar_instance.dart';
import 'service_providers.dart';
import 'sms_pipeline_service.dart';

/// Bumps whenever SMS sync creates/updates data so UI can refresh.
final smsSyncTickProvider = StateProvider<int>((ref) => 0);

/// Top-level background SMS handler (must stay top-level for telephony).
@pragma('vm:entry-point')
Future<void> onBackgroundSms(telephony.SmsMessage message) async {
  try {
    final address = message.address?.trim() ?? '';
    final body = message.body?.trim() ?? '';
    if (address.isEmpty || body.isEmpty) return;

    final receivedAt = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : DateTime.now();

    final pipeline = await _standalonePipeline();
    await pipeline.processIncomingSms(
      senderId: address,
      body: body,
      receivedAt: receivedAt,
    );
  } catch (e, st) {
    debugPrint('Background SMS handling failed: $e\n$st');
  }
}

Future<SmsPipelineService> _standalonePipeline() async {
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

  return SmsPipelineService(
    cardsRepository: CardsRepository(isar),
    transactionsRepository: TransactionsRepository(isar),
    categoriesRepository: CategoriesRepository(isar),
  );
}

class SmsListenerService {
  SmsListenerService(this._ref);

  final Ref _ref;
  final telephony.Telephony _telephony = telephony.Telephony.instance;
  bool _listening = false;
  bool _scanning = false;

  Future<void> start() async {
    if (!Platform.isAndroid) return;

    final granted = await _telephony.requestSmsPermissions ?? false;
    if (!granted) {
      debugPrint('SMS permissions not granted — auto-detect disabled');
      return;
    }

    if (!_listening) {
      _telephony.listenIncomingSms(
        onNewMessage: _onForegroundMessage,
        onBackgroundMessage: onBackgroundSms,
        listenInBackground: true,
      );
      _listening = true;
    }

    await syncInbox();
  }

  Future<void> _onForegroundMessage(telephony.SmsMessage message) async {
    final address = message.address?.trim() ?? '';
    final body = message.body?.trim() ?? '';
    if (address.isEmpty || body.isEmpty) return;

    final receivedAt = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : DateTime.now();

    final pipeline = await _ref.read(smsPipelineServiceProvider.future);
    final created = await pipeline.processIncomingSms(
      senderId: address,
      body: body,
      receivedAt: receivedAt,
    );
    if (created) {
      _invalidateUi();
    }
  }

  /// Scan device inbox for card SMS since last successful sync (or last 14 days).
  Future<int> syncInbox({bool forceFullWindow = false}) async {
    if (!Platform.isAndroid || _scanning) return 0;
    _scanning = true;
    var createdCount = 0;

    try {
      final granted = await _telephony.requestSmsPermissions ?? false;
      if (!granted) return 0;

      final prefs = _ref.read(appPreferencesServiceProvider);
      final lastScan = await prefs.lastSmsScanMillis();
      final now = DateTime.now();
      final sinceMillis = forceFullWindow || lastScan <= 0
          ? now.subtract(const Duration(days: 14)).millisecondsSinceEpoch
          : lastScan;

      final messages = await _telephony.getInboxSms(
        columns: [
          telephony.SmsColumn.ADDRESS,
          telephony.SmsColumn.BODY,
          telephony.SmsColumn.DATE,
        ],
        filter: telephony.SmsFilter.where(telephony.SmsColumn.DATE)
            .greaterThanOrEqualTo('$sinceMillis'),
        sortOrder: [
          telephony.OrderBy(
            telephony.SmsColumn.DATE,
            sort: telephony.Sort.DESC,
          ),
        ],
      );

      final pipeline = await _ref.read(smsPipelineServiceProvider.future);
      final ordered = messages.toList()
        ..sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));

      for (final message in ordered) {
        final address = message.address?.trim() ?? '';
        final body = message.body?.trim() ?? '';
        if (address.isEmpty || body.isEmpty) continue;

        final receivedAt = message.date != null
            ? DateTime.fromMillisecondsSinceEpoch(message.date!)
            : now;

        final created = await pipeline.processIncomingSms(
          senderId: address,
          body: body,
          receivedAt: receivedAt,
        );
        if (created) createdCount++;
      }

      await prefs.setLastSmsScanMillis(now.millisecondsSinceEpoch);
      if (createdCount > 0) {
        _invalidateUi();
      }
    } catch (e, st) {
      debugPrint('Inbox SMS sync failed: $e\n$st');
    } finally {
      _scanning = false;
    }

    return createdCount;
  }

  void _invalidateUi() {
    _ref.read(smsSyncTickProvider.notifier).state++;
    _ref.invalidate(transactionsListProvider);
    _ref.invalidate(thisMonthTotalProvider);
    _ref.invalidate(needsReviewProvider);
  }
}

final smsListenerServiceProvider = Provider<SmsListenerService>((ref) {
  return SmsListenerService(ref);
});

/// Ensures Isar provider is warm before SMS sync (used by app bootstrap).
final smsBootstrapProvider = FutureProvider<void>((ref) async {
  if (!Platform.isAndroid) return;
  await ref.watch(isarProvider.future);
  await SharedPreferences.getInstance();
  await ref.read(smsListenerServiceProvider).start();
});
