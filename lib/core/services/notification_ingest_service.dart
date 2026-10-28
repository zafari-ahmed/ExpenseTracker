import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/cards/data/models/card_model.dart';
import '../../features/cards/data/repositories/cards_repository.dart';
import '../../features/transactions/presentation/providers/transactions_provider.dart';
import 'notification_access_service.dart';
import 'service_providers.dart';
import 'sms_listener_service.dart';
import 'sms_process_result.dart';

/// Listens to Android NotificationListenerService events and inserts expenses
/// for cards with parseSource=notification.
class NotificationIngestService {
  NotificationIngestService(this._ref);

  final Ref _ref;
  final NotificationAccessService _access = NotificationAccessService();
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _starting = false;
  final Set<String> _recentKeys = <String>{};

  Future<void> start() async {
    if (!Platform.isAndroid) return;
    if (_starting) return;
    _starting = true;
    try {
      final cardsRepo = await _ref.read(cardsRepositoryProvider.future);
      final cards = await cardsRepo.getCards(activeOnly: true);
      final hasNotificationCards = cards.any(
        (c) =>
            c.parseSource == CardParseSource.notification &&
            c.notificationPackage.trim().isNotEmpty,
      );

      await _access.setListeningEnabled(hasNotificationCards);
      if (!hasNotificationCards) {
        await _sub?.cancel();
        _sub = null;
        return;
      }

      final granted = await _access.isAccessGranted();
      if (!granted) {
        debugPrint('Notification access not granted — ingest paused');
        await _sub?.cancel();
        _sub = null;
        return;
      }

      _sub ??= _access.notificationEvents().listen(
            _onEvent,
            onError: (Object e, StackTrace st) {
              debugPrint('Notification event stream error: $e\n$st');
            },
          );

      // Drain anything posted while Flutter was detached, then scan the shade.
      final pending = await _access.drainPending();
      for (final event in pending) {
        await _handlePayload(event);
      }
      final active = await _access.getActiveNotifications();
      for (final event in active) {
        await _handlePayload(event);
      }
    } catch (e, st) {
      debugPrint('Notification ingest start failed: $e\n$st');
    } finally {
      _starting = false;
    }
  }

  Future<void> refreshListeningState() => start();

  void _onEvent(Map<String, dynamic> event) {
    unawaited(_handlePayload(event));
  }

  Future<void> _handlePayload(Map<String, dynamic> event) async {
    final packageName = (event['packageName'] as String?)?.trim() ?? '';
    final text = (event['text'] as String?)?.trim() ?? '';
    if (packageName.isEmpty || text.isEmpty) return;

    final key = (event['key'] as String?)?.trim();
    if (key != null && key.isNotEmpty) {
      if (_recentKeys.contains(key)) return;
      _recentKeys.add(key);
      if (_recentKeys.length > 200) {
        _recentKeys.remove(_recentKeys.first);
      }
    }

    final postedAtMillis = event['postedAtMillis'];
    DateTime? postedAt;
    if (postedAtMillis is int) {
      postedAt = DateTime.fromMillisecondsSinceEpoch(postedAtMillis);
    } else if (postedAtMillis is num) {
      postedAt = DateTime.fromMillisecondsSinceEpoch(postedAtMillis.toInt());
    }

    try {
      final pipeline = await _ref.read(smsPipelineServiceProvider.future);
      final result = await pipeline.processIncomingNotification(
        packageName: packageName,
        text: text,
        postedAt: postedAt,
      );
      if (result.created) {
        _ref.read(smsSyncTickProvider.notifier).state++;
        _ref.invalidate(transactionsListProvider);
        _ref.invalidate(thisMonthTotalProvider);
        _ref.invalidate(needsReviewProvider);
      }
      if (result.kind == SmsProcessKind.expenseAdded &&
          result.transaction != null) {
        final dispatcher =
            await _ref.read(notificationDispatcherProvider.future);
        await dispatcher.onExpenseAddedFromSms(
          transaction: result.transaction!,
          cardName: result.cardName ?? 'Card',
        );
      }
    } catch (e, st) {
      debugPrint('Notification ingest failed: $e\n$st');
    }
  }
}

final notificationAccessServiceProvider =
    Provider<NotificationAccessService>((ref) {
  return NotificationAccessService();
});

final notificationIngestServiceProvider =
    Provider<NotificationIngestService>((ref) {
  return NotificationIngestService(ref);
});

final notificationAccessGrantedProvider = FutureProvider<bool>((ref) async {
  if (!Platform.isAndroid) return false;
  return ref.watch(notificationAccessServiceProvider).isAccessGranted();
});

final notificationIngestBootstrapProvider = FutureProvider<void>((ref) async {
  if (!Platform.isAndroid) return;
  await ref.read(notificationIngestServiceProvider).start();
});
