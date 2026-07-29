import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _keyDone = 'onboarding_done';

  Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDone) ?? false;
  }

  Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDone, true);
  }
}
