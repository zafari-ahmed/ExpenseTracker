import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/design_tokens.dart';
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
  final _amountValueCtrl = TextEditingController();
  final _placeValueCtrl = TextEditingController();
  final _dateValueCtrl = TextEditingController();
  final _amountPatternCtrl = TextEditingController();
  final _placePatternCtrl = TextEditingController();
  final _datePatternCtrl = TextEditingController();
  final _excludeCtrl = TextEditingController();
  final _previewCtrl = TextEditingController();
  String _previewOutput = '';
  String _guideStatus = '';
  SmsParsingRuleModel? _existing;

  @override
  void initState() {
    super.initState();
    _excludeCtrl.text = SmsParser.defaultIgnorePhrases.take(6).join(', ');
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  @override
  void dispose() {
    _sampleCtrl.dispose();
    _amountValueCtrl.dispose();
    _placeValueCtrl.dispose();
    _dateValueCtrl.dispose();
    _amountPatternCtrl.dispose();
    _placePatternCtrl.dispose();
    _datePatternCtrl.dispose();
    _excludeCtrl.dispose();
    _previewCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final row = await ref.read(parsingRuleByCardProvider(widget.cardId).future);
    if (row == null || !mounted) return;

    setState(() {
      _existing = row;
      _sampleCtrl.text = row.sampleMessage;
      _amountPatternCtrl.text = row.amountPattern;
      _placePatternCtrl.text = row.placePattern;
      _datePatternCtrl.text = row.datePattern ?? '';
      if (row.excludeKeywords.isNotEmpty) {
        _excludeCtrl.text = row.excludeKeywords.join(', ');
      }
      _previewCtrl.text = row.sampleMessage;
    });

    // Prefill amount/place/date fields by parsing the saved sample.
    if (row.sampleMessage.trim().isNotEmpty) {
      final parsed = SmsParser.parse(
        smsBody: row.sampleMessage,
        amountPattern: row.amountPattern,
        placePattern: row.placePattern,
        datePattern: row.datePattern,
        fallbackDate: DateTime.now(),
      );
      if (parsed != null && mounted) {
        setState(() {
          _amountValueCtrl.text = parsed.amount.toString();
          _placeValueCtrl.text = parsed.place;
          _dateValueCtrl.text =
              '${parsed.transactionDate.day.toString().padLeft(2, '0')}/'
              '${parsed.transactionDate.month.toString().padLeft(2, '0')}/'
              '${parsed.transactionDate.year}';
        });
      }
    }
  }

  void _generateFromValues() {
    final sample = _sampleCtrl.text.trim();
    final amount = _amountValueCtrl.text.trim();
    final place = _placeValueCtrl.text.trim();
    final date = _dateValueCtrl.text.trim();

    if (sample.isEmpty) {
      setState(() => _guideStatus = 'Paste the full bank SMS in the sample box first.');
      return;
    }
    if (amount.isEmpty || place.isEmpty) {
      setState(() {
        _guideStatus =
            'Fill Amount and Place exactly as they appear in the sample SMS.';
      });
      return;
    }

    final suggestion = SmsParser.buildFromFieldValues(
      sampleMessage: sample,
      amountValue: amount,
      placeValue: place,
      dateValue: date.isEmpty ? null : date,
    );

    if (suggestion == null) {
      setState(() {
        _guideStatus =
            'Could not find that Amount or Place inside the sample. Copy the text exactly from the SMS (including commas/spaces).';
      });
      return;
    }

    setState(() {
      _amountPatternCtrl.text = suggestion.amountPattern;
      _placePatternCtrl.text = suggestion.placePattern;
      _datePatternCtrl.text = suggestion.datePattern ?? '';
      _previewCtrl.text = sample;
      _guideStatus = 'Patterns created. Tap “Test extraction” to verify.';
    });
    _preview();
  }

  void _autoSuggest() {
    final suggestion = SmsParser.suggestFromSample(_sampleCtrl.text);
    setState(() {
      _amountPatternCtrl.text = suggestion.amountPattern;
      _placePatternCtrl.text = suggestion.placePattern;
      _datePatternCtrl.text = suggestion.datePattern ?? '';
      _previewCtrl.text = _sampleCtrl.text;
      _guideStatus = 'Tried auto-detect. Prefer “Generate from values” if this fails.';
    });
    _preview();
  }

  void _preview() {
    final body = _previewCtrl.text.trim().isEmpty
        ? _sampleCtrl.text
        : _previewCtrl.text;
    final amountPattern = _amountPatternCtrl.text;
    if (amountPattern.trim().isEmpty || _placePatternCtrl.text.trim().isEmpty) {
      setState(() {
        _previewOutput =
            'Generate patterns first (fill Amount + Place, then tap Generate).';
      });
      return;
    }

    final parsed = SmsParser.parse(
      smsBody: body,
      amountPattern: amountPattern,
      placePattern: _placePatternCtrl.text,
      datePattern: _datePatternCtrl.text.trim().isEmpty
          ? null
          : _datePatternCtrl.text.trim(),
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
            'OK\nAmount: ${parsed.amount}\nPlace: ${parsed.place}\nDate: ${parsed.transactionDate.toString().split(' ').first}';
      }
    });
  }

  Future<void> _save() async {
    if (_amountPatternCtrl.text.trim().isEmpty ||
        _placePatternCtrl.text.trim().isEmpty) {
      _generateFromValues();
      if (_amountPatternCtrl.text.trim().isEmpty ||
          _placePatternCtrl.text.trim().isEmpty) {
        return;
      }
    }

    final model = _existing ?? SmsParsingRuleModel();
    model
      ..cardId = widget.cardId
      ..sampleMessage = _sampleCtrl.text.trim()
      ..amountPattern = _amountPatternCtrl.text.trim()
      ..placePattern = _placePatternCtrl.text.trim()
      ..datePattern = _datePatternCtrl.text.trim().isEmpty
          ? null
          : _datePatternCtrl.text.trim()
      ..excludeKeywords = _excludeCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    await ref.read(cardMutationsProvider).saveRule(model);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final helperStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          height: 1.35,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configure SMS Format'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'No regex needed. Paste one real bank SMS, then copy the amount, place, and date from that same message into the boxes below.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _sampleCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: '1. Sample SMS message',
              hintText: 'Paste the full bank SMS here exactly as received',
              helperText: 'Use one real expense SMS for this card / sender.',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '2. Copy values from the sample',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type or paste the same text that appears in the SMS above.',
            style: helperStyle,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountValueCtrl,
            decoration: const InputDecoration(
              labelText: 'Amount (from sample)',
              hintText: 'e.g. 1,811.00 or 1,802.00 or 1020.00',
              helperText:
                  'Only the number, as written in the SMS (commas/decimals OK). Currency optional.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _placeValueCtrl,
            decoration: const InputDecoration(
              labelText: 'Place / merchant (from sample)',
              hintText: 'e.g. KFC - JAUHAR KARACHI PAK',
              helperText:
                  'Merchant name exactly as shown (including dashes/spaces).',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dateValueCtrl,
            decoration: const InputDecoration(
              labelText: 'Date (from sample, optional)',
              hintText: 'e.g. 24-07-26 or 25/Jul/2026',
              helperText:
                  'Copy the date text from the SMS. Leave blank if there is no date.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _generateFromValues,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate from values'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _autoSuggest,
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: const Text('Try auto-detect (optional)'),
          ),
          if (_guideStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _guideStatus,
              style: helperStyle?.copyWith(color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            '3. Test extraction',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _previewCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'SMS to test',
              hintText: 'Uses your sample by default — or paste another SMS',
              helperText: 'Check that amount, place, and date look correct.',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _preview,
            child: const Text('Test extraction'),
          ),
          if (_previewOutput.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_previewOutput, style: const TextStyle(height: 1.4)),
            ),
          ],
          const SizedBox(height: 16),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Advanced (optional)'),
            subtitle: Text(
              'Generated patterns & exclude keywords',
              style: helperStyle,
            ),
            children: [
              TextField(
                controller: _amountPatternCtrl,
                decoration: const InputDecoration(
                  labelText: 'Amount pattern',
                  helperText: 'Auto-filled — edit only if you know regex.',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _placePatternCtrl,
                decoration: const InputDecoration(
                  labelText: 'Place pattern',
                  helperText: 'Auto-filled — edit only if you know regex.',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _datePatternCtrl,
                decoration: const InputDecoration(
                  labelText: 'Date pattern (optional)',
                  helperText: 'Auto-filled when you provide a date value.',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _excludeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Exclude keywords (comma-separated)',
                  helperText: 'e.g. OTP, offer, reminder, statement',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _save,
            child: const Text('Save SMS format'),
          ),
        ],
      ),
    );
  }
}
