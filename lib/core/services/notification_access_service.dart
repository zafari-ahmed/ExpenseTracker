import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class InstalledAppInfo {
  const InstalledAppInfo({
    required this.packageName,
    required this.label,
    this.iconBytes,
  });

  final String packageName;
  final String label;
  final Uint8List? iconBytes;
}

/// Android Notification Listener access + installed-app listing.
class NotificationAccessService {
  static const _methods =
      MethodChannel('com.theexpensetracker.app/notification_access');
  static const _events =
      EventChannel('com.theexpensetracker.app/notification_events');

  Future<bool> isAccessGranted() async {
    if (!Platform.isAndroid) return false;
    final granted = await _methods.invokeMethod<bool>('isAccessGranted');
    return granted ?? false;
  }

  Future<void> openAccessSettings() async {
    if (!Platform.isAndroid) return;
    await _methods.invokeMethod<void>('openAccessSettings');
  }

  Future<void> setListeningEnabled(bool enabled) async {
    if (!Platform.isAndroid) return;
    await _methods.invokeMethod<void>('setListeningEnabled', enabled);
  }

  Future<bool> isListeningEnabled() async {
    if (!Platform.isAndroid) return false;
    final enabled = await _methods.invokeMethod<bool>('isListeningEnabled');
    return enabled ?? false;
  }

  Future<List<Map<String, dynamic>>> drainPending() async {
    if (!Platform.isAndroid) return const [];
    final raw = await _methods.invokeMethod<List<dynamic>>('drainPending');
    return _asMapList(raw);
  }

  Future<List<Map<String, dynamic>>> getActiveNotifications() async {
    if (!Platform.isAndroid) return const [];
    final raw =
        await _methods.invokeMethod<List<dynamic>>('getActiveNotifications');
    return _asMapList(raw);
  }

  Future<List<InstalledAppInfo>> getInstalledApps() async {
    if (!Platform.isAndroid) return const [];
    final raw = await _methods.invokeMethod<List<dynamic>>('getInstalledApps');
    if (raw == null) return const [];

    final apps = <InstalledAppInfo>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final packageName = (map['packageName'] as String?)?.trim() ?? '';
      final label = (map['label'] as String?)?.trim() ?? '';
      if (packageName.isEmpty || label.isEmpty) continue;

      Uint8List? iconBytes;
      final b64 = map['iconBase64'] as String?;
      if (b64 != null && b64.isNotEmpty) {
        try {
          iconBytes = base64Decode(b64);
        } catch (_) {
          iconBytes = null;
        }
      }

      apps.add(
        InstalledAppInfo(
          packageName: packageName,
          label: label,
          iconBytes: iconBytes,
        ),
      );
    }
    return apps;
  }

  Stream<Map<String, dynamic>> notificationEvents() {
    if (!Platform.isAndroid) {
      return const Stream<Map<String, dynamic>>.empty();
    }
    return _events.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }

  List<Map<String, dynamic>> _asMapList(List<dynamic>? raw) {
    if (raw == null) return const [];
    final out = <Map<String, dynamic>>[];
    for (final item in raw) {
      if (item is Map) {
        out.add(Map<String, dynamic>.from(item));
      }
    }
    return out;
  }
}
