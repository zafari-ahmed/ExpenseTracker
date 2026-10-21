import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/services/data_refresh.dart';
import '../../../../core/services/reviewer_demo_service.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/services/sms_listener_service.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/period_range.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../onboarding/presentation/widgets/how_to_sheet.dart';
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final cardsAsync = ref.watch(cardsListProvider);
    final reviewAsync = ref.watch(needsReviewProvider);
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
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                'Setup',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            EtSurfaceCard(
              onTap: () => _changeProfileName(context, ref, profileName),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeProfilePhoto(context, ref),
                    child: const EtAvatar(size: 42),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const EtLabelCaps('LOCAL ONLY · NO ACCOUNT'),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const EtLabelCaps('Help'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.menu_book_outlined,
                  title: 'How to use',
                  subtitle: 'Add a card, sender ID, sample SMS, then sync',
                  onTap: () => showHowToSheet(context, ref, markSeen: true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('SMS & DATA'),
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
                    final result = await ref
                        .read(smsListenerServiceProvider)
                        .syncInbox(forceFullWindow: true);
                    if (!context.mounted) return;
                    await _showSmsSyncAlert(context, result);
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
                    icon: Icons.tune_outlined,
                    title: 'Category thresholds',
                    subtitle: 'Set monthly limits per category',
                    onTap: () => context.push('/settings/thresholds'),
                  ),
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
                    icon: Icons.receipt_long_outlined,
                    title: 'Expense alerts',
                    subtitle: 'Notify when SMS expense is saved',
                    value: prefs.expenseAddedNotificationsEnabled,
                    onChanged: (value) async {
                      await ref
                          .read(appPreferencesServiceProvider)
                          .setExpenseAddedNotificationsEnabled(value);
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
                ref.watch(spendPeriodModeProvider).when(
                  data: (mode) => _SettingsRow(
                    icon: Icons.date_range_outlined,
                    title: 'Spend period',
                    subtitle: mode == SpendPeriodMode.billingCycle
                        ? 'Billing cycle (from each card bill date)'
                        : 'Calendar month',
                    trailing: Text(
                      mode == SpendPeriodMode.billingCycle
                          ? 'Billing'
                          : 'Monthly',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      final next = mode == SpendPeriodMode.monthly
                          ? SpendPeriodMode.billingCycle
                          : SpendPeriodMode.monthly;
                      await ref
                          .read(appPreferencesServiceProvider)
                          .setSpendPeriodMode(next);
                      ref.invalidate(spendPeriodModeProvider);
                      ref.invalidate(categoryThresholdStatusesProvider);
                      ref.invalidate(thisMonthTotalProvider);
                    },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => const _SettingsRow(
                    icon: Icons.date_range_outlined,
                    title: 'Spend period',
                    subtitle: 'Error loading preference',
                    onTap: null,
                  ),
                ),
                ref.watch(currencyProvider).when(
                  data: (currency) => _SettingsRow(
                    icon: Icons.payments_outlined,
                    title: 'Currency',
                    subtitle: '${currency.name} · ${currency.code}',
                    trailing: Text(
                      currency.code,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _pickCurrency(context, ref, currency),
                  ),
                  loading: () => const _SettingsRow(
                    icon: Icons.payments_outlined,
                    title: 'Currency',
                    subtitle: 'Loading…',
                    onTap: null,
                  ),
                  error: (_, __) => _SettingsRow(
                    icon: Icons.payments_outlined,
                    title: 'Currency',
                    subtitle: 'Tap to choose',
                    onTap: () => _pickCurrency(
                      context,
                      ref,
                      AppCurrency.pkr,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('SMS money management'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.sms_outlined,
                  title: 'Try a sample debit SMS',
                  subtitle:
                      'Parse a sample bank debit message into an expense (for review if this phone has no bank SMS)',
                  onTap: () => _trySampleSms(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            const EtLabelCaps('Backup & data'),
            const SizedBox(height: 8),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.file_upload_outlined,
                  title: 'Export backup',
                  subtitle: 'Save cards and transactions to a file',
                  onTap: () => _exportBackup(context, ref),
                ),
                _SettingsRow(
                  icon: Icons.file_download_outlined,
                  title: 'Import backup',
                  subtitle: 'Replace data on this install from a file',
                  onTap: () => _importBackup(context, ref),
                ),
                _SettingsRow(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete local data',
                  subtitle: 'Remove transactions stored on this phone',
                  onTap: () => _deleteLocalData(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}

Future<void> _showSmsSyncAlert(
  BuildContext context,
  SmsSyncResult result,
) async {
  if (result.skipped) {
    await etInfoAlert(
      context,
      title: 'SMS sync',
      message: 'A sync is already running. Try again in a moment.',
    );
    return;
  }
  if (!result.granted) {
    await etInfoAlert(
      context,
      title: 'SMS permission needed',
      message: 'Allow SMS access to fetch inbox messages from your cards.',
    );
    return;
  }

  final from = result.from;
  final to = result.to;
  final dateLine = from == null || to == null
      ? 'Fetched inbox SMS.'
      : 'Fetched SMS from ${_formatSyncDay(from)} to ${_formatSyncDay(to)}.';
  final countLine = result.createdCount == 0
      ? 'No new card expenses found.'
      : 'Imported ${result.createdCount} new expense(s).';

  await etInfoAlert(
    context,
    title: 'SMS sync complete',
    message: '$dateLine\n\n$countLine',
  );
}

String _formatSyncDay(DateTime value) {
  return DateFormat('d MMM yyyy').format(value);
}

Future<void> _pickCurrency(
  BuildContext context,
  WidgetRef ref,
  AppCurrency current,
) async {
  final selected = await showModalBottomSheet<AppCurrency>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.62;
      return SafeArea(
        child: SizedBox(
          height: maxHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Display currency',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Changes the symbol shown in the app. Amounts are not converted.',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: AppCurrency.all.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.hairline),
                    itemBuilder: (context, index) {
                      final item = AppCurrency.all[index];
                      final selected = item.code == current.code;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${item.code} · ${item.symbol.trim()}'),
                        trailing: selected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(ctx, item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (selected == null) return;
  await ref.read(appPreferencesServiceProvider).setCurrencyCode(selected.code);
  CurrencyStore.current = selected;
  ref.invalidate(currencyProvider);
}

Future<void> _trySampleSms(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final created = await ReviewerDemoService(ref).importSampleDebitSms();
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          created
              ? 'Sample bank debit SMS parsed: FOODPANDA Rs. 1,250'
              : 'That sample SMS is already in your transactions.',
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Could not parse sample SMS: $e')),
    );
  }
}

Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final backup = await ref.read(backupServiceProvider.future);
    final file = await backup.exportToTempFile();
    if (!context.mounted) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Expense Tracker backup',
      text: 'Keep this file. Updating the app in place does not need it; uninstalling or changing package name does.',
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Export failed: $e')),
    );
  }
}

Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Replace all local data?'),
      content: const Text(
        'Importing a backup overwrites cards, transactions, and settings on this install. Export first if you are unsure. Do not import just to update the APK — install over the existing app instead.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Choose file'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (!context.mounted) return;
  final path = picked?.files.single.path;
  if (path == null) return;

  final messenger = ScaffoldMessenger.of(context);
  try {
    final backup = await ref.read(backupServiceProvider.future);
    final result = await backup.importFromFile(File(path));
    invalidateLocalDataProviders(ref);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${result.transactionCount} transaction(s) and ${result.cardCount} card(s)',
        ),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Import failed: $e')),
    );
  }
}

Future<void> _deleteLocalData(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete all local data?'),
      content: const Text(
        'This permanently deletes transactions, cards, and settings on this phone. Export a backup first. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final messenger = ScaffoldMessenger.of(context);
  final backup = await ref.read(backupServiceProvider.future);
  await backup.deleteAllLocalData();
  invalidateLocalDataProviders(ref);
  messenger.showSnackBar(
    const SnackBar(content: Text('Local data deleted')),
  );
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
  if (source == ImageSource.camera) {
    final allowed =
        await ref.read(permissionServiceProvider).requestCamera();
    if (!allowed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to take a photo')),
        );
      }
      return;
    }
  }
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
          style: TextButton.styleFrom(
            minimumSize: const Size(88, 44),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(88, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
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
              const Divider(height: 1, color: AppColors.hairline),
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
            Icon(icon, color: AppColors.body, size: 20),
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
          Icon(icon, color: AppColors.body, size: 20),
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

