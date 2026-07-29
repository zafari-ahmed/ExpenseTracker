import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_providers.dart';

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  return service.isComplete();
});
