import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/preferences_provider.dart';
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
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descriptionCtrl;
  String? _category;
  bool _saving = false;
  bool _rememberForFuture = true;

  @override
  void initState() {
    super.initState();
    _placeCtrl = TextEditingController(text: widget.transaction.place);
    _amountCtrl = TextEditingController(text: _formatAmountInput(widget.transaction.amount));
    _descriptionCtrl =
        TextEditingController(text: widget.transaction.description);
    _category = widget.transaction.category;
    _placeCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  String _formatAmountInput(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }
    return amount.toString();
  }

  double? _parseAmount(String raw) {
    final cleaned = raw.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  bool get _hasSms {
    final body = widget.transaction.rawSmsBody.trim();
    return body.isNotEmpty;
  }

  String _sourceLabel(TransactionSource source) {
    switch (source) {
      case TransactionSource.sms:
        return 'SMS · auto';
      case TransactionSource.smsEdited:
        return 'SMS · edited';
      case TransactionSource.notification:
        return 'Notification · auto';
      case TransactionSource.notificationEdited:
        return 'Notification · edited';
      case TransactionSource.manual:
        return 'Manual';
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final place = _placeCtrl.text.trim();
    final description = _descriptionCtrl.text.trim();
    final category = _category ?? 'Uncategorized';
    final amount = _parseAmount(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    final transactionId = widget.transaction.id;

    if (mounted) Navigator.of(context).pop();

    await Future<void>.delayed(Duration.zero);
    await ref.read(transactionMutationsProvider).updateDetails(
          transactionId: transactionId,
          place: place,
          description: description,
          category: category,
          amount: amount,
          rememberForFuture: _rememberForFuture,
        );
  }

  Future<void> _delete() async {
    final confirmed = await etConfirmDelete(
      context,
      title: 'Delete transaction?',
      message: 'This permanently deletes the expense.',
    );
    if (confirmed != true || !mounted) return;
    final id = widget.transaction.id;
    Navigator.of(context).pop();
    await ref.read(transactionMutationsProvider).delete(id);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currencyProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final cards = ref.watch(cardsListProvider).valueOrNull ?? const <CardModel>[];
    final smsBody = widget.transaction.rawSmsBody.trim();
    CardModel? matched;
    for (final c in cards) {
      if (c.id == widget.transaction.cardId) matched = c;
    }
    final account = matched == null
        ? 'Account'
        : '${matched.bankName} ····${matched.lastFourDigits ?? '----'}';
    final dateFormat = EtTxnTime.hasClock(widget.transaction.transactionDate)
        ? DateFormat('d MMM yyyy · HH:mm')
        : DateFormat('d MMM yyyy');
    final date = dateFormat.format(widget.transaction.transactionDate).toUpperCase();

    return Material(
      color: AppColors.background,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              EtCategoryBadge(
                category: widget.transaction.category,
                size: 44,
                iconSize: 24,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    CurrencyStore.current.symbol.trim(),
                    style: GoogleFonts.archivo(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: GoogleFonts.archivo(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                        height: 1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: const InputDecoration(
                        hintText: '0',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.soft,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _placeCtrl,
                      style: GoogleFonts.archivo(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Merchant',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.soft,
                  ),
                ],
              ),
              EtLabelCaps(date),
              const SizedBox(height: 14),
              EtSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _MetaRow(
                      label: 'CATEGORY',
                      child: categoriesAsync.when(
                        data: (cats) {
                          final names = cats.map((c) => c.name).toList();
                          if (_category != null &&
                              _category!.isNotEmpty &&
                              !names.contains(_category)) {
                            names.insert(0, _category!);
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: names.contains(_category) ? _category : null,
                              isDense: true,
                              items: names
                                  .map(
                                    (name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _category = value),
                            ),
                          );
                        },
                        error: (e, _) => Text('$e'),
                        loading: () => const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.hairline),
                    _MetaRow(
                      label: 'ACCOUNT',
                      child: Text(
                        account,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.hairline),
                    _MetaRow(
                      label: 'SOURCE',
                      child: Text(
                        _sourceLabel(widget.transaction.source),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_hasSms)
                EtSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          EtLabelCaps(
                            widget.transaction.source.fromNotification
                                ? 'SOURCE ALERT'
                                : 'SOURCE MESSAGE',
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: widget.transaction.source ==
                                          TransactionSource.smsEdited ||
                                      widget.transaction.source ==
                                          TransactionSource.notificationEdited
                                  ? AppColors.amberTint
                                  : AppColors.greenTint,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: EtLabelCaps(
                              widget.transaction.source ==
                                          TransactionSource.smsEdited ||
                                      widget.transaction.source ==
                                          TransactionSource.notificationEdited
                                  ? 'EDITED'
                                  : 'AUTO-PARSED',
                              color: widget.transaction.source ==
                                          TransactionSource.smsEdited ||
                                      widget.transaction.source ==
                                          TransactionSource.notificationEdited
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SelectableText(
                          smsBody,
                          style: GoogleFonts.ibmPlexMono(
                            fontSize: 12,
                            height: 1.65,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      if (widget.transaction.source.fromSms) ...[
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            if (widget.transaction.cardId.isEmpty) return;
                            Navigator.pop(context);
                            context.push(
                              '/cards/sms-config?cardId=${widget.transaction.cardId}',
                            );
                          },
                          child: const EtLabelCaps(
                            'FIX HOW THIS SENDER IS READ →',
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                TextField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _rememberForFuture,
                onChanged: (value) =>
                    setState(() => _rememberForFuture = value ?? true),
                title: const Text('Remember for future transactions'),
                subtitle: Text(
                  _placeCtrl.text.trim().isEmpty
                      ? 'Saves this place → category for new SMS'
                      : 'Future "${_placeCtrl.text.trim()}" SMS go to ${_category ?? 'category'}',
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          EtLabelCaps(label),
          const Spacer(),
          Flexible(child: child),
        ],
      ),
    );
  }
}
