import 'package:flutter_test/flutter_test.dart';

import 'package:rota/main.dart';

void main() {
  testWidgets('Rota shows home title', (WidgetTester tester) async {
    await tester.pumpWidget(const RotaApp());
    expect(find.text('Rota'), findsOneWidget);
    expect(find.text('Sonraki rotanı bul'), findsOneWidget);
  });
}
