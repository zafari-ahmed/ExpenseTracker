import 'package:expense_tracker/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app boots successfully', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ExpenseTrackerApp()),
    );

    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
