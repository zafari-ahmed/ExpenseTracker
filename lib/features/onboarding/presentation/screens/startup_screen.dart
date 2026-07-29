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

class _StartupScreenState extends ConsumerState<StartupScreen>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goOnce(bool done) async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    context.go(done ? '/dashboard' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final doneAsync = ref.watch(onboardingCompletedProvider);
    doneAsync.whenData(_goOnce);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 148,
                  height: 148,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceContainerLow,
                    boxShadow: AppShadows.level1,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    AppAssets.splashShield,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'ExpenseTracker',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calm control over every spend',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
