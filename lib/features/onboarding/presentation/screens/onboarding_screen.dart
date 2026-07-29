import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../core/services/service_providers.dart';
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
      'Your Privacy First',
      'All your financial data is encrypted and stored locally. We never sell your personal information.',
    ),
    (
      null,
      Icons.sms_outlined,
      'Smart Automation',
      'Bank SMS is parsed automatically so expenses appear without manual entry.',
    ),
    (
      null,
      Icons.notifications_active_outlined,
      'Secure Access',
      'Grant SMS and notification access so bills and thresholds stay on track.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_page < _steps.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    setState(() {
      _loading = true;
      _status = '';
    });

    final permissionService = ref.read(permissionServiceProvider);
    final onboardingService = ref.read(onboardingServiceProvider);

    final PermissionRequestResult result =
        await permissionService.requestAppPermissions();

    if (!mounted) return;

    if (Platform.isAndroid) {
      if (!result.smsGranted || !result.notificationsGranted) {
        setState(() {
          _loading = false;
          _status = result.permanentlyDenied
              ? 'Permissions were denied permanently. Open Settings to enable SMS and Notifications.'
              : 'Please allow SMS and Notifications so expenses can be tracked automatically.';
        });

        if (result.permanentlyDenied) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permissions required'),
              content: const Text(
                'SMS and notification access were permanently denied. Enable them in system settings to continue auto-tracking.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
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
        return;
      }
    }

    await onboardingService.markComplete();
    if (mounted) context.go('/dashboard');
  }

  Future<void> _skip() async {
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
                'ExpenseTracker',
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
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
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
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            step.$4,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
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
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _continue,
                  child: Text(
                    _loading
                        ? 'Requesting...'
                        : isLast
                            ? (Platform.isAndroid
                                ? 'Grant & Continue'
                                : 'Continue')
                            : 'Continue',
                  ),
                ),
              ),
              if (Platform.isAndroid && isLast)
                TextButton(
                  onPressed: _loading ? null : _skip,
                  child: const Text('Skip for now'),
                )
              else
                const SizedBox(height: 48),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
