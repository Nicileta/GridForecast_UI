import 'package:flutter_test/flutter_test.dart';
import 'package:prototip_ui/main.dart';

void main() {
  testWidgets('GridForecast smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GridForecastApp());
    expect(find.text('GridForecast'), findsOneWidget);
  });
}