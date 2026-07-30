import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../providers/sms_ignore_provider.dart';

class SmsIgnoreListScreen extends ConsumerStatefulWidget {
  const SmsIgnoreListScreen({super.key});

  @override
  ConsumerState<SmsIgnoreListScreen> createState() =>
      _SmsIgnoreListScreenState();
}

class _SmsIgnoreListScreenState extends ConsumerState<SmsIgnoreListScreen> {
  final _sampleCtrl = TextEditingController();
  bool _saving = false;
  bool _showBuiltIn = false;

  @override
  void dispose() {
    _sampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSample() async {
    final text = _sampleCtrl.text.trim();
    if (text.isEmpty || _saving) return;

    setState(() => _saving = true);
    final added = await ref.read(smsIgnoreMutationsProvider).add(text);
    if (!mounted) return;

    setState(() => _saving = false);
    if (added) {
      _sampleCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to SMS ignore list')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That sample is already in the list')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customAsync = ref.watch(smsIgnoreListProvider);
    final activeDefaultsAsync = ref.watch(activeDefaultSmsIgnoreListProvider);
    final disabledDefaultsAsync = ref.watch(disabledDefaultSmsIgnoreListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SMS ignore list'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.margin,
          8,
          AppSpacing.margin,
          32,
        ),
        children: [
          Text(
            'Paste a full bank SMS (or a short phrase). Future syncs will skip any message that contains this text.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          EtSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _sampleCtrl,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'SMS sample or phrase',
                    alignLabelWithHint: true,
                    hintText:
                        'e.g. PKR 130,000 received from Asad\nor: is your OTP for online transaction',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _addSample,
                    icon: const Icon(Icons.playlist_add_check),
                    label: Text(_saving ? 'Saving…' : 'Add to ignore list'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          const EtLabelCaps('Your ignore samples'),
          const SizedBox(height: 8),
          customAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return EtSurfaceCard(
                  child: Text(
                    'No custom samples yet. Paste an unwanted SMS above and tap Add.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                );
              }
              return EtSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                        title: Text(
                          entries[i],
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(height: 1.35),
                        ),
                        trailing: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          color: AppColors.error,
                          onPressed: () async {
                            await ref
                                .read(smsIgnoreMutationsProvider)
                                .remove(entries[i]);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Removed from ignore list'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: AppSpacing.section),
          const EtLabelCaps('Built-in filters'),
          const SizedBox(height: 8),
          activeDefaultsAsync.when(
            data: (activeDefaults) {
              return EtSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                      title: const Text('Default OTP & credit filters'),
                      subtitle: Text(
                        _showBuiltIn
                            ? 'Tap delete to disable any default phrase.'
                            : '${activeDefaults.length} active by default',
                      ),
                      trailing: TextButton(
                        onPressed: () =>
                            setState(() => _showBuiltIn = !_showBuiltIn),
                        child: Text(_showBuiltIn ? 'Hide' : 'Show'),
                      ),
                    ),
                    if (_showBuiltIn) ...[
                      const Divider(height: 1),
                      if (activeDefaults.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            'No default phrases are active right now.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                        )
                      else
                        for (var i = 0; i < activeDefaults.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            contentPadding:
                                const EdgeInsets.fromLTRB(14, 8, 4, 8),
                            title: Text(activeDefaults[i]),
                            trailing: IconButton(
                              tooltip: 'Disable default phrase',
                              icon: const Icon(Icons.delete_outline),
                              color: AppColors.error,
                              onPressed: () async {
                                final removed = await ref
                                    .read(smsIgnoreMutationsProvider)
                                    .disableDefault(activeDefaults[i]);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      removed
                                          ? 'Default phrase disabled'
                                          : 'Already disabled',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 10),
          disabledDefaultsAsync.when(
            data: (disabledDefaults) {
              if (disabledDefaults.isEmpty) return const SizedBox.shrink();
              return EtSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disabled default phrases',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < disabledDefaults.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        title: Text(disabledDefaults[i]),
                        trailing: TextButton(
                          onPressed: () async {
                            await ref
                                .read(smsIgnoreMutationsProvider)
                                .restoreDefault(disabledDefaults[i]);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Default phrase restored'),
                              ),
                            );
                          },
                          child: const Text('Restore'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
