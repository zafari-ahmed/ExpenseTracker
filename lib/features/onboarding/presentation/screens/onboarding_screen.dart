import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/services/sms_listener_service.dart';
import '../../../../core/theme/design_tokens.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _loading = false;
  String _status = '';

  Future<void> _continue({required bool requestSms}) async {
    if (!requestSms) {
      await _finishToDashboard();
      return;
    }

    setState(() {
      _loading = true;
      _status = '';
    });

    final permissionService = ref.read(permissionServiceProvider);
    final PermissionRequestResult result =
        await permissionService.requestAppPermissions();

    if (!mounted) return;

    if (Platform.isAndroid && result.smsGranted) {
      try {
        await ref.read(smsListenerServiceProvider).start();
      } catch (e) {
        debugPrint('SMS listener start after onboarding failed: $e');
      }
    } else if (Platform.isAndroid && !result.smsGranted) {
      setState(() {
        _loading = false;
        _status = result.permanentlyDenied
            ? 'SMS was not granted. You can track expenses manually, or enable SMS later in Android Settings.'
            : 'SMS was not granted. You can still use the app and add expenses yourself.';
      });
      if (result.permanentlyDenied) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Continue without SMS'),
            content: const Text(
              'Enable SMS in system settings for automatic bank-expense tracking, or continue and add expenses yourself.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Continue'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await permissionService.openSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    }

    await _finishToDashboard();
  }

  Future<void> _finishToDashboard() async {
    await ref.read(onboardingServiceProvider).markComplete();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryBright,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sms_outlined, color: AppColors.ink),
              ),
              const SizedBox(height: 26),
              Text(
                'Your bank already\ntells you every spend.',
                style: GoogleFonts.archivo(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Let Expense Tracker read those alerts and file them for you. No manual entry, ever.',
                style: GoogleFonts.archivo(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.soft,
                ),
              ),
              const SizedBox(height: 26),
              const _CheckRow(
                title: 'Only your chosen bank senders',
                subtitle: 'Personal messages are never opened.',
              ),
              const SizedBox(height: 14),
              const _CheckRow(
                title: 'Parsed on this device',
                subtitle: 'Nothing is uploaded to a server.',
              ),
              const SizedBox(height: 14),
              const _CheckRow(
                title: 'Revocable any time',
                subtitle: 'Turn it off in Settings; data stays.',
              ),
              const SizedBox(height: 20),
              Text(
                'We request READ_SMS and RECEIVE_SMS only to detect bank and card debit messages. We do not send SMS, and we do not read OTP or 5-digit verification codes.',
                style: GoogleFonts.archivo(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.soft,
                ),
              ),
              const Spacer(),
              if (_status.isNotEmpty) ...[
                Text(
                  _status,
                  style: GoogleFonts.archivo(
                    fontSize: 13,
                    color: AppColors.primaryBright,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : () => _continue(requestSms: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: AppColors.ink,
                  ),
                  child: Text(_loading ? 'Requesting...' : 'Allow SMS access'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      _loading ? null : () => _continue(requestSms: false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.inkMuted),
                  ),
                  child: const Text('Add expenses manually instead'),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'READS SMS · NEVER SENDS THEM',
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppColors.successBright, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.archivo(
                  fontSize: 13,
                  color: AppColors.soft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
