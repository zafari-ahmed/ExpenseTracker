import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
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
    if (!done) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
    }
    context.go(done ? '/dashboard' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(onboardingCompletedProvider).whenData(_goOnce);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const EtBrandMark(size: 56),
            const SizedBox(height: 18),
            Text(
              AppInfo.brand,
              style: GoogleFonts.archivo(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 28,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'SMS-parsed expense tracker',
              style: GoogleFonts.ibmPlexMono(
                color: AppColors.soft,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
