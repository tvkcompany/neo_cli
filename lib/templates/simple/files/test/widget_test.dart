// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:neo/neo.dart';
import 'package:{{_PROJECT_NAME_}}/router/neo_router.dart';

void main() {
  testWidgets('Welcome screen shows correct text', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      ProviderScope(
        child: NeoApp(
          title: "{{_PROJECT_NAME_}}",
          defaultThemeMode: NeoThemeMode.system,
          routerConfig: NeoRouter().config(),
        ),
      ),
    );

    // Wait for navigation and animations to complete
    await tester.pumpAndSettle();

    // Verify that welcome text is present
    expect(find.text("Welcome to Neo"), findsOneWidget);
  });
}
