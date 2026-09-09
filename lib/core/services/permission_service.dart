import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionRequestResult {
  const PermissionRequestResult({
    required this.smsGranted,
    required this.notificationsGranted,
    required this.permanentlyDenied,
  });

  final bool smsGranted;
  final bool notificationsGranted;
  final bool permanentlyDenied;
}

class PermissionService {
  /// Prefer this over telephony.requestSmsPermissions — that plugin crashes
  /// with "Reply already submitted" on many Android versions.
  Future<bool> isSmsGranted() async {
    if (!Platform.isAndroid) return false;
    return Permission.sms.isGranted;
  }

  Future<bool> requestCamera() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<PermissionRequestResult> requestAppPermissions() async {
    final List<Permission> permissions = <Permission>[
      Permission.notification,
    ];

    if (Platform.isAndroid) {
      permissions.add(Permission.sms);
    }

    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    final notificationStatus =
        statuses[Permission.notification] ?? PermissionStatus.denied;
    final smsStatus = Platform.isAndroid
        ? (statuses[Permission.sms] ?? PermissionStatus.denied)
        : PermissionStatus.granted;

    final permanentlyDenied = statuses.values.any(
      (status) => status.isPermanentlyDenied,
    );

    return PermissionRequestResult(
      smsGranted: smsStatus.isGranted,
      notificationsGranted: notificationStatus.isGranted,
      permanentlyDenied: permanentlyDenied,
    );
  }

  Future<bool> openSettings() => openAppSettings();
}
