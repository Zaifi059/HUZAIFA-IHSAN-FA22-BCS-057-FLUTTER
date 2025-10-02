// This is a basic Flutter widget test for the Calculator app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled/main.dart';

void main() {
  testWidgets('Calculator basic functionality test', (WidgetTester tester) async {
    // Build our calculator app and trigger a frame.
    await tester.pumpWidget(const CalculatorApp());

    // Verify that the calculator display starts at 0.
    expect(find.text('0'), findsOneWidget);

    // Test basic number input
    await tester.tap(find.text('1'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // Test addition operation
    await tester.tap(find.text('+'));
    await tester.pump();
    
    await tester.tap(find.text('2'));
    await tester.pump();
    
    await tester.tap(find.text('='));
    await tester.pump();
    
    // Verify the result is 3
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Calculator clear functionality test', (WidgetTester tester) async {
    // Build our calculator app and trigger a frame.
    await tester.pumpWidget(const CalculatorApp());

    // Input some numbers
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);

    // Test clear function
    await tester.tap(find.text('C'));
    await tester.pump();
    
    // Verify display is back to 0
    expect(find.text('0'), findsOneWidget);
  });
}
