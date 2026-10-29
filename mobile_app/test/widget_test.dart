import 'package:flutter_test/flutter_test.dart';
import 'package:denuncias_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DenunciasApp());
    expect(find.text('Serenazgo - Denuncias'), findsOneWidget);
  });
}
