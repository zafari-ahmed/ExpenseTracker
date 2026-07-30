import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/service_providers.dart';
import '../../../../core/services/sms_listener_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/data/models/category_threshold_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../dashboard/presentation/providers/threshold_status_provider.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    final thresholdsAsync = ref.watch(thresholdsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cardsAsync = ref.watch(cardsListProvider);
    final reviewAsync = ref.watch(needsReviewProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profileNameAsync = ref.watch(profileNameProvider);
    final profileName = profileNameAsync.valueOrNull ?? 'Member';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            0,
            AppSpacing.margin,
            108,
          ),
          children: [
            const EtAppHeader(),
            EtSurfaceCard(
              elevated: false,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const EtAvatar(size: 88),
                      Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _changeProfilePhoto(context, ref),
                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profileName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'SMS Expense Tracking',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => _changeProfilePhoto(context, ref),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Change Photo'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _changeProfileName(context, ref, profileName),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Change Name'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('Cards'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                cardsAsync.when(
                  data: (cards) => _SettingsRow(
                    icon: Icons.credit_card_outlined,
                    title: 'Manage Cards',
                    subtitle:
                        '${cards.where((c) => c.isActive).length} active payment methods',
                    onTap: () => context.push('/cards'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => _SettingsRow(
                    icon: Icons.credit_card_outlined,
                    title: 'Manage Cards',
                    subtitle: 'Error loading cards',
                    onTap: () => context.push('/cards'),
                  ),
                ),
                _SettingsRow(
                  icon: Icons.sms_outlined,
                  title: 'SMS Format',
                  subtitle: 'Sample messages & parsing rules',
                  onTap: () => context.push('/cards'),
                ),
                _SettingsRow(
                  icon: Icons.sync,
                  title: 'Sync SMS now',
                  subtitle: 'Scan inbox for card transactions',
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Scanning SMS inbox…')),
                    );
                    final count = await ref
                        .read(smsListenerServiceProvider)
                        .syncInbox(forceFullWindow: true);
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          count == 0
                              ? 'No new card SMS found'
                              : 'Imported $count transaction(s) from SMS',
                        ),
                      ),
                    );
                  },
                ),
                _SettingsRow(
                  icon: Icons.block,
                  title: 'SMS ignore list',
                  subtitle: 'Paste full SMS samples to skip on sync',
                  onTap: () => context.push('/settings/sms-ignore'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('Categories'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                categoriesAsync.when(
                  data: (categories) => _SettingsRow(
                    icon: Icons.category_outlined,
                    title: 'Custom Categories',
                    subtitle: '${categories.length} total categories defined',
                    onTap: () => context.push('/categories'),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => _SettingsRow(
                    icon: Icons.category_outlined,
                    title: 'Custom Categories',
                    subtitle: 'Manage spend categories',
                    onTap: () => context.push('/categories'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('Thresholds & Notifications'),
            const SizedBox(height: 8),
            prefsAsync.when(
              data: (prefs) => _SettingsGroup(
                children: [
                  _SettingsRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'Spending Limits',
                    subtitle: 'Alert me at budget thresholds',
                    trailing: Text(
                      prefs.thresholdAlertsEnabled ? 'Active' : 'Off',
                      style: TextStyle(
                        color: prefs.thresholdAlertsEnabled
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await ref
                          .read(appPreferencesServiceProvider)
                          .setThresholdAlertsEnabled(
                            !prefs.thresholdAlertsEnabled,
                          );
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                  _SettingsToggleRow(
                    icon: Icons.mail_outline,
                    title: 'Bill Reminders',
                    subtitle: '${prefs.billLeadDays} days before bill date',
                    value: prefs.billReminderEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(appPreferencesServiceProvider)
                          .setBillReminderEnabled(value);
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                  _SettingsToggleRow(
                    icon: Icons.summarize_outlined,
                    title: 'Category Summaries',
                    subtitle: 'Push category spending updates',
                    value: prefs.summaryPushEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(appPreferencesServiceProvider)
                          .setSummaryPushEnabled(value);
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                ],
              ),
              error: (e, _) => Text('Error: $e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                const Expanded(child: EtLabelCaps('Needs Review')),
                reviewAsync.when(
                  data: (rows) {
                    if (rows.isEmpty) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Text(
                        '${rows.length} PENDING',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.assignment_late_outlined,
                  title: 'Uncategorized Transactions',
                  subtitle: 'Review SMS items that need attention',
                  onTap: () => context.push('/needs-review'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('App Preferences'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Theme',
                  subtitle: _themeLabel(themeMode),
                  onTap: () {
                    final next = switch (themeMode) {
                      ThemeMode.system => ThemeMode.light,
                      ThemeMode.light => ThemeMode.dark,
                      ThemeMode.dark => ThemeMode.system,
                    };
                    ref.read(themeModeProvider.notifier).state = next;
                  },
                ),
                _SettingsRow(
                  icon: Icons.language_outlined,
                  title: 'Currency & Region',
                  subtitle: 'PKR (Rs.)',
                  onTap: null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('Category Thresholds'),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (categories) => thresholdsAsync.when(
                data: (thresholds) => Column(
                  children: [
                    for (final c in categories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: EtSurfaceCard(
                          radius: AppRadii.card,
                          child: _ThresholdTile(
                            categoryId: c.id,
                            categoryName: c.name,
                            threshold: _findThreshold(thresholds, c.id),
                            onSave: (limit, percent) async {
                              final threshold =
                                  _findThreshold(thresholds, c.id) ??
                                      (CategoryThresholdModel()
                                        ..id = const Uuid().v4()
                                        ..categoryId = c.id);
                              threshold
                                ..monthlyLimit = limit
                                ..notifyAtPercent = percent;
                              await ref
                                  .read(categoryMutationsProvider)
                                  .upsertThreshold(threshold);
                              ref.invalidate(categoryThresholdStatusesProvider);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                error: (e, _) => Text('Error: $e'),
                loading: () => const LinearProgressIndicator(),
              ),
              error: (e, _) => Text('Error: $e'),
              loading: () => const LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}

Future<void> _changeProfilePhoto(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profile photo',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Remove photo',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(profileMutationsProvider).clear();
              },
            ),
          ],
        ),
      ),
    ),
  );

  if (source == null) return;
  await ref.read(profileMutationsProvider).pickAndSave(source: source);
}

Future<void> _changeProfileName(
  BuildContext context,
  WidgetRef ref,
  String currentName,
) async {
  final controller = TextEditingController(text: currentName);
  final value = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Change name'),
      content: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'Enter your name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  final next = value?.trim();
  if (next == null || next.isEmpty) return;
  await ref.read(profileMutationsProvider).setName(next);
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return EtSurfaceCard(
      radius: AppRadii.card,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 4),
            ],
            if (onTap != null)
              const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

CategoryThresholdModel? _findThreshold(
  List<CategoryThresholdModel> thresholds,
  String categoryId,
) {
  for (final item in thresholds) {
    if (item.categoryId == categoryId) return item;
  }
  return null;
}

class _ThresholdTile extends ConsumerStatefulWidget {
  const _ThresholdTile({
    required this.categoryId,
    required this.categoryName,
    required this.threshold,
    required this.onSave,
  });

  final String categoryId;
  final String categoryName;
  final CategoryThresholdModel? threshold;
  final Future<void> Function(double limit, int percent) onSave;

  @override
  ConsumerState<_ThresholdTile> createState() => _ThresholdTileState();
}

class _ThresholdTileState extends ConsumerState<_ThresholdTile> {
  late final TextEditingController _limitCtrl;
  late double _percent;

  @override
  void initState() {
    super.initState();
    _limitCtrl =
        TextEditingController(text: '${widget.threshold?.monthlyLimit ?? 0}');
    _percent = (widget.threshold?.notifyAtPercent ?? 80).toDouble();
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(categoryThresholdStatusesProvider);
    final status = statusAsync.maybeWhen(
      data: (rows) {
        for (final row in rows) {
          if (row.categoryId == widget.categoryId) return row;
        }
        return null;
      },
      orElse: () => null,
    );

    final barColor = status == null
        ? AppColors.primary
        : status.level == ThresholdLevel.exceeded
            ? AppColors.error
            : status.level == ThresholdLevel.warning
                ? AppColors.warning
                : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            EtCategoryBadge(category: widget.categoryName, size: 36, iconSize: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.categoryName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            if (status != null)
              Text(
                '${status.percentUsed.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: barColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        if (status != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (status.percentUsed / 100).clamp(0.0, 1.0),
              minHeight: 8,
              color: barColor,
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${EtMoney.format(status.spent)} of ${EtMoney.format(status.monthlyLimit)}',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _limitCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monthly limit',
                  isDense: true,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  'Alert ${_percent.toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Slider(
                    min: 50,
                    max: 100,
                    divisions: 10,
                    value: _percent,
                    onChanged: (value) => setState(() => _percent = value),
                  ),
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () async {
              final limit = double.tryParse(_limitCtrl.text.trim()) ?? 0;
              final messenger = ScaffoldMessenger.of(context);
              await widget.onSave(limit, _percent.toInt());
              messenger.showSnackBar(
                SnackBar(
                  content: Text('${widget.categoryName} threshold saved'),
                ),
              );
            },
            style: FilledButton.styleFrom(minimumSize: const Size(110, 40)),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}
