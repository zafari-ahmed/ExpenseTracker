import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Selected month for dashboard calendar filter.
final dashboardMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});
