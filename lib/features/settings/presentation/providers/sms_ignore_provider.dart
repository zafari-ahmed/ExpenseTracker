import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';
import '../../../../features/cards/domain/sms_parser.dart';

final smsIgnoreListProvider = FutureProvider<List<String>>((ref) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return prefs.customSmsIgnoreList();
});

final smsIgnoreMutationsProvider = Provider<SmsIgnoreMutations>((ref) {
  return SmsIgnoreMutations(ref);
});

class SmsIgnoreMutations {
  SmsIgnoreMutations(this._ref);

  final Ref _ref;

  Future<bool> add(String entry) async {
    final prefs = _ref.read(appPreferencesServiceProvider);
    final added = await prefs.addCustomSmsIgnoreEntry(entry);
    _ref.invalidate(smsIgnoreListProvider);
    return added;
  }

  Future<void> remove(String entry) async {
    final prefs = _ref.read(appPreferencesServiceProvider);
    await prefs.removeCustomSmsIgnoreEntry(entry);
    _ref.invalidate(smsIgnoreListProvider);
  }
}

/// Built-in phrases shown read-only in Settings for reference.
List<String> get builtInSmsIgnorePhrases =>
    List<String>.unmodifiable(SmsParser.defaultIgnorePhrases);
