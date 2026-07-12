import 'package:flutter_test/flutter_test.dart';
import 'package:transitops_frontend/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash page is displayed
    expect(find.text('TransitOps'), findsOneWidget);

    // Pump the timer duration to allow the splash delay to complete
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
