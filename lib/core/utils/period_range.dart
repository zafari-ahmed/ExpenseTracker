enum SpendPeriodMode {
  monthly,
  billingCycle,
}

extension SpendPeriodModeX on SpendPeriodMode {
  String get storageValue => switch (this) {
        SpendPeriodMode.monthly => 'monthly',
        SpendPeriodMode.billingCycle => 'billing_cycle',
      };

  String get label => switch (this) {
        SpendPeriodMode.monthly => 'Calendar month',
        SpendPeriodMode.billingCycle => 'Billing cycle',
      };

  static SpendPeriodMode fromStorage(String? value) {
    if (value == SpendPeriodMode.billingCycle.storageValue) {
      return SpendPeriodMode.billingCycle;
    }
    return SpendPeriodMode.monthly;
  }
}

/// Inclusive start, exclusive end.
class PeriodRange {
  const PeriodRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(end);

  String get shortLabel {
    final sameMonth = start.month == end.month && start.year == end.year;
    if (sameMonth && start.day == 1) {
      // Calendar month style when end is next month day 1.
      final monthEnd = DateTime(start.year, start.month + 1);
      if (end == monthEnd) {
        return _monthYear(start);
      }
    }
    final endInclusive = end.subtract(const Duration(milliseconds: 1));
    return '${_dayMonth(start)} – ${_dayMonth(endInclusive)}';
  }

  String get monthStyleLabel {
    final endInclusive = end.subtract(const Duration(milliseconds: 1));
    if (start.day == 1 &&
        end.day == 1 &&
        end == DateTime(start.year, start.month + 1)) {
      return _monthYear(start);
    }
    return '${_dayMonth(start)} – ${_dayMonth(endInclusive)}';
  }

  static String _monthYear(DateTime d) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  static String _dayMonth(DateTime d) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class PeriodHelper {
  const PeriodHelper._();

  static int clampBillDay(int billDay, int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final day = billDay < 1 ? 1 : billDay;
    return day > daysInMonth ? daysInMonth : day;
  }

  /// Calendar month for [anchor] (day ignored aside from year/month).
  static PeriodRange calendarMonth(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month);
    final end = DateTime(anchor.year, anchor.month + 1);
    return PeriodRange(start: start, end: end);
  }

  /// Billing cycle that contains [anchor], starting on [billDay] each month.
  /// Example billDay=20, anchor=Aug 12 → Jul 20 .. Aug 20
  /// Example billDay=20, anchor=Aug 25 → Aug 20 .. Sep 20
  static PeriodRange billingCycle(DateTime anchor, int billDay) {
    final dayThisMonth = clampBillDay(billDay, anchor.year, anchor.month);
    final DateTime start;
    if (anchor.day >= dayThisMonth) {
      start = DateTime(anchor.year, anchor.month, dayThisMonth);
    } else {
      final prevMonth = DateTime(anchor.year, anchor.month - 1);
      final dayPrev = clampBillDay(billDay, prevMonth.year, prevMonth.month);
      start = DateTime(prevMonth.year, prevMonth.month, dayPrev);
    }
    final nextMonth = DateTime(start.year, start.month + 1);
    final dayNext = clampBillDay(billDay, nextMonth.year, nextMonth.month);
    final end = DateTime(nextMonth.year, nextMonth.month, dayNext);
    return PeriodRange(start: start, end: end);
  }

  static PeriodRange forMode({
    required SpendPeriodMode mode,
    required DateTime anchor,
    int billDay = 1,
  }) {
    return switch (mode) {
      SpendPeriodMode.monthly => calendarMonth(anchor),
      SpendPeriodMode.billingCycle => billingCycle(anchor, billDay),
    };
  }

  /// Shift [anchor] by [delta] periods (months or billing cycles).
  static DateTime shiftAnchor(DateTime anchor, int delta) {
    return DateTime(anchor.year, anchor.month + delta, anchor.day);
  }

  /// Resolves which date to use when the UI only stores a year/month selection.
  /// For the current calendar month in billing mode, uses [DateTime.now] so the
  /// active cycle (e.g. 20th→20th) is correct after the bill date.
  static DateTime resolveAnchor({
    required DateTime selectedMonth,
    required SpendPeriodMode mode,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    if (mode == SpendPeriodMode.monthly) {
      return DateTime(selectedMonth.year, selectedMonth.month);
    }
    if (selectedMonth.year == today.year &&
        selectedMonth.month == today.month) {
      return today;
    }
    // Historical months: cycle that starts on the bill day of that month.
    final day = clampBillDay(28, selectedMonth.year, selectedMonth.month);
    return DateTime(selectedMonth.year, selectedMonth.month, day);
  }

  static PeriodRange previousOf(PeriodRange current, SpendPeriodMode mode, int billDay) {
    final prevAnchor = DateTime(
      current.start.year,
      current.start.month,
      current.start.day,
    ).subtract(const Duration(days: 1));
    return forMode(mode: mode, anchor: prevAnchor, billDay: billDay);
  }

  /// Filters [dates] using per-card billing days when in billing-cycle mode.
  static bool isInPeriod({
    required DateTime date,
    required SpendPeriodMode mode,
    required DateTime anchor,
    required int billDay,
  }) {
    return forMode(mode: mode, anchor: anchor, billDay: billDay).contains(date);
  }
}
