import 'package:intl/intl.dart';

/// Edit the strings in this file to change all push / local notification text.
///
/// Placeholders use {name} syntax and are filled by the helper methods below.
class NotificationMessages {
  NotificationMessages._();

  // ── Expense added (SMS auto-save) ─────────────────────────────────────────

  static const expenseAddedTitle = 'Expense added';

  /// Body when place/merchant is known.
  /// Placeholders: {amount}, {category}, {place}
  static const expenseAddedBodyWithPlace =
      '{amount} spent at {place} · saved under {category}';

  /// Body when place is empty.
  /// Placeholders: {amount}, {category}
  static const expenseAddedBody =
      '{amount} added under {category}';

  // ── Category threshold ────────────────────────────────────────────────────

  static const thresholdWarningTitle = 'Category limit warning';

  /// Placeholders: {category}, {percent}, {spent}, {limit}
  static const thresholdWarningBody =
      '{category} is at {percent}% of your limit ({spent} of {limit})';

  static const thresholdExceededTitle = 'Category limit exceeded';

  /// Placeholders: {category}, {percent}, {spent}, {limit}
  static const thresholdExceededBody =
      '{category} has exceeded your limit ({spent} of {limit})';

  // ── Bill reminder ─────────────────────────────────────────────────────────

  static const billReminderTitle = 'Bill date reminder';

  /// Placeholders: {cardName}, {days}, {billDate}
  static const billReminderBodyDays =
      '{cardName} bill date is in {days} day(s) (day {billDate} of the month)';

  /// Placeholders: {cardName}, {billDate}
  static const billReminderBodyToday =
      '{cardName} bill date is today (day {billDate})';

  // ── Notification channel labels (Android) ─────────────────────────────────

  static const channelExpenseName = 'Expense alerts';
  static const channelExpenseDescription =
      'When a new expense is saved from SMS';

  static const channelThresholdName = 'Spending limits';
  static const channelThresholdDescription =
      'When you are close to or over a category limit';

  static const channelBillName = 'Bill reminders';
  static const channelBillDescription =
      'Reminders before your card billing date';

  // ── Formatters ────────────────────────────────────────────────────────────

  static final NumberFormat _money =
      NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);

  static String money(num value) => _money.format(value);

  static String _apply(String template, Map<String, String> values) {
    var out = template;
    for (final entry in values.entries) {
      out = out.replaceAll('{${entry.key}}', entry.value);
    }
    return out;
  }

  static String expenseAdded({
    required double amount,
    required String category,
    String place = '',
  }) {
    final trimmedPlace = place.trim();
    if (trimmedPlace.isEmpty) {
      return _apply(expenseAddedBody, {
        'amount': money(amount),
        'category': category,
      });
    }
    return _apply(expenseAddedBodyWithPlace, {
      'amount': money(amount),
      'category': category,
      'place': trimmedPlace,
    });
  }

  static String thresholdWarning({
    required String category,
    required int percent,
    required double spent,
    required double limit,
  }) =>
      _apply(thresholdWarningBody, {
        'category': category,
        'percent': '$percent',
        'spent': money(spent),
        'limit': money(limit),
      });

  static String thresholdExceeded({
    required String category,
    required int percent,
    required double spent,
    required double limit,
  }) =>
      _apply(thresholdExceededBody, {
        'category': category,
        'percent': '$percent',
        'spent': money(spent),
        'limit': money(limit),
      });

  static String billReminder({
    required String cardName,
    required int billDate,
    required int daysUntil,
  }) {
    if (daysUntil <= 0) {
      return _apply(billReminderBodyToday, {
        'cardName': cardName,
        'billDate': '$billDate',
      });
    }
    return _apply(billReminderBodyDays, {
      'cardName': cardName,
      'days': '$daysUntil',
      'billDate': '$billDate',
    });
  }
}
