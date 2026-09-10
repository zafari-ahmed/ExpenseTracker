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

  static const _shieldSize = 160.0;

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
    final background =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final titleColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final taglineColor =
        isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant;

    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final shieldTop = constraints.maxHeight / 2 - _shieldSize / 2;
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: shieldTop,
                child: Center(
                  child: SizedBox(
                    width: _shieldSize,
                    height: _shieldSize,
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.splashShield,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: shieldTop + _shieldSize + 24,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  builder: (context, opacity, child) =>
                      Opacity(opacity: opacity, child: child),
                  child: Column(
                    children: [
                      Text(
                        'Expense Tracker',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: titleColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 28,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calm control over every spend',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: taglineColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
