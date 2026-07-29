import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/profile_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../providers/dashboard_month_provider.dart';
import '../providers/threshold_status_provider.dart';
import '../widgets/threshold_progress_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _pickMonth(BuildContext context, WidgetRef ref) async {
    final current = ref.read(dashboardMonthProvider);
    final picked = await etPickMonth(context, current);
    if (picked != null) {
      ref.read(dashboardMonthProvider.notifier).state =
          DateTime(picked.year, picked.month);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(dashboardMonthProvider);
    final cardsAsync = ref.watch(activeCardsProvider);
    final reviewAsync = ref.watch(needsReviewProvider);
    final txAsync = ref.watch(transactionsListProvider);
    final profileName = ref.watch(profileNameProvider).valueOrNull ?? 'Alex';
    final monthLabel = DateFormat('MMMM yyyy').format(month);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(transactionsListProvider);
            ref.invalidate(thisMonthTotalProvider);
            ref.invalidate(needsReviewProvider);
            ref.invalidate(thresholdsProvider);
            ref.invalidate(categoryThresholdStatusesProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: EtAppHeader(
                  greeting: etGreeting(profileName.split(' ').first),
                  subtitle: monthLabel,
                  onCalendarTap: () => _pickMonth(context, ref),
                  onSubtitleTap: () => _pickMonth(context, ref),
                  onAvatarTap: () => context.go('/settings'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  0,
                  AppSpacing.margin,
                  108,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    txAsync.when(
                      data: (rows) {
                        final monthRows = _rowsForMonth(rows, month);
                        final prevRows = _rowsForMonth(
                          rows,
                          DateTime(month.year, month.month - 1),
                        );
                        final total = monthRows.fold<double>(
                          0,
                          (a, b) => a + b.amount,
                        );
                        final prev = prevRows.fold<double>(
                          0,
                          (a, b) => a + b.amount,
                        );
                        final trend = prev <= 0
                            ? null
                            : ((total - prev) / prev) * 100;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const EtLabelCaps('Total spend this month'),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    EtMoney.format(total),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 40,
                                          height: 1.05,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                  ),
                                ),
                                if (trend != null) ...[
                                  const SizedBox(width: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '${trend >= 0 ? '↑' : '↓'} ${trend.abs().toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: trend >= 0
                                            ? AppColors.trendUp
                                            : AppColors.success,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      },
                      error: (e, _) => Text('Error: $e'),
                      loading: () => const LinearProgressIndicator(),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    EtSectionHeader(
                      title: 'My Accounts',
                      actionLabel: 'See all',
                      onAction: () => context.push('/cards'),
                    ),
                    SizedBox(
                      height: 158,
                      child: cardsAsync.when(
                        data: (cards) {
                          if (cards.isEmpty) {
                            return EtSurfaceCard(
                              elevated: false,
                              onTap: () => context.push('/cards/form'),
                              child: const Row(
                                children: [
                                  Icon(Icons.add_card, color: AppColors.primary),
                                  SizedBox(width: 12),
                                  Text('Add a card to get started'),
                                ],
                              ),
                            );
                          }
                          return txAsync.when(
                            data: (rows) => ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: cards.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return _AccountCard(
                                  card: cards[index],
                                  rows: rows,
                                  month: month,
                                );
                              },
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                        error: (e, _) => Text('Error: $e'),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    reviewAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: EtSurfaceCard(
                            color: AppColors.errorContainer.withValues(
                              alpha: 0.45,
                            ),
                            onTap: () => context.push('/needs-review'),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.assignment_late_outlined,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${rows.length} SMS items need review',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        );
                      },
                      error: (_, __) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    ),
                    EtSectionHeader(
                      title: 'Top Categories',
                      actionLabel: 'Add',
                      onAction: () => context.push('/categories'),
                    ),
                    _CategorySummaryRow(ref: ref, month: month),
                    const SizedBox(height: AppSpacing.section),
                    const ThresholdProgressSection(),
                    const SizedBox(height: AppSpacing.section),
                    EtSectionHeader(
                      title: 'Recent Transactions',
                      actionLabel: 'View all',
                      onAction: () => context.go('/transactions'),
                    ),
                    txAsync.when(
                      data: (rows) {
                        final monthRows = _rowsForMonth(rows, month);
                        if (monthRows.isEmpty) {
                          return const Text('No transactions this month yet.');
                        }
                        final recent = monthRows.take(5).toList();
                        final dateFmt = DateFormat('MMM d, h:mm a');
                        return Column(
                          children: [
                            for (final row in recent) ...[
                              EtTransactionTile(
                                place: row.place,
                                category: row.category,
                                amount: row.amount,
                                subtitle: dateFmt.format(row.transactionDate),
                                onTap: () => context.go('/transactions'),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        );
                      },
                      error: (_, __) => const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<TransactionModel> _rowsForMonth(
  List<TransactionModel> rows,
  DateTime month,
) {
  return rows
      .where(
        (e) =>
            e.transactionDate.year == month.year &&
            e.transactionDate.month == month.month,
      )
      .toList();
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.card,
    required this.rows,
    required this.month,
  });

  final CardModel card;
  final List<TransactionModel> rows;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final digits = card.lastFourDigits ?? '----';
    final cardRows = rows.where((r) => r.cardId == card.id).toList();
    final monthSpend = cardRows
        .where(
          (r) =>
              r.transactionDate.year == month.year &&
              r.transactionDate.month == month.month,
        )
        .fold<double>(0, (a, b) => a + b.amount);

    final spark = <double>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final dayTotal = cardRows
          .where(
            (r) =>
                r.transactionDate.year == day.year &&
                r.transactionDate.month == day.month &&
                r.transactionDate.day == day.day,
          )
          .fold<double>(0, (a, b) => a + b.amount);
      spark.add(dayTotal);
    }

    return SizedBox(
      width: 260,
      height: 158,
      child: Material(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.summary),
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/cards/form?cardId=${card.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.more_vert,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  card.cardName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
                Text(
                  '**** $digits',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const EtLabelCaps('Spend'),
                          Text(
                            EtMoney.format(monthSpend),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              height: 1.2,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                    EtSparkline(values: spark, width: 64, height: 28),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySummaryRow extends StatelessWidget {
  const _CategorySummaryRow({required this.ref, required this.month});

  final WidgetRef ref;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsListProvider);
    final thresholdAsync = ref.watch(categoryThresholdStatusesProvider);

    return txAsync.when(
      data: (rows) {
        final monthRows = _rowsForMonth(rows, month);
        if (monthRows.isEmpty) {
          return const Text('No transactions this month yet.');
        }

        final totals = <String, double>{};
        for (final row in monthRows) {
          totals[row.category] = (totals[row.category] ?? 0) + row.amount;
        }

        final warningNames = thresholdAsync.maybeWhen(
          data: (statuses) => statuses
              .where((s) => s.isHighlighted)
              .map((s) => s.categoryName)
              .toSet(),
          orElse: () => <String>{},
        );

        final top = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final items = top.take(8).toList();

        return SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return Align(
                  alignment: Alignment.center,
                  child: Material(
                    color: AppColors.surfaceContainerHigh,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.push('/categories'),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.add,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }
              final e = items[index];
              final warned = warningNames.contains(e.key);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: warned
                      ? AppColors.errorContainer.withValues(alpha: 0.45)
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    EtCategoryBadge(category: e.key, size: 32, iconSize: 16),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EtLabelCaps(e.key),
                        Text(
                          EtMoney.format(e.value),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

