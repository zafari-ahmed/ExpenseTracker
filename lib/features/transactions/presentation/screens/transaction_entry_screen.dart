import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cards/domain/sms_parser.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../providers/transactions_provider.dart';

class TransactionEntryScreen extends ConsumerStatefulWidget {
  const TransactionEntryScreen({super.key});

  @override
  ConsumerState<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends ConsumerState<TransactionEntryScreen> {
  final _smsCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _cardId;
  DateTime _date = DateTime.now();
  String _parseHint = '';
  bool _parsedFromSms = false;

  @override
  void dispose() {
    _smsCtrl.dispose();
    _amountCtrl.dispose();
    _placeCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _parsePastedSms() async {
    final body = _smsCtrl.text.trim();
    if (body.isEmpty) {
      setState(() => _parseHint = 'Paste a bank SMS first.');
      return;
    }
    if (_cardId == null) {
      setState(() => _parseHint = 'Select a card first so we can use its SMS format (if configured).');
      return;
    }

    final rule = await ref.read(parsingRuleByCardProvider(_cardId!).future);
    // Prefer fresh HBL/auto suggestion for place accuracy; keep saved amount/date if present.
    final suggestion = SmsParser.suggestFromSample(body);

    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: rule?.amountPattern.isNotEmpty == true
          ? rule!.amountPattern
          : suggestion.amountPattern,
      placePattern: suggestion.placePattern,
      datePattern: (rule?.datePattern?.isNotEmpty ?? false)
          ? rule!.datePattern
          : suggestion.datePattern,
      fallbackDate: DateTime.now(),
    );

    if (parsed == null) {
      setState(() {
        _parsedFromSms = false;
        _parseHint = rule == null
            ? 'Could not auto-extract fields. Configure this card\'s SMS sample in Settings → Manage Cards → Configure SMS Format, or fill amount/place manually.'
            : 'Could not match this SMS with the saved format. Check Configure SMS Format for this card, or edit fields manually.';
      });
      return;
    }

    setState(() {
      _amountCtrl.text = parsed.amount.toStringAsFixed(
        parsed.amount.truncateToDouble() == parsed.amount ? 0 : 2,
      );
      _placeCtrl.text = parsed.place;
      _date = parsed.transactionDate;
      _parsedFromSms = true;
      _parseHint = rule == null
          ? 'Extracted using auto-detect. Tip: save a sample SMS for this card so future messages parse more reliably.'
          : 'Extracted using this card\'s saved SMS format.';
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (_cardId == null || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a card and enter a valid amount.')),
      );
      return;
    }
    await ref.read(transactionMutationsProvider).addManual(
          cardId: _cardId!,
          amount: amount,
          place: _placeCtrl.text.trim().isEmpty ? 'Unknown' : _placeCtrl.text.trim(),
          description: _descriptionCtrl.text.trim(),
          date: _date,
          rawSmsBody: _smsCtrl.text.trim(),
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _openSmsConfigIfNeeded() async {
    if (_cardId == null) {
      return;
    }
    await context.push('/cards/sms-config?cardId=$_cardId');
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(activeCardsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            cardsAsync.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('No cards yet. Add a card first.'),
                      TextButton(
                        onPressed: () => context.push('/cards/form'),
                        child: const Text('Add Card'),
                      ),
                    ],
                  );
                }
                return DropdownButtonFormField<String>(
                  initialValue: _cardId,
                  hint: const Text('Select card'),
                  items: cards
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.cardName)))
                      .toList(),
                  onChanged: (value) => setState(() => _cardId = value),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 16),
            Text(
              'Paste bank SMS (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Paste the full message exactly as received. We will try to extract amount, place, and date.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _smsCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Bank SMS message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _parsePastedSms,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Extract from SMS'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Configure SMS format for this card',
                  onPressed: _cardId == null ? null : _openSmsConfigIfNeeded,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            if (_parseHint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _parseHint,
                style: TextStyle(
                  color: _parsedFromSms
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const Divider(height: 32),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _placeCtrl,
              decoration: const InputDecoration(
                labelText: 'Place / Merchant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Transaction Date'),
              subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.calendar_month_outlined),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
