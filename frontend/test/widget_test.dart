// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Home screen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FridgeGPTApp());

    // Verify that the app title "FridgeGPT" is displayed.
    expect(find.text('FridgeGPT'), findsOneWidget);

    // Verify that the scan button text is displayed.
    expect(find.text('Scan my fridge'), findsOneWidget);

    // Verify that the settings icon is present.
    expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
