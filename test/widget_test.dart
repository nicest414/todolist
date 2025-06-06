// This is a basic Flutter widget test for TODO List app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist_2/main.dart';

void main() {
  testWidgets('TODO List app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Device Previewはテスト環境では無効になるので、MyAppを直接テストします
    await tester.pumpWidget(const MaterialApp(home: MyApp()));

    // TODOリストのタイトルが表示されることを確認
    expect(find.text('TODOリスト'), findsOneWidget);

    // 基本的なUIが表示されることを確認
    await tester.pumpAndSettle();
  });
}
