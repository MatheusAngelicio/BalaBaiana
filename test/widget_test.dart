import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bala_baiana/main.dart';

void main() {
  testWidgets('renders an empty home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
