import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/routing/app_shell.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/reviewer_demo_service.dart';
import '../../../../core/services/service_providers.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/period_range.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../cards/data/models/card_model.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../settings/presentation/providers/preferences_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../onboarding/presentation/widgets/how_to_sheet.dart';
import '../providers/dashboard_month_provider.dart';
import '../providers/threshold_status_provider.dart';
import '../widgets/threshold_progress_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _howToPrompted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHowTo());
  }

  Future<void> _maybeShowHowTo() async {
    if (_howToPrompted) return;
    _howToPrompted = true;
    final seen = await ref.read(onboardingServiceProvider).isHowToSeen();
    if (seen || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    await showHowToSheet(context, ref);
  }

  Future<void> _pickMonth() async {
    final current = ref.read(dashboardMonthProvider);
    final picked = await runWithHiddenAddFab(
      ref,
      () => etPickMonth(context, current),
    );
    if (picked != null) {
      ref.read(dashboardMonthProvider.notifier).state =
          DateTime(picked.year, picked.month);
    }
  }

  int _defaultBillDay(List<CardModel> cards) {
    if (cards.isEmpty) return 1;
    return cards.first.billDate;
  }

  Map<String, int> _billDayByCard(List<CardModel> cards) {
    return {for (final c in cards) c.id: c.billDate};
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(dashboardMonthProvider);
    final cardsAsync = ref.watch(activeCardsProvider);
    final allCardsAsync = ref.watch(cardsListProvider);
    final reviewAsync = ref.watch(needsReviewProvider);
    final txAsync = ref.watch(transactionsListProvider);
    final smsGranted = ref.watch(smsGrantedProvider).valueOrNull ?? false;
    ref.watch(currencyProvider);
    final periodMode =
        ref.watch(spendPeriodModeProvider).valueOrNull ?? SpendPeriodMode.monthly;
    final activeCards = cardsAsync.valueOrNull ?? const <CardModel>[];
    final allCards = allCardsAsync.valueOrNull ?? activeCards;
    final billDay = _defaultBillDay(activeCards);
    final billDays = _billDayByCard(allCards);
    final anchor = PeriodHelper.resolveAnchor(
      selectedMonth: month,
      mode: periodMode,
    );
    final period = PeriodHelper.forMode(
      mode: periodMode,
      anchor: anchor,
      billDay: billDay,
    );
    final periodLabel = periodMode == SpendPeriodMode.monthly
        ? DateFormat('MMM yyyy').format(month).toUpperCase()
        : period.monthStyleLabel.toUpperCase();
    final endInclusive = period.end.subtract(const Duration(milliseconds: 1));
    final rangeLabel =
        '${DateFormat('dd').format(period.start)}–${DateFormat('dd').format(endInclusive)}';

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
            ref.invalidate(spendPeriodModeProvider);
            ref.invalidate(smsGrantedProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      const EtBrandMark(),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          AppInfo.brand,
                          style: GoogleFonts.archivo(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/settings'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: smsGranted
                                      ? AppColors.successBright
                                      : AppColors.onSurfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                smsGranted ? 'SMS ON' : 'SMS OFF',
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 10,
                                  letterSpacing: 0.6,
                                  color: AppColors.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 108),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    txAsync.when(
                      data: (rows) {
                        final monthRows = _rowsForPeriod(
                          rows,
                          mode: periodMode,
                          anchor: anchor,
                          billDayByCardId: billDays,
                          fallbackBillDay: billDay,
                        );
                        final prevAnchor = PeriodHelper.resolveAnchor(
                          selectedMonth: PeriodHelper.shiftAnchor(month, -1),
                          mode: periodMode,
                        );
                        final prevRows = _rowsForPeriod(
                          rows,
                          mode: periodMode,
                          anchor: prevAnchor,
                          billDayByCardId: billDays,
                          fallbackBillDay: billDay,
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
                        final days = mathMax(
                          1,
                          period.end.difference(period.start).inDays,
                        );
                        final dailyAvg = total / days;
                        final spark = _weekSpark(monthRows);

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _pickMonth(),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.ink,
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.card),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        EtLabelCaps(
                                          'TOTAL SPEND · $periodLabel',
                                          color: AppColors.soft,
                                        ),
                                        const Spacer(),
                                        EtLabelCaps(
                                          rangeLabel,
                                          color: AppColors.soft,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            EtMoney.format(total),
                                            style: GoogleFonts.archivo(
                                              fontSize: 38,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -1.1,
                                              height: 1,
                                              color: Colors.white,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (trend != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: trend >= 0
                                                  ? AppColors.trendUp
                                                  : AppColors.success,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  trend >= 0
                                                      ? Icons.north_east
                                                      : Icons.south_east,
                                                  size: 13,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${trend.abs().toStringAsFixed(0)}%',
                                                  style:
                                                      GoogleFonts.ibmPlexMono(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    EtBarSpark(
                                      values: spark,
                                      height: 40,
                                      color: AppColors.primaryBright,
                                      trackColor: AppColors.inkMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final smsCards = activeCards
                                    .where(
                                      (c) =>
                                          c.parseSource == CardParseSource.sms,
                                    )
                                    .length;
                                final notifCards = activeCards
                                    .where(
                                      (c) =>
                                          c.parseSource ==
                                          CardParseSource.notification,
                                    )
                                    .length;
                                // One card → that source only.
                                // Mixed SMS + notification cards → both tiles.
                                // All same source → that source only.
                                final showSms = smsCards > 0;
                                final showNotif = notifCards > 0;
                                final smsCount = monthRows
                                    .where((r) => r.source.fromSms)
                                    .length;
                                final notifCount = monthRows
                                    .where((r) => r.source.fromNotification)
                                    .length;
                                final tileCount =
                                    1 + (showSms ? 1 : 0) + (showNotif ? 1 : 0);
                                final valueSize = tileCount >= 3 ? 18.0 : 20.0;
                                TextStyle valueStyle() => GoogleFonts.archivo(
                                      fontSize: valueSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.4,
                                    );
                                TextStyle subStyle([Color? color]) =>
                                    GoogleFonts.ibmPlexMono(
                                      fontSize: tileCount >= 3 ? 9 : 10,
                                      color: color ??
                                          AppColors.onSurfaceVariant,
                                    );

                                Widget gap() => SizedBox(
                                      width: tileCount >= 3 ? 10 : 12,
                                    );

                                Widget dailyTile() => EtSurfaceCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const EtLabelCaps('DAILY AVG'),
                                          const SizedBox(height: 8),
                                          Text(
                                            EtMoney.format(dailyAvg),
                                            style: valueStyle(),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            trend == null
                                                ? 'vs last period'
                                                : '${trend >= 0 ? '+' : '−'}${trend.abs().toStringAsFixed(0)}% vs last',
                                            style: subStyle(
                                              trend == null
                                                  ? null
                                                  : trend >= 0
                                                      ? AppColors.trendUp
                                                      : AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                Widget parseTile({
                                  required String label,
                                  required int count,
                                  required int cards,
                                }) =>
                                    EtSurfaceCard(
                                      onTap: () => context.push('/cards'),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          EtLabelCaps(label),
                                          const SizedBox(height: 8),
                                          Text('$count', style: valueStyle()),
                                          const SizedBox(height: 4),
                                          Text(
                                            cards == 1
                                                ? '1 card'
                                                : '$cards cards',
                                            style: subStyle(),
                                          ),
                                        ],
                                      ),
                                    );

                                return Row(
                                  children: [
                                    Expanded(child: dailyTile()),
                                    if (showSms) ...[
                                      gap(),
                                      Expanded(
                                        child: parseTile(
                                          label: 'SMS',
                                          count: smsCount,
                                          cards: smsCards,
                                        ),
                                      ),
                                    ],
                                    if (showNotif) ...[
                                      gap(),
                                      Expanded(
                                        child: parseTile(
                                          label: 'NOTIF',
                                          count: notifCount,
                                          cards: notifCards,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                      error: (e, _) => Text('Error: $e'),
                      loading: () => const LinearProgressIndicator(),
                    ),
                    const SizedBox(height: 12),
                    reviewAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EtSurfaceCard(
                            onTap: () => context.push('/needs-review'),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.help_outline,
                                  color: AppColors.amber,
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
                      title: 'Top categories',
                      actionLabel: 'See all',
                      onAction: () => context.go('/analytics'),
                    ),
                    _TopCategoriesCard(
                      periodMode: periodMode,
                      anchor: anchor,
                      billDayByCardId: billDays,
                      fallbackBillDay: billDay,
                    ),
                    const SizedBox(height: 12),
                    const ThresholdProgressSection(),
                    const SizedBox(height: 12),
                    EtSectionHeader(
                      title: 'Latest · auto-captured',
                      actionLabel: 'View all',
                      onAction: () => context.go('/transactions'),
                    ),
                    txAsync.when(
                      data: (rows) {
                        final monthRows = _rowsForPeriod(
                          rows,
                          mode: periodMode,
                          anchor: anchor,
                          billDayByCardId: billDays,
                          fallbackBillDay: billDay,
                        );
                        if (monthRows.isEmpty) {
                          return _SmsEmptyState(
                            billingCycle:
                                periodMode == SpendPeriodMode.billingCycle,
                          );
                        }
                        final recent = monthRows.take(5).toList();
                        final cardsById = {
                          for (final c in allCards) c.id: c,
                        };
                        return EtTxnGroup(
                          children: [
                            for (final row in recent)
                              EtTransactionTile(
                                place: row.place,
                                category: row.category,
                                amount: row.amount,
                                subtitle: _txnMeta(row, cardsById[row.cardId]),
                                onTap: () => context.go('/transactions'),
                              ),
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

int mathMax(int a, int b) => a > b ? a : b;

List<double> _weekSpark(List<TransactionModel> rows) {
  final spark = <double>[];
  for (var i = 6; i >= 0; i--) {
    final day = DateTime.now().subtract(Duration(days: i));
    spark.add(
      rows
          .where(
            (r) =>
                r.transactionDate.year == day.year &&
                r.transactionDate.month == day.month &&
                r.transactionDate.day == day.day,
          )
          .fold<double>(0, (a, b) => a + b.amount),
    );
  }
  return spark;
}

String _txnMeta(TransactionModel row, CardModel? card) {
  final bank = card?.bankName.isNotEmpty == true
      ? card!.bankName
      : (card?.cardName ?? 'CARD');
  final digits = card?.lastFourDigits;
  final tail = digits == null || digits.isEmpty ? bank : '$bank ····$digits';
  final time = EtTxnTime.clock(row.transactionDate);
  return time == null ? tail : '$time · $tail';
}

List<TransactionModel> _rowsForPeriod(
  List<TransactionModel> rows, {
  required SpendPeriodMode mode,
  required DateTime anchor,
  required Map<String, int> billDayByCardId,
  int fallbackBillDay = 1,
}) {
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

class _TopCategoriesCard extends ConsumerWidget {
  const _TopCategoriesCard({
    required this.periodMode,
    required this.anchor,
    required this.billDayByCardId,
    required this.fallbackBillDay,
  });

  final SpendPeriodMode periodMode;
  final DateTime anchor;
  final Map<String, int> billDayByCardId;
  final int fallbackBillDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsListProvider);
    return txAsync.when(
      data: (rows) {
        final monthRows = _rowsForPeriod(
          rows,
          mode: periodMode,
          anchor: anchor,
          billDayByCardId: billDayByCardId,
          fallbackBillDay: fallbackBillDay,
        );
        if (monthRows.isEmpty) {
          return EtSurfaceCard(
            child: Text(
              periodMode == SpendPeriodMode.billingCycle
                  ? 'No category spend this billing cycle yet.'
                  : 'No category spend this month yet.',
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          );
        }
        final totals = <String, double>{};
        for (final row in monthRows) {
          totals[row.category] = (totals[row.category] ?? 0) + row.amount;
        }
        final top = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final items = top.take(3).toList();
        final maxV = items.first.value;
        return EtSurfaceCard(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    EtCategoryBadge(
                      category: items[i].key,
                      size: 30,
                      iconSize: 17,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  items[i].key,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                EtMoney.format(items[i].value),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: maxV == 0 ? 0 : items[i].value / maxV,
                              minHeight: 4,
                              backgroundColor: AppColors.hairline,
                              color: AppCategoryStyle.colorFor(items[i].key),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _SmsEmptyState extends ConsumerStatefulWidget {
  const _SmsEmptyState({required this.billingCycle});

  final bool billingCycle;

  @override
  ConsumerState<_SmsEmptyState> createState() => _SmsEmptyStateState();
}

class _SmsEmptyStateState extends ConsumerState<_SmsEmptyState> {
  bool _busy = false;

  Future<void> _runSample() async {
    setState(() => _busy = true);
    try {
      final result = await ReviewerDemoService(ref).importSampleDebitSms();
      if (!mounted) return;
      final message = switch (result) {
        ReviewerDemoImportResult.created =>
          'Sample bank debit SMS parsed: FOODPANDA Rs 1,250',
        ReviewerDemoImportResult.alreadyExists =>
          'That sample SMS is already in your transactions.',
        ReviewerDemoImportResult.failed =>
          'Could not parse the sample SMS. Check SMS permissions and try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not parse sample SMS: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EtSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.billingCycle
                ? 'No bank SMS expenses in this billing cycle.'
                : 'No bank SMS found for this month.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'This app reads debit SMS from your bank or card and turns matching messages into expenses. If this phone has no bank alerts, try a sample debit SMS.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _busy ? null : _runSample,
              child: Text(
                _busy ? 'Parsing sample SMS...' : 'Try a sample debit SMS',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
