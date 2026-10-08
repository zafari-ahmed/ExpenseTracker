import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_info.dart';
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
  final _pageController = PageController();
  int _page = 0;
  bool _loading = false;
  String _status = '';

  static const _steps = [
    (
      AppAssets.splashShield,
      Icons.shield_outlined,
      'Your data stays on this phone',
      'Cards, SMS parses, and spending history are stored in the app’s private storage. They are not uploaded to our servers, and we do not sell your information.',
    ),
    (
      null,
      Icons.sms_outlined,
      'Bank SMS becomes expenses',
      'This app’s core feature is SMS-based money management: it reads debit SMS from your bank or card and turns matching messages into expenses. You can still add expenses by hand.',
    ),
    (
      null,
      Icons.privacy_tip_outlined,
      'SMS access disclosure',
      'The next step asks Android for SMS permission so the app can read and receive bank and wallet debit messages.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continue({required bool requestSms}) async {
    if (_page < _steps.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

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
    final isLast = _page == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                AppInfo.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Container(
                            width: 180,
                            height: 180,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerLow,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: step.$1 != null
                                ? Image.asset(step.$1!, fit: BoxFit.cover)
                                : Icon(
                                    step.$2,
                                    size: 88,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.section),
                          Text(
                            step.$3,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(
                              step.$4,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ),
                          if (index == 2) ...[
                            const SizedBox(height: 16),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Text(
                                'We request READ_SMS and RECEIVE_SMS only to detect bank and card debit messages and save them as expenses on this device.\n\n'
                                'We do not send SMS. We do not read OTP or 5-digit verification codes. Matching messages stay on this phone and are not uploaded.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_status.isNotEmpty) ...[
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _steps.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              if (Platform.isAndroid && isLast) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading
                        ? null
                        : () => _continue(requestSms: true),
                    child: Text(
                      _loading ? 'Requesting...' : 'Allow SMS tracking',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => _continue(requestSms: false),
                  child: const Text('Not now — add expenses manually'),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading
                        ? null
                        : () => _continue(requestSms: true),
                    child: const Text('Continue'),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
