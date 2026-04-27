import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Adaptive English Learning App')),
        ),
      ),
    );

    expect(find.text('Adaptive English Learning App'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
