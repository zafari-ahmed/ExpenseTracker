import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';
import '../../../../features/cards/domain/sms_parser.dart';

final smsIgnoreListProvider = FutureProvider<List<String>>((ref) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return prefs.customSmsIgnoreList();
});

final disabledDefaultSmsIgnoreListProvider = FutureProvider<List<String>>((
  ref,
) async {
  final prefs = ref.watch(appPreferencesServiceProvider);
  return prefs.disabledDefaultSmsIgnoreList();
});

final activeDefaultSmsIgnoreListProvider = FutureProvider<List<String>>((
  ref,
) async {
  final disabled = await ref.watch(disabledDefaultSmsIgnoreListProvider.future);
  return SmsParser.effectiveDefaultIgnorePhrases(disabledPhrases: disabled);
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

  Future<bool> disableDefault(String phrase) async {
    final prefs = _ref.read(appPreferencesServiceProvider);
    final removed = await prefs.disableDefaultSmsIgnorePhrase(phrase);
    _ref.invalidate(disabledDefaultSmsIgnoreListProvider);
    _ref.invalidate(activeDefaultSmsIgnoreListProvider);
    return removed;
  }

  Future<void> restoreDefault(String phrase) async {
    final prefs = _ref.read(appPreferencesServiceProvider);
    await prefs.enableDefaultSmsIgnorePhrase(phrase);
    _ref.invalidate(disabledDefaultSmsIgnoreListProvider);
    _ref.invalidate(activeDefaultSmsIgnoreListProvider);
  }
}

/// Built-in phrases available by default (user can disable/restore).
List<String> get builtInSmsIgnorePhrases =>
    List<String>.unmodifiable(SmsParser.defaultIgnorePhrases);
