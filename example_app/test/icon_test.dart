import 'package:flutter_test/flutter_test.dart';
import 'package:example_app/main.dart';

void main() {
  testWidgets('Icon display test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app shows the expected text
    expect(find.text('Flutter IconFont Generator Demo'), findsOneWidget);
    expect(find.text('Generated Icons:'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // You can add more specific tests for the IconFont widget here
  });
}
