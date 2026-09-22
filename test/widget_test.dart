import 'package:flutter_test/flutter_test.dart';

import 'package:bala_baiana/main.dart';

void main() {
  testWidgets('renders the app navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Calcular nova produção'), findsOneWidget);
    expect(find.text('Compras'), findsOneWidget);
    expect(find.text('Receitas'), findsOneWidget);
    expect(find.text('Produções'), findsOneWidget);
  });
}
