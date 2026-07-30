import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../categories/presentation/providers/categories_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';

class TransactionEditSheet extends ConsumerStatefulWidget {
  const TransactionEditSheet({required this.transaction, super.key});

  final TransactionModel transaction;

  @override
  ConsumerState<TransactionEditSheet> createState() =>
      _TransactionEditSheetState();
}

class _TransactionEditSheetState extends ConsumerState<TransactionEditSheet> {
  late final TextEditingController _placeCtrl;
  late final TextEditingController _descriptionCtrl;
  String? _category;
  bool _saving = false;
  bool _smsExpanded = false;

  @override
  void initState() {
    super.initState();
    _placeCtrl = TextEditingController(text: widget.transaction.place);
    _descriptionCtrl =
        TextEditingController(text: widget.transaction.description);
    _category = widget.transaction.category;
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  bool get _hasSms {
    final body = widget.transaction.rawSmsBody.trim();
    return body.isNotEmpty;
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);

    final place = _placeCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final category = _category ?? 'Uncategorized';
    final transactionId = widget.transaction.id;

    // Close sheet first to avoid navigator lock during provider refresh.
    if (mounted) {
      Navigator.of(context).pop();
    }

    await Future<void>.delayed(Duration.zero);
    await ref.read(transactionMutationsProvider).updateDetails(
          transactionId: transactionId,
          place: place,
          description: description,
          category: category,
        );
  }

  Future<void> _showFullSms() async {
    final body = widget.transaction.rawSmsBody.trim();
    if (body.isEmpty || !mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Original SMS'),
        content: SingleChildScrollView(
          child: SelectableText(
            body,
            style: const TextStyle(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: body));
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('SMS copied')),
                );
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
    final categoriesAsync = ref.watch(categoriesProvider);
    final smsBody = widget.transaction.rawSmsBody.trim();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Transaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('Amount (locked): ${money.format(widget.transaction.amount)}'),
            if (_hasSms) ...[
              const SizedBox(height: 12),
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.sms_outlined,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.transaction.source == TransactionSource.sms
                                  ? 'Original bank SMS'
                                  : 'Linked SMS / note',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: _showFullSms,
                            child: const Text('View full'),
                          ),
                        ],
                      ),
                      Text(
                        _smsExpanded
                            ? smsBody
                            : (smsBody.length > 140
                                ? '${smsBody.substring(0, 140)}…'
                                : smsBody),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                            ),
                      ),
                      if (smsBody.length > 140)
                        TextButton(
                          onPressed: () =>
                              setState(() => _smsExpanded = !_smsExpanded),
                          child: Text(_smsExpanded ? 'Show less' : 'Show more'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _placeCtrl,
              decoration: const InputDecoration(labelText: 'Place'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (cats) {
                final names = cats.map((c) => c.name).toList();
                if (_category != null &&
                    _category!.isNotEmpty &&
                    !names.contains(_category)) {
                  names.insert(0, _category!);
                }
                return DropdownButtonFormField<String>(
                  key: ValueKey(_category),
                  initialValue: _category,
                  items: names
                      .map(
                        (name) =>
                            DropdownMenuItem(value: name, child: Text(name)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value),
                  decoration: const InputDecoration(labelText: 'Category'),
                );
              },
              error: (e, s) => Text('Error: $e'),
              loading: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
