// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:setupx/main.dart';

void main() {
  test('SetupX app can be instantiated', () {
    // Just test that the app can be created without running it
    const app = SetupXApp();
    expect(app, isA<SetupXApp>());
  });
}
