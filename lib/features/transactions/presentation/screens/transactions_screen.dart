import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import 'transaction_edit_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _openEdit(BuildContext context, TransactionModel row) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: EtSurfaceCard(
          radius: AppRadii.summary,
          padding: EdgeInsets.zero,
          child: TransactionEditSheet(transaction: row),
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    TransactionModel row,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text(
          row.source == TransactionSource.sms
              ? 'This transaction came from SMS. Delete it permanently?'
              : 'Delete this transaction permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(transactionMutationsProvider).delete(row.id);
  }

  Future<void> _openFilters() async {
    final filters = ref.read(transactionFilterProvider);
    final cards = await ref.read(activeCardsProvider.future);
    final categories = await ref.read(categoriesProvider.future);
    if (!mounted) return;

    var cardId = filters.cardId;
    var category = filters.category;
    var fromDate = filters.fromDate;
    var toDate = filters.toDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            Future<void> pickFrom() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) setModal(() => fromDate = picked);
            }

            Future<void> pickTo() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: fromDate ?? DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              if (picked != null) setModal(() => toDate = picked);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Row(
                      children: [
                        Text(
                          'Filters',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModal(() {
                              cardId = null;
                              category = null;
                              fromDate = null;
                              toDate = null;
                            });
                          },
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const EtLabelCaps('Card'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: cardId,
                      decoration: const InputDecoration(hintText: 'All cards'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Cards'),
                        ),
                        ...cards.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.cardName),
                          ),
                        ),
                      ],
                      onChanged: (value) => setModal(() => cardId = value),
                    ),
                    const SizedBox(height: 16),
                    const EtLabelCaps('Category'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FilterPill(
                          label: 'All',
                          selected: category == null,
                          onTap: () => setModal(() => category = null),
                        ),
                        ...categories.map(
                          (c) => _FilterPill(
                            label: c.name,
                            selected: category == c.name,
                            onTap: () => setModal(() => category = c.name),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const EtLabelCaps('Date range'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickFrom,
                            icon: const Icon(Icons.calendar_today_outlined, size: 16),
                            label: Text(
                              fromDate == null
                                  ? 'From'
                                  : DateFormat('dd MMM yyyy').format(fromDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: pickTo,
                            icon: const Icon(Icons.event_outlined, size: 16),
                            label: Text(
                              toDate == null
                                  ? 'To'
                                  : DateFormat('dd MMM yyyy').format(toDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () {
                        ref.read(transactionFilterProvider.notifier).state =
                            TransactionFilters(
                          cardId: cardId,
                          category: category,
                          fromDate: fromDate,
                          toDate: toDate,
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get _hasActiveFilters {
    final f = ref.watch(transactionFilterProvider);
    return f.cardId != null ||
        f.category != null ||
        f.fromDate != null ||
        f.toDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsListProvider);
    final cardsAsync = ref.watch(activeCardsProvider);
    final filters = ref.watch(transactionFilterProvider);
    final dateFmt = DateFormat('MMM d');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            EtAppHeader(
              onAvatarTap: () {},
              onCalendarTap: _openFilters,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v.trim()),
                      decoration: const InputDecoration(
                        hintText: 'Search transactions',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: _hasActiveFilters
                            ? AppColors.primaryFixed
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        child: InkWell(
                          onTap: _openFilters,
                          borderRadius: BorderRadius.circular(AppRadii.input),
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              Icons.tune,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      if (_hasActiveFilters)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            cardsAsync.when(
              data: (cards) {
                final labels = [
                  'All Transactions',
                  ...cards.map((c) {
                    final digits = c.lastFourDigits;
                    return digits == null || digits.isEmpty
                        ? c.cardName
                        : '${c.cardName} *$digits';
                  }),
                ];
                var selected = 0;
                if (filters.cardId != null) {
                  final idx = cards.indexWhere((c) => c.id == filters.cardId);
                  if (idx >= 0) selected = idx + 1;
                }
                return EtFilterChipBar(
                  labels: labels,
                  selectedIndex: selected,
                  onSelected: (index) {
                    final current = ref.read(transactionFilterProvider);
                    ref.read(transactionFilterProvider.notifier).state =
                        TransactionFilters(
                      cardId: index == 0 ? null : cards[index - 1].id,
                      category: current.category,
                      fromDate: current.fromDate,
                      toDate: current.toDate,
                    );
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            if (filters.category != null ||
                filters.fromDate != null ||
                filters.toDate != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                  children: [
                    if (filters.category != null)
                      _ActiveFilterChip(
                        label: filters.category!,
                        onClear: () {
                          final c = ref.read(transactionFilterProvider);
                          ref.read(transactionFilterProvider.notifier).state =
                              TransactionFilters(
                            cardId: c.cardId,
                            fromDate: c.fromDate,
                            toDate: c.toDate,
                          );
                        },
                      ),
                    if (filters.fromDate != null || filters.toDate != null)
                      _ActiveFilterChip(
                        label: [
                          if (filters.fromDate != null)
                            DateFormat('dd MMM').format(filters.fromDate!),
                          if (filters.toDate != null)
                            DateFormat('dd MMM').format(filters.toDate!),
                        ].join(' – '),
                        onClear: () {
                          final c = ref.read(transactionFilterProvider);
                          ref.read(transactionFilterProvider.notifier).state =
                              TransactionFilters(
                            cardId: c.cardId,
                            category: c.category,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: txAsync.when(
                data: (rows) {
                  final filtered = _query.isEmpty
                      ? rows
                      : rows
                          .where(
                            (r) =>
                                r.place
                                    .toLowerCase()
                                    .contains(_query.toLowerCase()) ||
                                r.category
                                    .toLowerCase()
                                    .contains(_query.toLowerCase()),
                          )
                          .toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No transactions yet.'));
                  }

                  final grouped = <String, List<TransactionModel>>{};
                  for (final row in filtered) {
                    final key = DateFormat('EEEE, MMM d')
                        .format(row.transactionDate)
                        .toUpperCase();
                    grouped.putIfAbsent(key, () => []).add(row);
                  }

                  final sections = grouped.entries.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      8,
                      AppSpacing.margin,
                      108,
                    ),
                    itemCount: sections.length,
                    itemBuilder: (context, sectionIndex) {
                      final section = sections[sectionIndex];
                      final dayTotal = section.value.fold<double>(
                        0,
                        (a, b) => a + b.amount,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    section.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                Text(
                                  '-${EtMoney.format(dayTotal)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          for (final row in section.value) ...[
                            EtTransactionTile(
                              place: row.place,
                              category: row.category,
                              amount: row.amount,
                              subtitle: row.category,
                              badge: dateFmt.format(row.transactionDate),
                              showAccent: true,
                              onTap: () => _openEdit(context, row),
                              onDelete: () => _deleteTransaction(context, row),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  );
                },
                error: (error, _) => Center(child: Text('Error: $error')),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryFixed,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
