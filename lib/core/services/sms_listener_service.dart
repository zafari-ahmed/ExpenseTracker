import 'dart:io';

import 'package:another_telephony/telephony.dart' as telephony;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cards/domain/sms_parser.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import '../database/isar_instance.dart';
import 'notification_runtime.dart';
import 'service_providers.dart';
import 'sms_process_result.dart';

class LatestSenderSms {
  const LatestSenderSms({
    required this.senderId,
    required this.body,
    required this.receivedAt,
  });

  final String senderId;
  final String body;
  final DateTime receivedAt;
}

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

    final stack = await createStandaloneNotificationStack();
    final result = await stack.pipeline.processIncomingSms(
      senderId: address,
      body: body,
      receivedAt: receivedAt,
    );
    await handleSmsProcessResult(result);
  } catch (e, st) {
    debugPrint('Background SMS handling failed: $e\n$st');
  }
}

class SmsListenerService {
  SmsListenerService(this._ref);

  final Ref _ref;
  final telephony.Telephony _telephony = telephony.Telephony.instance;
  bool _listening = false;
  bool _scanning = false;

  Future<void> start() async {
    if (!Platform.isAndroid) return;

    // Never call Telephony.requestSmsPermissions — it crashes on permission
    // results ("Reply already submitted"). Use permission_handler only.
    final granted =
        await _ref.read(permissionServiceProvider).isSmsGranted();
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
    final result = await pipeline.processIncomingSms(
      senderId: address,
      body: body,
      receivedAt: receivedAt,
    );
    if (result.created) {
      _invalidateUi();
    }
    if (result.kind == SmsProcessKind.expenseAdded && result.transaction != null) {
      final dispatcher = await _ref.read(notificationDispatcherProvider.future);
      await dispatcher.onExpenseAddedFromSms(
        transaction: result.transaction!,
        cardName: result.cardName ?? 'Card',
      );
    }
  }

  /// Scan device inbox for card SMS since last successful sync (or last 14 days).
  Future<int> syncInbox({bool forceFullWindow = false}) async {
    if (!Platform.isAndroid || _scanning) return 0;
    _scanning = true;
    var createdCount = 0;

    try {
      final granted =
          await _ref.read(permissionServiceProvider).isSmsGranted();
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

        final result = await pipeline.processIncomingSms(
          senderId: address,
          body: body,
          receivedAt: receivedAt,
        );
        if (result.created) createdCount++;
        if (result.kind == SmsProcessKind.expenseAdded &&
            result.transaction != null) {
          final dispatcher =
              await _ref.read(notificationDispatcherProvider.future);
          await dispatcher.onExpenseAddedFromSms(
            transaction: result.transaction!,
            cardName: result.cardName ?? 'Card',
          );
        }
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

  /// Latest inbox SMS from [senderId], preferring a debit/expense message
  /// over OTP or credit alerts when possible.
  Future<LatestSenderSms?> latestInboxSmsForSender({
    required String senderId,
    String? lastFourDigits,
  }) async {
    if (!Platform.isAndroid) return null;
    final configured = _normalizeSender(senderId);
    if (configured.isEmpty) return null;

    final granted =
        await _ref.read(permissionServiceProvider).isSmsGranted();
    if (!granted) return null;

    try {
      final since = DateTime.now()
          .subtract(const Duration(days: 90))
          .millisecondsSinceEpoch;
      final messages = await _telephony.getInboxSms(
        columns: [
          telephony.SmsColumn.ADDRESS,
          telephony.SmsColumn.BODY,
          telephony.SmsColumn.DATE,
        ],
        filter: telephony.SmsFilter.where(telephony.SmsColumn.DATE)
            .greaterThanOrEqualTo('$since'),
        sortOrder: [
          telephony.OrderBy(
            telephony.SmsColumn.DATE,
            sort: telephony.Sort.DESC,
          ),
        ],
      );

      LatestSenderSms? withDigits;
      LatestSenderSms? expenseLike;
      LatestSenderSms? anyFromSender;
      final digits = lastFourDigits?.trim();

      for (final message in messages) {
        final address = message.address?.trim() ?? '';
        final body = message.body?.trim() ?? '';
        if (address.isEmpty || body.isEmpty) continue;
        if (!_senderMatches(address, configured)) continue;

        final receivedAt = message.date != null
            ? DateTime.fromMillisecondsSinceEpoch(message.date!)
            : DateTime.now();
        final item = LatestSenderSms(
          senderId: address,
          body: body,
          receivedAt: receivedAt,
        );
        anyFromSender ??= item;

        if (SmsParser.shouldIgnoreSms(body)) continue;
        expenseLike ??= item;

        if (digits != null &&
            digits.length >= 4 &&
            body.toLowerCase().contains(digits.toLowerCase())) {
          withDigits = item;
          break;
        }
      }

      return withDigits ?? expenseLike ?? anyFromSender;
    } catch (e, st) {
      debugPrint('Latest sender SMS lookup failed: $e\n$st');
      return null;
    }
  }

  static String _normalizeSender(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static bool _senderMatches(String address, String configuredNormalized) {
    final addr = _normalizeSender(address);
    if (addr.isEmpty || configuredNormalized.isEmpty) return false;
    return addr == configuredNormalized ||
        addr.contains(configuredNormalized) ||
        configuredNormalized.contains(addr);
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
/// Skips the telephony permission dialog so onboarding can request via
/// [PermissionService] without racing another_telephony.
final smsBootstrapProvider = FutureProvider<void>((ref) async {
  if (!Platform.isAndroid) return;
  await ref.watch(isarProvider.future);
  await SharedPreferences.getInstance();

  final onboardingDone =
      await ref.read(onboardingServiceProvider).isComplete();
  final smsGranted = await ref.read(permissionServiceProvider).isSmsGranted();
  if (!onboardingDone && !smsGranted) {
    debugPrint('SMS bootstrap deferred until onboarding grants SMS');
    return;
  }

  await ref.read(smsListenerServiceProvider).start();
});
