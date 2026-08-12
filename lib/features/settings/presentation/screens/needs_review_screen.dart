import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/design_tokens.dart';
import '../../../cards/presentation/providers/cards_provider.dart';
import '../../../categories/data/repositories/categories_repository.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transactions_provider.dart';
import '../../../transactions/data/repositories/transactions_repository.dart';

class NeedsReviewScreen extends ConsumerWidget {
  const NeedsReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(needsReviewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Needs Review')),
      body: reviewsAsync.when(
        data: (rows) {
          if (rows.isEmpty) {
            return const Center(child: Text('No failed SMS items.'));
          }
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(row.senderId),
                  subtitle: Text(row.rawSmsBody),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Map fields',
                        onPressed: () => _openMappingDialog(
                          context,
                          ref,
                          row.id,
                          row.cardId,
                          row.rawSmsBody,
                        ),
                        icon: const Icon(Icons.edit_note_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(context, ref, row.id),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (e, s) => Center(child: Text('Error: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete review item?'),
        content: const Text(
          'This removes the failed SMS from Needs Review. It will not create a transaction.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(transactionMutationsProvider).removeNeedsReview(reviewId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review item deleted')),
      );
    }
  }

  Future<void> _openMappingDialog(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
    String cardId,
    String rawSms,
  ) async {
    final amountCtrl = TextEditingController();
    final placeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Uncategorized';
    var rememberForFuture = true;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manual Field Mapping'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rawSms),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                TextField(
                  controller: placeCtrl,
                  decoration: const InputDecoration(labelText: 'Place'),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final categoriesAsync = ref.watch(categoriesProvider);
                    return categoriesAsync.when(
                      data: (cats) => DropdownButtonFormField<String>(
                        initialValue: category,
                        items: cats
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.name,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            category = value ?? 'Uncategorized',
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      error: (e, s) => Text('Error: $e'),
                      loading: () => const LinearProgressIndicator(),
                    );
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: rememberForFuture,
                  onChanged: (value) => setDialogState(
                    () => rememberForFuture = value ?? true,
                  ),
                  title: const Text('Remember for future'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text.trim());
                if (amount == null) {
                  return;
                }
                final place = placeCtrl.text.trim();
                final repo =
                    await ref.read(transactionsRepositoryProvider.future);
                final tx = TransactionModel()
                  ..id = const Uuid().v4()
                  ..cardId = cardId
                  ..amount = amount
                  ..place = place
                  ..description = descCtrl.text.trim()
                  ..category = category
                  ..rawSmsBody = rawSms
                  ..transactionDate = DateTime.now()
                  ..createdAt = DateTime.now()
                  ..source = TransactionSource.sms;
                await repo.upsertTransaction(tx);
                await repo.removeNeedsReview(reviewId);

                if (rememberForFuture && place.isNotEmpty) {
                  final categoryRepo =
                      await ref.read(categoriesRepositoryProvider.future);
                  await categoryRepo.learnPlaceForCategory(
                    place: place,
                    categoryName: category,
                  );
                  await repo.applyCategoryToUncategorizedPlace(
                    place: place,
                    category: category,
                    excludeTransactionId: tx.id,
                  );
                  ref.invalidate(categoriesProvider);
                }

                ref.invalidate(transactionsListProvider);
                ref.invalidate(needsReviewProvider);
                ref.invalidate(cardsListProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save Mapping'),
            ),
          ],
        ),
      ),
    );
  }
}
