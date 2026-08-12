import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/isar_instance.dart';
import '../models/needs_review_item_model.dart';
import '../models/transaction_model.dart';

class TransactionsRepository {
  TransactionsRepository(this._isar);

  final Isar _isar;
  static const _uuid = Uuid();

  Future<void> upsertTransaction(TransactionModel transaction) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(transaction);
    });
  }

  Future<void> updateTransactionDetails({
    required String transactionId,
    required String place,
    required String description,
    required String category,
  }) async {
    final current = await getById(transactionId);
    if (current == null) {
      return;
    }

    current
      ..place = place
      ..description = description
      ..category = category;
    await upsertTransaction(current);
  }

  /// Applies [category] to other Uncategorized rows with the same place.
  Future<int> applyCategoryToUncategorizedPlace({
    required String place,
    required String category,
    String? excludeTransactionId,
  }) async {
    final needle = place.trim().toLowerCase();
    if (needle.isEmpty) return 0;
    if (category.trim().isEmpty ||
        category.trim().toLowerCase() == 'uncategorized') {
      return 0;
    }

    final rows = await listTransactions();
    var updated = 0;
    for (final row in rows) {
      if (excludeTransactionId != null && row.id == excludeTransactionId) {
        continue;
      }
      if (row.category.trim().toLowerCase() != 'uncategorized') {
        continue;
      }
      if (row.place.trim().toLowerCase() != needle) {
        continue;
      }
      row.category = category;
      await upsertTransaction(row);
      updated++;
    }
    return updated;
  }

  Future<TransactionModel?> getById(String transactionId) {
    return _isar.transactionModels.filter().idEqualTo(transactionId).findFirst();
  }

  Future<List<TransactionModel>> listTransactions({
    String? cardId,
    String? category,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final rows = await _isar.transactionModels.where().findAll();

    rows.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return rows.where((tx) {
      final cardMatch = cardId == null || cardId.isEmpty || tx.cardId == cardId;
      final categoryMatch =
          category == null || category.isEmpty || tx.category == category;
      final fromMatch = fromDate == null || !tx.transactionDate.isBefore(fromDate);
      final toMatch = toDate == null || !tx.transactionDate.isAfter(toDate);
      return cardMatch && categoryMatch && fromMatch && toMatch;
    }).toList();
  }

  Future<double> totalAmountForMonth({
    String? cardId,
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await listTransactions(
      cardId: cardId,
      fromDate: start,
      toDate: end.subtract(const Duration(milliseconds: 1)),
    );
    return rows.fold<double>(0, (sum, tx) => sum + tx.amount);
  }

  Future<void> deleteTransaction(String transactionId) async {
    final row = await getById(transactionId);
    if (row == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.transactionModels.delete(row.isarId);
    });
  }

  Future<int> deleteAllForCard(String cardId) async {
    return _isar.writeTxn(() async {
      return _isar.transactionModels.filter().cardIdEqualTo(cardId).deleteAll();
    });
  }

  Future<List<NeedsReviewItemModel>> listNeedsReview() {
    return _isar.needsReviewItemModels.where().sortByReceivedAtDesc().findAll();
  }

  Future<void> addNeedsReview({
    required String cardId,
    required String senderId,
    required String rawSmsBody,
    String? parseError,
    DateTime? receivedAt,
  }) async {
    final item = NeedsReviewItemModel()
      ..id = _uuid.v4()
      ..cardId = cardId
      ..senderId = senderId
      ..rawSmsBody = rawSmsBody
      ..receivedAt = receivedAt ?? DateTime.now()
      ..parseError = parseError;

    await _isar.writeTxn(() async {
      await _isar.needsReviewItemModels.put(item);
    });
  }

  Future<void> removeNeedsReview(String reviewId) async {
    final row = await _isar.needsReviewItemModels.filter().idEqualTo(reviewId).findFirst();
    if (row == null) {
      return;
    }
    await _isar.writeTxn(() async {
      await _isar.needsReviewItemModels.delete(row.isarId);
    });
  }

  Future<bool> existsByRawSmsBody(String rawSmsBody) async {
    final body = rawSmsBody.trim();
    if (body.isEmpty) return false;
    final hit = await _isar.transactionModels
        .filter()
        .rawSmsBodyEqualTo(body)
        .findFirst();
    return hit != null;
  }

  Future<bool> existsSimilarSmsTransaction({
    required String cardId,
    required double amount,
    required String place,
    required DateTime transactionDate,
  }) async {
    final dayStart = DateTime(
      transactionDate.year,
      transactionDate.month,
      transactionDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    final rows = await _isar.transactionModels
        .filter()
        .cardIdEqualTo(cardId)
        .sourceEqualTo(TransactionSource.sms)
        .findAll();

    for (final row in rows) {
      if (row.amount != amount) continue;
      if (row.place.toLowerCase() != place.toLowerCase()) continue;
      if (row.transactionDate.isBefore(dayStart)) continue;
      if (!row.transactionDate.isBefore(dayEnd)) continue;
      return true;
    }
    return false;
  }
}

final transactionsRepositoryProvider =
    FutureProvider<TransactionsRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TransactionsRepository(isar);
});
