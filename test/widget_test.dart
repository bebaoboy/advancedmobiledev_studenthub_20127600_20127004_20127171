// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/firebase_options.dart';
import 'package:boilerplate/main.dart';
import 'package:boilerplate/presentation/my_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await setPreferredOrientations();
    await ServiceLocator.configureDependencies();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
  });
}
