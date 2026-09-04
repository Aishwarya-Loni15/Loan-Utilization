import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laon/app/app.dart';

void main() {
  testWidgets('Laon Utilization app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LaonUtilizationApp(),
      ),
    );

    expect(find.byType(LaonUtilizationApp), findsOneWidget);
  });
}
