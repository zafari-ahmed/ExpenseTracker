import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/service_providers.dart';

final profileImagePathProvider = FutureProvider<String?>((ref) async {
  return ref.watch(appPreferencesServiceProvider).profileImagePath();
});

final profileNameProvider = FutureProvider<String>((ref) async {
  return ref.watch(appPreferencesServiceProvider).profileName();
});

final profileMutationsProvider = Provider<ProfileMutations>((ref) {
  return ProfileMutations(ref);
});

class ProfileMutations {
  ProfileMutations(this._ref);

  final Ref _ref;
  final _picker = ImagePicker();

  Future<String?> pickAndSave({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 88,
    );
    if (picked == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final dest = File('${docs.path}/profile_avatar.jpg');
    await File(picked.path).copy(dest.path);

    await _ref.read(appPreferencesServiceProvider).setProfileImagePath(dest.path);
    _ref.invalidate(profileImagePathProvider);
    return dest.path;
  }

  Future<void> clear() async {
    final current = await _ref.read(appPreferencesServiceProvider).profileImagePath();
    if (current != null) {
      final file = File(current);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _ref.read(appPreferencesServiceProvider).setProfileImagePath(null);
    _ref.invalidate(profileImagePathProvider);
  }

  Future<void> setName(String name) async {
    await _ref.read(appPreferencesServiceProvider).setProfileName(name);
    _ref.invalidate(profileNameProvider);
  }
}
