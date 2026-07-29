import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cards_provider.dart';

class CardSetupScreen extends ConsumerWidget {
  const CardSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
        actions: [
          IconButton(
            onPressed: () => context.push('/cards/form'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/cards/form'),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No cards yet.\nAdd a card, then paste one sample bank SMS so future expenses can auto-detect.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final card = cards[index];
              final ruleAsync = ref.watch(parsingRuleByCardProvider(card.id));
              final hasRule = ruleAsync.maybeWhen(
                data: (rule) => rule != null,
                orElse: () => false,
              );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          child: Text(
                            card.bankName.isNotEmpty ? card.bankName.characters.first : '?',
                          ),
                        ),
                        title: Text(card.cardName),
                        subtitle: Text('${card.bankName} • Sender: ${card.smsSenderId}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              context.push('/cards/form?cardId=${card.id}');
                            } else if (value == 'delete') {
                              await ref.read(cardMutationsProvider).deleteCard(card.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasRule
                            ? 'SMS format configured — auto-detect ready'
                            : 'SMS sample not set — auto-detect unavailable',
                        style: TextStyle(
                          color: hasRule
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () =>
                              context.push('/cards/sms-config?cardId=${card.id}'),
                          icon: const Icon(Icons.sms_outlined),
                          label: Text(hasRule ? 'Edit SMS Sample' : 'Add Sample SMS'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
