import '../../features/transactions/data/models/transaction_model.dart';

enum SmsProcessKind {
  none,
  needsReview,
  expenseAdded,
}

class SmsProcessResult {
  const SmsProcessResult._({
    required this.kind,
    this.transaction,
    this.cardName,
  });

  const SmsProcessResult.none() : this._(kind: SmsProcessKind.none);

  const SmsProcessResult.needsReview()
      : this._(kind: SmsProcessKind.needsReview);

  const SmsProcessResult.expenseAdded({
    required TransactionModel transaction,
    required String cardName,
  }) : this._(
          kind: SmsProcessKind.expenseAdded,
          transaction: transaction,
          cardName: cardName,
        );

  final SmsProcessKind kind;
  final TransactionModel? transaction;
  final String? cardName;

  bool get created =>
      kind == SmsProcessKind.needsReview || kind == SmsProcessKind.expenseAdded;
}
