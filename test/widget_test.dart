// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:afran_project/main.dart';

void main() {
  testWidgets('App loads and displays the main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the main screen appears with its navigation bar
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Verify that the home screen is the default
    expect(find.text('Home'), findsOneWidget);
  });
}
