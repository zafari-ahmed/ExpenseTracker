import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/service_providers.dart';
import '../../../categories/data/repositories/categories_repository.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transactions_repository.dart';

class TransactionFilters {
  const TransactionFilters({
    this.cardId,
    this.category,
    this.fromDate,
    this.toDate,
  });

  final String? cardId;
  final String? category;
  final DateTime? fromDate;
  final DateTime? toDate;

  TransactionFilters copyWith({
    String? cardId,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return TransactionFilters(
      cardId: cardId ?? this.cardId,
      category: category ?? this.category,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}

final transactionFilterProvider = StateProvider<TransactionFilters>(
  (ref) => const TransactionFilters(),
);

final transactionsListProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final repo = await ref.watch(transactionsRepositoryProvider.future);
  final filter = ref.watch(transactionFilterProvider);
  return repo.listTransactions(
    cardId: filter.cardId,
    category: filter.category,
    fromDate: filter.fromDate,
    toDate: filter.toDate,
  );
});

final needsReviewProvider = FutureProvider((ref) async {
  final repo = await ref.watch(transactionsRepositoryProvider.future);
  return repo.listNeedsReview();
});

final thisMonthTotalProvider = FutureProvider<double>((ref) async {
  final repo = await ref.watch(transactionsRepositoryProvider.future);
  return repo.totalAmountForMonth(month: DateTime.now());
});

final transactionMutationsProvider = Provider<TransactionMutations>((ref) {
  return TransactionMutations(ref);
});

class TransactionMutations {
  TransactionMutations(this._ref);

  final Ref _ref;
  static const _uuid = Uuid();

  Future<void> addManual({
    required String cardId,
    required double amount,
    required String place,
    required String description,
    required DateTime date,
    String rawSmsBody = '',
  }) async {
    final repo = await _ref.read(transactionsRepositoryProvider.future);
    final categoryRepo = await _ref.read(categoriesRepositoryProvider.future);
    final category = await categoryRepo.autoCategoryFromPlace(place);
    final row = TransactionModel()
      ..id = _uuid.v4()
      ..cardId = cardId
      ..amount = amount
      ..place = place
      ..description = description
      ..category = category?.name ?? 'Uncategorized'
      ..rawSmsBody = rawSmsBody
      ..transactionDate = date
      ..createdAt = DateTime.now()
      ..source = TransactionSource.manual;
    await repo.upsertTransaction(row);
    final thresholdService = await _ref.read(thresholdAlertServiceProvider.future);
    await thresholdService.checkForCategoryThreshold(
      categoryName: row.category,
      forMonth: row.transactionDate,
    );
    _refresh();
  }

  Future<void> updateDetails({
    required String transactionId,
    required String place,
    required String description,
    required String category,
  }) async {
    final repo = await _ref.read(transactionsRepositoryProvider.future);
    await repo.updateTransactionDetails(
      transactionId: transactionId,
      place: place,
      description: description,
      category: category,
    );
    _refresh();
  }

  Future<void> delete(String transactionId) async {
    final repo = await _ref.read(transactionsRepositoryProvider.future);
    await repo.deleteTransaction(transactionId);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(transactionsListProvider);
    _ref.invalidate(thisMonthTotalProvider);
    _ref.invalidate(needsReviewProvider);
  }
}
