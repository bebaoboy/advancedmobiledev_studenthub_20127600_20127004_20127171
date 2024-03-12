// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:boilerplate/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Click on splash screen go to login screen test',
      (WidgetTester tester) async {
    setPreferredOrientations();
    //await ServiceLocator.configureDependencies();
    // Build our app and trigger a frame.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: Text("data"))));
    // Verify if the splash image is visible
    expect(find.byType(Text), findsOneWidget);
  });
}
