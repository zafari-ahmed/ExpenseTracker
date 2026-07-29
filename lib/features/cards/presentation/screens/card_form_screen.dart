import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../data/models/card_model.dart';
import '../providers/cards_provider.dart';

class CardFormScreen extends ConsumerStatefulWidget {
  const CardFormScreen({required this.cardId, super.key});

  final String? cardId;

  @override
  ConsumerState<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends ConsumerState<CardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _last4Ctrl = TextEditingController();
  final _senderCtrl = TextEditingController();
  int _billDate = 10;
  bool _isActive = true;
  int _themeIndex = 0;
  int _iconIndex = 0;
  CardModel? _editing;

  static const _icons = [
    Icons.account_balance_outlined,
    Icons.savings_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.payments_outlined,
  ];

  static const _iconKeys = [
    'account_balance',
    'savings',
    'wallet',
    'payments',
  ];

  @override
  void initState() {
    super.initState();
    _bankCtrl.addListener(_rebuild);
    _cardCtrl.addListener(_rebuild);
    _last4Ctrl.addListener(_rebuild);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfEditing());
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _bankCtrl.dispose();
    _cardCtrl.dispose();
    _last4Ctrl.dispose();
    _senderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIfEditing() async {
    final id = widget.cardId;
    if (id == null || id.isEmpty) return;
    final cards = await ref.read(cardsListProvider.future);
    CardModel? row;
    for (final card in cards) {
      if (card.id == id) {
        row = card;
        break;
      }
    }
    if (row == null || !mounted) return;
    final selected = row;
    setState(() {
      _editing = selected;
      _bankCtrl.text = selected.bankName;
      _cardCtrl.text = selected.cardName;
      _last4Ctrl.text = selected.lastFourDigits ?? '';
      _senderCtrl.text = selected.smsSenderId;
      _billDate = selected.billDate;
      _isActive = selected.isActive;
      final iconIdx = _iconKeys.indexOf(selected.cardIcon);
      _iconIndex = iconIdx >= 0 ? iconIdx : 0;
      if (selected.cardIcon.startsWith('theme:')) {
        final t = int.tryParse(selected.cardIcon.split(':').last) ?? 0;
        _themeIndex = t.clamp(0, AppColors.cardThemes.length - 1);
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final wasNew = _editing == null;
    final model = _editing ?? CardModel();
    model
      ..bankName = _bankCtrl.text.trim()
      ..cardName = _cardCtrl.text.trim()
      ..cardIcon = 'theme:$_themeIndex|${_iconKeys[_iconIndex]}'
      ..lastFourDigits =
          _last4Ctrl.text.trim().isEmpty ? null : _last4Ctrl.text.trim()
      ..smsSenderId = _senderCtrl.text.trim()
      ..billDate = _billDate
      ..isActive = _isActive
      ..createdAt = _editing?.createdAt ?? DateTime.now();

    await ref.read(cardMutationsProvider).saveCard(model);
    if (!mounted) return;

    final cardId = model.id;
    if (wasNew) {
      final configureSms = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add sample bank SMS?'),
              content: const Text(
                'Paste one transaction SMS for this card so future messages can be auto-detected.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Later'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Configure SMS Format'),
                ),
              ],
            ),
          ) ??
          false;

      if (!mounted) return;
      if (configureSms && cardId.isNotEmpty) {
        context.pushReplacement('/cards/sms-config?cardId=$cardId');
        return;
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppColors.cardThemes[_themeIndex];
    final last4 = _last4Ctrl.text.trim().isEmpty
        ? '••••'
        : _last4Ctrl.text.trim().padLeft(4, '•');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  ),
                  Expanded(
                    child: Text(
                      _editing == null ? 'Add Card' : 'Edit Card',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const EtAvatar(size: 36),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _CardPreview(
                      color: theme,
                      bankName: _bankCtrl.text.trim().isEmpty
                          ? 'Bank Name'
                          : _bankCtrl.text.trim(),
                      cardName: _cardCtrl.text.trim().isEmpty
                          ? 'Card Nickname'
                          : _cardCtrl.text.trim(),
                      last4: last4,
                      icon: _icons[_iconIndex],
                      billDate: _billDate,
                    ),
                    const SizedBox(height: 24),
                    _LabeledField(
                      label: 'Bank Name',
                      child: TextFormField(
                        controller: _bankCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_balance_outlined),
                          hintText: 'Premier Global',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Card Nickname',
                      child: TextFormField(
                        controller: _cardCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.credit_card_outlined),
                          hintText: 'Personal Spending',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Theme Color',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  for (var i = 0;
                                      i < AppColors.cardThemes.length;
                                      i++) ...[
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _themeIndex = i),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardThemes[i],
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _themeIndex == i
                                                ? AppColors.primary
                                                : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _LabeledField(
                            label: 'Bank Icon',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  for (var i = 0; i < _icons.length; i++) ...[
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _iconIndex = i),
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: _iconIndex == i
                                              ? AppColors.primaryFixed
                                              : AppColors.surfaceContainerHigh,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _icons[i],
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Last 4 Digits',
                            child: TextFormField(
                              controller: _last4Ctrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: const InputDecoration(
                                hintText: '1234',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'SMS Sender ID',
                            child: TextFormField(
                              controller: _senderCtrl,
                              decoration: const InputDecoration(
                                hintText: 'HBL / 8005',
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'Bill Date (day $_billDate)',
                      child: Slider(
                        min: 1,
                        max: 31,
                        divisions: 30,
                        value: _billDate.toDouble(),
                        label: '$_billDate',
                        onChanged: (v) =>
                            setState(() => _billDate = v.toInt()),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active card'),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Linking the SMS Sender ID allows ExpenseTracker to automatically categorize transactions from bank notifications.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                    if (_editing != null) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/cards/sms-config?cardId=${_editing!.id}',
                        ),
                        icon: const Icon(Icons.sms_outlined),
                        label: const Text('Configure SMS Format'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Save Card'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.color,
    required this.bankName,
    required this.cardName,
    required this.last4,
    required this.icon,
    required this.billDate,
  });

  final Color color;
  final String bankName;
  final String cardName;
  final String last4;
  final IconData icon;
  final int billDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, Colors.black, 0.28)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BANK NAME',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bankName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.white, size: 28),
            ],
          ),
          const Spacer(),
          Text(
            '••••   ••••   ••••   $last4',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD NICKNAME',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      cardName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'BILL DAY',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$billDate',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
