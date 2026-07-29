import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime _month = DateTime.now();
  bool _donutView = true;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsListProvider);
    final monthLabel = DateFormat('MMMM yyyy').format(_month);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: txAsync.when(
          data: (rows) {
            final monthRows = rows
                .where(
                  (e) =>
                      e.transactionDate.year == _month.year &&
                      e.transactionDate.month == _month.month,
                )
                .toList();

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
                0,
                AppSpacing.margin,
                120,
              ),
              children: [
                const EtAppHeader(showCalendar: true),
                EtSurfaceCard(
                  radius: AppRadii.input,
                  padding: const EdgeInsets.all(8),
                  color: AppColors.surfaceContainerLow,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(
                          () => _month =
                              DateTime(_month.year, _month.month - 1),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const EtLabelCaps('Current period'),
                            Text(
                              monthLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => _month =
                              DateTime(_month.year, _month.month + 1),
                        ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Row(
                      children: [
                        _Segment(
                          label: 'Donut View',
                          selected: _donutView,
                          onTap: () => setState(() => _donutView = true),
                        ),
                        _Segment(
                          label: 'Trend View',
                          selected: !_donutView,
                          onTap: () => setState(() => _donutView = false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                if (_donutView)
                  SizedBox(
                    height: 280,
                    child: sections.isEmpty
                        ? const Center(
                            child: Text('No chart data for this month'),
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
                else
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
                                final month = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month - (5 - value.toInt()),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('MMM').format(month).toUpperCase(),
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
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.section),
                const EtLabelCaps('Category details'),
                const SizedBox(height: 12),
                if (sections.isEmpty)
                  const Text('No category spend for this month.')
                else
                  ...sections.map((e) {
                    final pct = total == 0 ? 0.0 : (e.value / total) * 100;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: EtSurfaceCard(
                        radius: AppRadii.card,
                        child: Row(
                          children: [
                            EtCategoryBadge(category: e.key),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  Text(
                                    '${pct.toStringAsFixed(0)}% of total spend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              EtMoney.format(e.value),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: AppSpacing.md),
                _InsightCard(rows: rows, month: _month),
              ],
            );
          },
          error: (e, _) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(
    List<TransactionModel> rows,
    DateTime month,
    int x,
  ) {
    double total = 0;
    for (final row in rows) {
      if (row.transactionDate.year == month.year &&
          row.transactionDate.month == month.month) {
        total += row.amount;
      }
    }
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceContainerLowest
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.rows, required this.month});

  final List<TransactionModel> rows;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final prev = DateTime(month.year, month.month - 1);
    double current = 0;
    double previous = 0;
    for (final row in rows) {
      if (row.transactionDate.year == month.year &&
          row.transactionDate.month == month.month) {
        current += row.amount;
      }
      if (row.transactionDate.year == prev.year &&
          row.transactionDate.month == prev.month) {
        previous += row.amount;
      }
    }

    String message;
    IconData icon = Icons.insights_outlined;
    if (previous <= 0) {
      message =
          'Track a full month to unlock spending insights versus last period.';
    } else {
      final delta = ((current - previous) / previous) * 100;
      if (delta <= 0) {
        icon = Icons.trending_down;
        message =
            'You spent ${delta.abs().toStringAsFixed(0)}% less this month compared to ${DateFormat('MMMM').format(prev)}. Keep it up!';
      } else {
        icon = Icons.trending_up;
        message =
            'Spending is up ${delta.toStringAsFixed(0)}% versus ${DateFormat('MMMM').format(prev)}. Review top categories below.';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadii.summary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Spending Insight',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
