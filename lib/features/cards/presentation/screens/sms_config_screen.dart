import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/sms_parsing_rule_model.dart';
import '../../domain/sms_parser.dart';
import '../providers/cards_provider.dart';

class SmsConfigScreen extends ConsumerStatefulWidget {
  const SmsConfigScreen({required this.cardId, super.key});

  final String cardId;

  @override
  ConsumerState<SmsConfigScreen> createState() => _SmsConfigScreenState();
}

class _SmsConfigScreenState extends ConsumerState<SmsConfigScreen> {
  final _sampleCtrl = TextEditingController();
  final _amountPatternCtrl = TextEditingController();
  final _placePatternCtrl = TextEditingController();
  final _datePatternCtrl = TextEditingController();
  final _excludeCtrl = TextEditingController();
  final _previewCtrl = TextEditingController();
  String _previewOutput = '';
  SmsParsingRuleModel? _existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    final row = await ref.read(parsingRuleByCardProvider(widget.cardId).future);
    if (row == null || !mounted) {
      return;
    }
    setState(() {
      _existing = row;
      _sampleCtrl.text = row.sampleMessage;
      _amountPatternCtrl.text = row.amountPattern;
      _placePatternCtrl.text = row.placePattern;
      _datePatternCtrl.text = row.datePattern ?? '';
      _excludeCtrl.text = row.excludeKeywords.join(', ');
    });
  }

  void _autoSuggest() {
    final suggestion = SmsParser.suggestFromSample(_sampleCtrl.text);
    setState(() {
      _amountPatternCtrl.text = suggestion.amountPattern;
      _placePatternCtrl.text = suggestion.placePattern;
      _datePatternCtrl.text = suggestion.datePattern ?? '';
      // Clear merchant names mistakenly used as exclude keywords.
      final excludeLower = _excludeCtrl.text.toLowerCase();
      if (excludeLower.contains('shell') || excludeLower.contains('select')) {
        _excludeCtrl.text = 'OTP, offer, reminder, statement';
      }

      // Immediately verify sample against suggested patterns.
      final parsed = SmsParser.parse(
        smsBody: _sampleCtrl.text,
        amountPattern: suggestion.amountPattern,
        placePattern: suggestion.placePattern,
        datePattern: suggestion.datePattern,
        fallbackDate: DateTime.now(),
      );
      _previewCtrl.text = _sampleCtrl.text;
      _previewOutput = parsed == null
          ? SmsParser.explainFailure(
              smsBody: _sampleCtrl.text,
              amountPattern: suggestion.amountPattern,
            )
          : 'Sample OK\nAmount: ${parsed.amount}\nPlace: ${parsed.place}\nDate: ${parsed.transactionDate}';
    });
  }

  void _preview() {
    final body = _previewCtrl.text;
    final amountPattern = _amountPatternCtrl.text;
    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: amountPattern,
      placePattern: _placePatternCtrl.text,
      datePattern: _datePatternCtrl.text.trim().isEmpty ? null : _datePatternCtrl.text.trim(),
      fallbackDate: DateTime.now(),
    );
    setState(() {
      if (parsed == null) {
        _previewOutput = SmsParser.explainFailure(
          smsBody: body,
          amountPattern: amountPattern,
        );
      } else {
        _previewOutput =
            'Amount: ${parsed.amount}\nPlace: ${parsed.place}\nDate: ${parsed.transactionDate}';
      }
    });
  }

  Future<void> _save() async {
    // If patterns are empty, auto-suggest before saving.
    if (_amountPatternCtrl.text.trim().isEmpty ||
        _placePatternCtrl.text.trim().isEmpty) {
      _autoSuggest();
    }

    final model = _existing ?? SmsParsingRuleModel();
    model
      ..cardId = widget.cardId
      ..sampleMessage = _sampleCtrl.text.trim()
      ..amountPattern = _amountPatternCtrl.text.trim()
      ..placePattern = _placePatternCtrl.text.trim()
      ..datePattern = _datePatternCtrl.text.trim().isEmpty ? null : _datePatternCtrl.text.trim()
      ..excludeKeywords = _excludeCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    await ref.read(cardMutationsProvider).saveRule(model);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure SMS Format')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Paste one real bank SMS for this card. The app will learn the format and auto-detect future expenses from the same sender.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sampleCtrl,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Sample SMS Message',
              hintText: 'Paste full bank SMS here exactly as received',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: _autoSuggest,
            child: const Text('Auto-suggest Regex from Sample'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountPatternCtrl,
            decoration: const InputDecoration(labelText: 'Amount Pattern'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _placePatternCtrl,
            decoration: const InputDecoration(labelText: 'Place Pattern'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _datePatternCtrl,
            decoration: const InputDecoration(labelText: 'Date Pattern (optional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _excludeCtrl,
            decoration: const InputDecoration(
              labelText: 'Exclude Keywords (comma-separated)',
              helperText: 'e.g. OTP, offer, reminder, statement',
            ),
          ),
          const Divider(height: 24),
          const Text('Live test'),
          const SizedBox(height: 8),
          TextField(
            controller: _previewCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Paste another SMS to test',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _preview,
            child: const Text('Test Extraction'),
          ),
          if (_previewOutput.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(_previewOutput),
          ],
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Save SMS Format')),
        ],
      ),
    );
  }
}
