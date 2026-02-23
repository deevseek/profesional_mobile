import 'package:flutter_test/flutter_test.dart';
import 'package:profesionalservis_mobile/main.dart';

void main() {
  testWidgets('renders app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProfesionalServisApp());
    await tester.pumpAndSettle();

    expect(find.text('Profesional Servis'), findsOneWidget);
    expect(find.text('Kasir Cepat'), findsOneWidget);
  });
}
