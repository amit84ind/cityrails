import 'package:flutter_test/flutter_test.dart';
import 'package:cityrails/main.dart';

void main() {
  testWidgets('CityRailsApp loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CityRailsApp());
    expect(find.text('CITYRAILS'), findsOneWidget);
  });
}
