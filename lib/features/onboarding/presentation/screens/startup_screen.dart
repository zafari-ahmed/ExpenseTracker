import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../providers/onboarding_provider.dart';

class StartupScreen extends ConsumerStatefulWidget {
  const StartupScreen({super.key});

  @override
  ConsumerState<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends ConsumerState<StartupScreen> {
  bool _navigated = false;

  Future<void> _goOnce(bool done) async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    context.go(done ? '/dashboard' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(onboardingCompletedProvider).whenData(_goOnce);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      body: Center(
        child: Image.asset(
          isDark ? AppAssets.splashBrandedDark : AppAssets.splashBranded,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
