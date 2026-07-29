import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesService {
  static const _billReminderEnabled = 'bill_reminder_enabled';
  static const _thresholdAlertsEnabled = 'threshold_alerts_enabled';
  static const _summaryPushEnabled = 'summary_push_enabled';
  static const _billLeadDays = 'bill_lead_days';
  static const _profileImagePath = 'profile_image_path';
  static const _profileName = 'profile_name';
  static const _lastSmsScanMillis = 'last_sms_scan_millis';

  Future<bool> billReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_billReminderEnabled) ?? true;
  }

  Future<bool> thresholdAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_thresholdAlertsEnabled) ?? true;
  }

  Future<bool> summaryPushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_summaryPushEnabled) ?? false;
  }

  Future<int> billLeadDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_billLeadDays) ?? 3;
  }

  Future<String?> profileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImagePath);
  }

  Future<String> profileName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_profileName)?.trim();
    if (name == null || name.isEmpty) {
      return 'Alex Thompson';
    }
    return name;
  }

  Future<void> setProfileImagePath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_profileImagePath);
    } else {
      await prefs.setString(_profileImagePath, path);
    }
  }

  Future<void> setProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final value = name.trim();
    if (value.isEmpty) {
      await prefs.remove(_profileName);
    } else {
      await prefs.setString(_profileName, value);
    }
  }

  Future<int> lastSmsScanMillis() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSmsScanMillis) ?? 0;
  }

  Future<void> setLastSmsScanMillis(int millis) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSmsScanMillis, millis);
  }

  Future<void> setBillReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_billReminderEnabled, value);
  }

  Future<void> setThresholdAlertsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_thresholdAlertsEnabled, value);
  }

  Future<void> setSummaryPushEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_summaryPushEnabled, value);
  }

  Future<void> setBillLeadDays(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_billLeadDays, value);
  }
}
