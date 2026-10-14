import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../../core/utils/period_range.dart';
import '../../../../core/widgets/stitch_widgets.dart';
import '../../../settings/presentation/providers/preferences_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../data/models/card_model.dart';
import '../providers/cards_provider.dart';

class CardSetupScreen extends ConsumerWidget {
  const CardSetupScreen({super.key});

  Future<void> _deleteAllTransactions(
    BuildContext context,
    WidgetRef ref, {
    required String cardId,
    required String cardName,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all transactions?'),
        content: Text(
          'This permanently deletes every transaction for "$cardName". This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final deleted =
        await ref.read(transactionMutationsProvider).deleteAllForCard(cardId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted == 0
              ? 'No transactions found for this card'
              : 'Deleted $deleted transaction(s) for $cardName',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currencyProvider);
    final cardsAsync = ref.watch(cardsListProvider);
    final txAsync = ref.watch(transactionsListProvider);
    final periodMode =
        ref.watch(spendPeriodModeProvider).valueOrNull ?? SpendPeriodMode.monthly;
    final month = DateTime(DateTime.now().year, DateTime.now().month);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      'Cards',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push('/cards/form'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: cardsAsync.when(
                data: (cards) {
                  if (cards.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'No cards yet.\nAdd a card, then paste one sample bank SMS so future expenses can auto-detect.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: () => context.push('/cards/form'),
                              child: const Text('Add a card'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final rows = txAsync.valueOrNull ?? const <TransactionModel>[];
                  final totals = <String, double>{};
                  for (final card in cards) {
                    final anchor = PeriodHelper.resolveAnchor(
                      selectedMonth: month,
                      mode: periodMode,
                    );
                    totals[card.id] = rows
                        .where(
                          (r) =>
                              r.cardId == card.id &&
                              PeriodHelper.isInPeriod(
                                date: r.transactionDate,
                                mode: periodMode,
                                anchor: anchor,
                                billDay: card.billDate,
                              ),
                        )
                        .fold<double>(0, (a, b) => a + b.amount);
                  }
                  final grand = totals.values.fold<double>(0, (a, b) => a + b);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        _DeckCard(
                          card: cards[i],
                          spend: totals[cards[i].id] ?? 0,
                          onMenu: (value) async {
                            if (value == 'edit') {
                              context.push('/cards/form?cardId=${cards[i].id}');
                            } else if (value == 'sms') {
                              context.push(
                                '/cards/sms-config?cardId=${cards[i].id}',
                              );
                            } else if (value == 'wipe') {
                              await _deleteAllTransactions(
                                context,
                                ref,
                                cardId: cards[i].id,
                                cardName: cards[i].cardName,
                              );
                            } else if (value == 'delete') {
                              await ref
                                  .read(cardMutationsProvider)
                                  .deleteCard(cards[i].id);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      if (grand > 0)
                        EtSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const EtLabelCaps('CARD SPLIT'),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: SizedBox(
                                  height: 8,
                                  child: Row(
                                    children: [
                                      for (var i = 0; i < cards.length; i++)
                                        if ((totals[cards[i].id] ?? 0) > 0)
                                          Expanded(
                                            flex: ((totals[cards[i].id] ?? 0) *
                                                    100)
                                                .round()
                                                .clamp(1, 10000),
                                            child: Container(
                                              color: AppColors.cardThemes[
                                                  i %
                                                      AppColors
                                                          .cardThemes.length],
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 14,
                                children: [
                                  for (var i = 0; i < cards.length; i++)
                                    EtLabelCaps(
                                      '${cards[i].bankName.isEmpty ? cards[i].cardName : cards[i].bankName} ${((totals[cards[i].id] ?? 0) / grand * 100).toStringAsFixed(0)}%',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
                error: (error, stack) => Center(child: Text('Error: $error')),
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

class _DeckCard extends ConsumerWidget {
  const _DeckCard({
    required this.card,
    required this.spend,
    required this.onMenu,
  });

  final CardModel card;
  final double spend;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.themeForCardIcon(card.cardIcon);
    final onColor = Colors.white;
    final digits = card.lastFourDigits ?? '----';
    final ruleAsync = ref.watch(parsingRuleByCardProvider(card.id));
    final hasRule = ruleAsync.maybeWhen(
      data: (rule) => rule != null,
      orElse: () => false,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
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
                      card.cardName,
                      style: GoogleFonts.archivo(
                        color: onColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${card.bankName.toUpperCase()} · ····$digits',
                      style: GoogleFonts.ibmPlexMono(
                        color: onColor.withValues(alpha: 0.75),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: onColor.withValues(alpha: 0.75)),
                onSelected: onMenu,
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'sms',
                    child: Text(hasRule ? 'Edit SMS sample' : 'Add sample SMS'),
                  ),
                  const PopupMenuItem(
                    value: 'wipe',
                    child: Text('Delete all transactions'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete card')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          EtLabelCaps('SPENT THIS PERIOD', color: onColor.withValues(alpha: 0.75)),
          const SizedBox(height: 4),
          Text(
            EtMoney.format(spend),
            style: GoogleFonts.archivo(
              color: onColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
