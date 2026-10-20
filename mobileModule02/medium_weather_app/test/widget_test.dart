import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medium_weather_app/main.dart';

void main() {
  testWidgets('Weather app initial UI test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(TextField), findsOneWidget);

    expect(find.text('Currently'), findsWidgets);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Weekly'), findsWidgets);
  });
}
