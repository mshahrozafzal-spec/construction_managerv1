// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:construction_manager/app.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ConstructionManagerApp());

    // Verify that our app launches without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}