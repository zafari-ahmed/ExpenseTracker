import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_access_service.dart';
import '../../../../core/services/notification_ingest_service.dart';
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
  final _appSearchCtrl = TextEditingController();
  int _billDate = 10;
  bool _isActive = true;
  int _themeIndex = 0;
  int _iconIndex = 0;
  CardModel? _editing;
  CardParseSource _parseSource = CardParseSource.sms;
  InstalledAppInfo? _selectedApp;
  List<InstalledAppInfo> _apps = const [];
  bool _appsLoading = false;
  bool _editingAppPicker = false;
  bool _notificationAccessGranted = true;
  bool _checkingAccess = false;

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

  static const _notificationNote =
      'We’ll record spends from now on, and any bank alert still in the '
      'notification bar. Older dismissed alerts cannot be imported. If this '
      'bank also sends SMS, turn on SMS to fill the current month.';

  @override
  void initState() {
    super.initState();
    _bankCtrl.addListener(_rebuild);
    _cardCtrl.addListener(_rebuild);
    _last4Ctrl.addListener(_rebuild);
    _appSearchCtrl.addListener(_rebuild);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfEditing());
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _bankCtrl.dispose();
    _cardCtrl.dispose();
    _last4Ctrl.dispose();
    _senderCtrl.dispose();
    _appSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadIfEditing() async {
    final id = widget.cardId;
    if (id == null || id.isEmpty) {
      await _refreshNotificationAccess();
      return;
    }
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
      _parseSource = selected.parseSource;
      if (selected.parseSource == CardParseSource.notification &&
          selected.notificationPackage.trim().isNotEmpty) {
        _selectedApp = InstalledAppInfo(
          packageName: selected.notificationPackage.trim(),
          label: (selected.notificationAppLabel ?? '').trim().isEmpty
              ? selected.notificationPackage.trim()
              : selected.notificationAppLabel!.trim(),
        );
      }
      final iconIdx = _iconKeys.indexOf(selected.cardIcon);
      _iconIndex = iconIdx >= 0 ? iconIdx : 0;
      if (selected.cardIcon.startsWith('theme:')) {
        final raw = selected.cardIcon.substring(6).split('|').first;
        final t = int.tryParse(raw) ?? 0;
        _themeIndex = t.clamp(0, AppColors.cardThemes.length - 1);
      }
    });
    await _refreshNotificationAccess();
    if (_parseSource == CardParseSource.notification) {
      await _loadInstalledApps();
    }
  }

  Future<void> _refreshNotificationAccess() async {
    if (!Platform.isAndroid) {
      setState(() => _notificationAccessGranted = true);
      return;
    }
    setState(() => _checkingAccess = true);
    try {
      final granted =
          await ref.read(notificationAccessServiceProvider).isAccessGranted();
      if (!mounted) return;
      setState(() {
        _notificationAccessGranted = granted;
        _checkingAccess = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _notificationAccessGranted = false;
        _checkingAccess = false;
      });
    }
  }

  Future<void> _loadInstalledApps() async {
    if (!Platform.isAndroid) return;
    setState(() => _appsLoading = true);
    try {
      final apps =
          await ref.read(notificationAccessServiceProvider).getInstalledApps();
      if (!mounted) return;
      InstalledAppInfo? matched = _selectedApp;
      final selectedPackage = matched?.packageName;
      if (selectedPackage != null) {
        for (final app in apps) {
          if (app.packageName == selectedPackage) {
            matched = app;
            break;
          }
        }
      }
      setState(() {
        _apps = apps;
        _selectedApp = matched;
        _appsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _appsLoading = false);
    }
  }

  Future<void> _onParseSourceChanged(CardParseSource? value) async {
    if (value == null) return;
    setState(() {
      _parseSource = value;
      if (value == CardParseSource.notification) {
        _editingAppPicker = _selectedApp == null;
      }
    });
    if (value == CardParseSource.notification) {
      await _refreshNotificationAccess();
      await _loadInstalledApps();
    }
  }

  bool get _showAppPicker =>
      _parseSource == CardParseSource.notification &&
      (_selectedApp == null || _editingAppPicker);

  Future<void> _openNotificationAccess({required bool explainFirst}) async {
    if (!Platform.isAndroid) return;
    if (explainFirst && mounted) {
      final open = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Enable notification access'),
              content: const Text(
                'Expense Tracker needs Notification access to read bank app alerts '
                'for cards set to “Parse from: Notification”. Only apps you pick '
                'on a card are read. Your data stays on this device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Not now'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Open settings'),
                ),
              ],
            ),
          ) ??
          false;
      if (!open) return;
    }
    await ref.read(notificationAccessServiceProvider).openAccessSettings();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final switchingToNotification = _parseSource == CardParseSource.notification &&
        (_editing == null ||
            _editing!.parseSource != CardParseSource.notification);

    if (_parseSource == CardParseSource.notification) {
      await _refreshNotificationAccess();
      if (!_notificationAccessGranted) {
        await _openNotificationAccess(explainFirst: true);
        await _refreshNotificationAccess();
        if (!_notificationAccessGranted) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Turn on Notification access for Expense Tracker, then save again.',
              ),
            ),
          );
          return;
        }
      }
    }

    final wasNew = _editing == null;
    final model = _editing ?? CardModel();
    model
      ..bankName = _bankCtrl.text.trim()
      ..cardName = _cardCtrl.text.trim()
      ..cardIcon = 'theme:$_themeIndex|${_iconKeys[_iconIndex]}'
      ..lastFourDigits =
          _last4Ctrl.text.trim().isEmpty ? null : _last4Ctrl.text.trim()
      ..smsSenderId = _parseSource == CardParseSource.sms
          ? _senderCtrl.text.trim()
          : (_editing?.smsSenderId ?? '')
      ..billDate = _billDate
      ..isActive = _isActive
      ..createdAt = _editing?.createdAt ?? DateTime.now()
      ..parseSource = _parseSource
      ..notificationPackage = _parseSource == CardParseSource.notification
          ? (_selectedApp?.packageName ?? '')
          : ''
      ..notificationAppLabel = _parseSource == CardParseSource.notification
          ? _selectedApp?.label
          : null;

    await ref.read(cardMutationsProvider).saveCard(model);
    await ref.read(notificationIngestServiceProvider).refreshListeningState();
    if (!mounted) return;

    final cardId = model.id;
    if (wasNew && _parseSource == CardParseSource.sms) {
      final configureSms = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Configure SMS format?'),
              content: const Text(
                'We’ll pull the latest inbox SMS from this card’s sender so you can confirm amount and merchant.',
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

    if (switchingToNotification && mounted) {
      // Access already ensured above; shade scan happens in ingest start().
    }

    if (mounted) Navigator.of(context).pop();
  }

  List<InstalledAppInfo> get _filteredApps {
    final q = _appSearchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _apps;
    return _apps
        .where(
          (a) =>
              a.label.toLowerCase().contains(q) ||
              a.packageName.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppColors.cardThemes[_themeIndex];
    final last4 = _last4Ctrl.text.trim().isEmpty
        ? '••••'
        : _last4Ctrl.text.trim().padLeft(4, '•');
    final isSms = _parseSource == CardParseSource.sms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            EtPageHeader(
              title: _editing == null ? 'Add a card' : 'Edit card',
              closeInsteadOfBack: true,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Bank Name',
                            child: TextFormField(
                              controller: _bankCtrl,
                              decoration: const InputDecoration(
                                prefixIcon:
                                    Icon(Icons.account_balance_outlined),
                                hintText: 'Premier Global',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Card Nickname',
                            child: TextFormField(
                              controller: _cardCtrl,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.credit_card_outlined),
                                hintText: 'Personal Spending',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ),
                      ],
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
                                          borderRadius:
                                              BorderRadius.circular(9),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            label: 'Parse from',
                            child: DropdownButtonFormField<CardParseSource>(
                              value: _parseSource,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.tune_outlined),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: CardParseSource.sms,
                                  child: Text('SMS'),
                                ),
                                DropdownMenuItem(
                                  value: CardParseSource.notification,
                                  child: Text('Notification'),
                                ),
                              ],
                              onChanged: _onParseSourceChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isSms) ...[
                      _LabeledField(
                        label: 'SMS Sender ID',
                        child: TextFormField(
                          controller: _senderCtrl,
                          decoration: const InputDecoration(
                            hintText: 'HBL / 8005',
                          ),
                          validator: (v) {
                            if (_parseSource != CardParseSource.sms) {
                              return null;
                            }
                            return (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null;
                          },
                        ),
                      ),
                    ] else ...[
                      _LabeledField(
                        label: 'Bank app',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormField<InstalledAppInfo>(
                              validator: (_) {
                                if (_parseSource !=
                                    CardParseSource.notification) {
                                  return null;
                                }
                                if (_selectedApp == null ||
                                    _selectedApp!.packageName.isEmpty) {
                                  return 'Select an app';
                                }
                                return null;
                              },
                              builder: (field) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selectedApp != null &&
                                        !_editingAppPicker)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryFixed,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (_selectedApp!.iconBytes != null)
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.memory(
                                                  _selectedApp!.iconBytes!,
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            else
                                              const Icon(Icons.apps_outlined),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Selected app',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                  Text(
                                                    _selectedApp!.label,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: 'Change app',
                                              onPressed: () async {
                                                setState(() {
                                                  _editingAppPicker = true;
                                                });
                                                if (_apps.isEmpty) {
                                                  await _loadInstalledApps();
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_showAppPicker) ...[
                                      if (_selectedApp != null) ...[
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () => setState(() {
                                              _editingAppPicker = false;
                                              _appSearchCtrl.clear();
                                            }),
                                            child: const Text('Cancel'),
                                          ),
                                        ),
                                      ],
                                      TextFormField(
                                        controller: _appSearchCtrl,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.search),
                                          hintText: 'Search apps…',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (_appsLoading)
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      else
                                        Container(
                                          constraints: const BoxConstraints(
                                            maxHeight: 200,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: field.hasError
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .error
                                                  : AppColors.outlineVariant,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: _filteredApps.isEmpty
                                              ? const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child: Text('No apps found'),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _filteredApps.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final app =
                                                        _filteredApps[index];
                                                    final selected = _selectedApp
                                                            ?.packageName ==
                                                        app.packageName;
                                                    return ListTile(
                                                      dense: true,
                                                      selected: selected,
                                                      leading: app.iconBytes ==
                                                              null
                                                          ? const Icon(
                                                              Icons
                                                                  .apps_outlined,
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                8,
                                                              ),
                                                              child:
                                                                  Image.memory(
                                                                app.iconBytes!,
                                                                width: 32,
                                                                height: 32,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                      title: Text(app.label),
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedApp = app;
                                                          _editingAppPicker =
                                                              false;
                                                          _appSearchCtrl
                                                              .clear();
                                                        });
                                                        field.didChange(app);
                                                      },
                                                    );
                                                  },
                                                ),
                                        ),
                                    ],
                                    if (field.hasError)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          field.errorText!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 10),
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
                                    _notificationNote,
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
                            if (!_notificationAccessGranted) ...[
                              const SizedBox(height: 10),
                              Text(
                                _checkingAccess
                                    ? 'Checking notification access…'
                                    : 'Notification access is off. Enable it so bank alerts can be read.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton.icon(
                                onPressed: () => _openNotificationAccess(
                                  explainFirst: false,
                                ),
                                icon: const Icon(Icons.notifications_active_outlined),
                                label: const Text('Enable notification access'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _LabeledField(
                            label: 'Bill Date',
                            child: DropdownButtonFormField<int>(
                              value: _billDate.clamp(1, 31),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              items: [
                                for (var day = 1; day <= 31; day++)
                                  DropdownMenuItem(
                                    value: day,
                                    child: Text('$day'),
                                  ),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _billDate = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LabeledField(
                            label: 'Active card',
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_isActive ? 'On' : 'Off'),
                              value: _isActive,
                              onChanged: (v) =>
                                  setState(() => _isActive = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isSms)
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
                              'Linking the SMS Sender ID allows Expense Tracker to automatically categorize transactions from bank notifications.',
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
                    if (_editing != null && isSms) ...[
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
