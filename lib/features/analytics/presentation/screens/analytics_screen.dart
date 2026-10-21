import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/period_range.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../settings/presentation/providers/preferences_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  int _tab = 0;

  int _defaultBillDay(List<CardModel> cards) {
    if (cards.isEmpty) return 1;
    return cards.first.billDate;
  }

  Map<String, int> _billDays(List<CardModel> cards) {
    return {for (final c in cards) c.id: c.billDate};
  }

  List<TransactionModel> _rowsForPeriod(
    List<TransactionModel> rows, {
    required SpendPeriodMode mode,
    required DateTime selectedMonth,
    required Map<String, int> billDayByCardId,
    required int fallbackBillDay,
  }) {
    final anchor = PeriodHelper.resolveAnchor(
      selectedMonth: selectedMonth,
      mode: mode,
    );
    return rows
        .where(
          (e) => PeriodHelper.isInPeriod(
            date: e.transactionDate,
            mode: mode,
            anchor: anchor,
            billDay: billDayByCardId[e.cardId] ?? fallbackBillDay,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currencyProvider);
    final txAsync = ref.watch(transactionsListProvider);
    final periodMode =
        ref.watch(spendPeriodModeProvider).valueOrNull ?? SpendPeriodMode.monthly;
    final cards = ref.watch(cardsListProvider).valueOrNull ?? const <CardModel>[];
    final billDay = _defaultBillDay(cards);
    final billDays = _billDays(cards);
    final anchor = PeriodHelper.resolveAnchor(
      selectedMonth: _month,
      mode: periodMode,
    );
    final period = PeriodHelper.forMode(
      mode: periodMode,
      anchor: anchor,
      billDay: billDay,
    );
    final monthLabel = periodMode == SpendPeriodMode.monthly
        ? DateFormat('MMMM yyyy').format(_month)
        : period.monthStyleLabel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: txAsync.when(
          data: (rows) {
            final monthRows = _rowsForPeriod(
              rows,
              mode: periodMode,
              selectedMonth: _month,
              billDayByCardId: billDays,
              fallbackBillDay: billDay,
            );

            final byCategory = <String, double>{};
            for (final row in monthRows) {
              byCategory[row.category] =
                  (byCategory[row.category] ?? 0) + row.amount;
            }

            final sections = byCategory.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final total =
                byCategory.values.fold<double>(0, (a, b) => a + b);

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.margin,
                12,
                AppSpacing.margin,
                120,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Analytics',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => _month =
                                  DateTime(_month.year, _month.month - 1),
                            ),
                            icon: const Icon(Icons.chevron_left, size: 18),
                          ),
                          EtLabelCaps(monthLabel),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => setState(
                              () => _month =
                                  DateTime(_month.year, _month.month + 1),
                            ),
                            icon: const Icon(Icons.chevron_right, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                EtSegmented(
                  labels: const ['Categories', 'Trend', 'Merchants'],
                  selectedIndex: _tab,
                  onSelected: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 12),
                if (_tab == 0)
                  SizedBox(
                    height: 280,
                    child: sections.isEmpty
                        ? Center(
                            child: Text(
                              periodMode == SpendPeriodMode.billingCycle
                                  ? 'No chart data for this billing cycle'
                                  : 'No chart data for this month',
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 72,
                                  sections: [
                                    for (var i = 0; i < sections.length; i++)
                                      PieChartSectionData(
                                        title: '',
                                        value: sections[i].value,
                                        radius: 28,
                                        color: AppColors.categoryPalette[
                                            i %
                                                AppColors
                                                    .categoryPalette.length],
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const EtLabelCaps('Total spent'),
                                  Text(
                                    EtMoney.format(total),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  )
                else if (_tab == 1)
                  SizedBox(
                    height: 260,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final selected = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month - (5 - value.toInt()),
                                );
                                final labelAnchor = PeriodHelper.resolveAnchor(
                                  selectedMonth: selected,
                                  mode: periodMode,
                                );
                                final labelPeriod = PeriodHelper.forMode(
                                  mode: periodMode,
                                  anchor: labelAnchor,
                                  billDay: billDay,
                                );
                                final text = periodMode == SpendPeriodMode.monthly
                                    ? DateFormat('MMM').format(selected).toUpperCase()
                                    : DateFormat('dd/MM').format(labelPeriod.start);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (int i = 5; i >= 0; i--)
                            _barGroup(
                              rows,
                              DateTime(
                                DateTime.now().year,
                                DateTime.now().month - i,
                              ),
                              5 - i,
                              mode: periodMode,
                              billDayByCardId: billDays,
                              fallbackBillDay: billDay,
                            ),
                        ],
                      ),
                    ),
                  ),
                if (_tab == 2) ...[
                  const EtLabelCaps('Merchants'),
                  const SizedBox(height: 12),
                  ..._merchantRows(monthRows),
                ],
                if (_tab == 0) ...[
                  const SizedBox(height: AppSpacing.section),
                  const EtLabelCaps('Breakdown'),
                  const SizedBox(height: 12),
                  if (sections.isEmpty)
                    Text(
                      periodMode == SpendPeriodMode.billingCycle
                          ? 'No category spend for this billing cycle.'
                          : 'No category spend for this month.',
                    )
                  else
                    EtSurfaceCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < sections.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _BreakdownRow(
                              name: sections[i].key,
                              amount: sections[i].value,
                              count: monthRows
                                  .where((r) => r.category == sections[i].key)
                                  .length,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: AppSpacing.md),
                _InsightCard(
                  rows: rows,
                  selectedMonth: _month,
                  periodMode: periodMode,
                  billDayByCardId: billDays,
                  fallbackBillDay: billDay,
                ),
              ],
            );
          },
          error: (e, _) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  List<Widget> _merchantRows(List<TransactionModel> rows) {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final row in rows) {
      totals[row.place] = (totals[row.place] ?? 0) + row.amount;
      counts[row.place] = (counts[row.place] ?? 0) + 1;
    }
    final items = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (items.isEmpty) {
      return const [Text('No merchants this period.')];
    }
    return [
      EtSurfaceCard(
        child: Column(
          children: [
            for (var i = 0; i < items.take(8).length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _BreakdownRow(
                name: items[i].key,
                amount: items[i].value,
                count: counts[items[i].key] ?? 0,
              ),
            ],
          ],
        ),
      ),
    ];
  }

  BarChartGroupData _barGroup(
    List<TransactionModel> rows,
    DateTime selectedMonth,
    int x, {
    required SpendPeriodMode mode,
    required Map<String, int> billDayByCardId,
    required int fallbackBillDay,
  }) {
    final periodRows = _rowsForPeriod(
      rows,
      mode: mode,
      selectedMonth: selectedMonth,
      billDayByCardId: billDayByCardId,
      fallbackBillDay: fallbackBillDay,
    );
    final total = periodRows.fold<double>(0, (a, b) => a + b.amount);
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: total,
          width: 18,
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.name,
    required this.amount,
    required this.count,
  });

  final String name;
  final double amount;
  final int count;

  @override
  Widget build(BuildContext context) {
    final avg = count == 0 ? 0.0 : amount / count;
    return Row(
      children: [
        EtCategoryBadge(category: name),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleMedium),
              EtLabelCaps('$count EXPENSES · AVG ${EtMoney.format(avg)}'),
            ],
          ),
        ),
        Text(
          EtMoney.format(amount),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.rows,
    required this.selectedMonth,
    required this.periodMode,
    required this.billDayByCardId,
    required this.fallbackBillDay,
  });

  final List<TransactionModel> rows;
  final DateTime selectedMonth;
  final SpendPeriodMode periodMode;
  final Map<String, int> billDayByCardId;
  final int fallbackBillDay;

  @override
  Widget build(BuildContext context) {
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    double current = 0;
    double previous = 0;
    final currentAnchor = PeriodHelper.resolveAnchor(
      selectedMonth: selectedMonth,
      mode: periodMode,
    );
    final prevAnchor = PeriodHelper.resolveAnchor(
      selectedMonth: prevMonth,
      mode: periodMode,
    );
    for (final row in rows) {
      final billDay = billDayByCardId[row.cardId] ?? fallbackBillDay;
      if (PeriodHelper.isInPeriod(
        date: row.transactionDate,
        mode: periodMode,
        anchor: currentAnchor,
        billDay: billDay,
      )) {
        current += row.amount;
      }
      if (PeriodHelper.isInPeriod(
        date: row.transactionDate,
        mode: periodMode,
        anchor: prevAnchor,
        billDay: billDay,
      )) {
        previous += row.amount;
      }
    }

    String message;
    final periodWord =
        periodMode == SpendPeriodMode.billingCycle ? 'billing cycle' : 'month';
    if (previous <= 0) {
      message =
          'Track a full $periodWord to unlock spending insights versus last period.';
    } else {
      final delta = ((current - previous) / previous) * 100;
      if (delta <= 0) {
        message =
            'You spent ${delta.abs().toStringAsFixed(0)}% less this $periodWord compared to the previous period. Keep it up!';
      } else {
        message =
            'Spending is up ${delta.toStringAsFixed(0)}% versus the previous $periodWord. Review top categories below.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EtLabelCaps('INSIGHT', color: AppColors.soft),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
