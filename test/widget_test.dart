import 'package:flutter_test/flutter_test.dart';
import 'package:click_clack/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClickClackApp());
    expect(find.text('Click & Clack'), findsOneWidget);
  });
}
