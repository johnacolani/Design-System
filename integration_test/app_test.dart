import 'package:design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Pumps frames for a bounded time so the app has time to build and paint.
Future<void> _pumpFrames(WidgetTester tester, {int seconds = 2}) async {
  for (var i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// Wait until the home screen is visible (max [maxSeconds]).
Future<void> _waitForAppToPaint(WidgetTester tester, {int maxSeconds = 8}) async {
  for (var i = 0; i < maxSeconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (find.text('Get started').evaluate().isNotEmpty ||
        find.text('Design System Builder').evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows home content', (WidgetTester tester) async {
    await tester.pumpWidget(const DesignSystemApp());
    await _waitForAppToPaint(tester, maxSeconds: 8);

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('home screen has scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const DesignSystemApp());
    await _waitForAppToPaint(tester, maxSeconds: 8);

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets(
    'full flow: Get started → Guest → project name → Create and continue → description → app info → Next color scheme',
    (WidgetTester tester) async {
      await tester.pumpWidget(const DesignSystemApp());
      await _waitForAppToPaint(tester, maxSeconds: 8);

      // 1. Get started
      await tester.tap(find.text('Get started').first);
      await _pumpFrames(tester, seconds: 2);

      // 2. Continue as Guest
      await tester.tap(find.text('Continue as Guest'));
      await _pumpFrames(tester, seconds: 2);

      // 3. Create New Project: add project name
      await tester.enterText(find.byType(TextField).first, 'E2E Test Design System');
      await tester.pump(const Duration(milliseconds: 300));

      // 4. Click Create and continue
      await tester.tap(find.text('Create and continue'));
      await _pumpFrames(tester, seconds: 3);

      // 5. Onboarding Step 1: add description, then click Next: Tell us about your app
      final textFields = find.byType(TextField);
      expect(textFields.evaluate().length, greaterThanOrEqualTo(2));
      await tester.enterText(textFields.at(1), 'Design system for E2E testing.');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Next: Tell us about your app'));
      await _pumpFrames(tester, seconds: 2);

      // 6. Onboarding Step 2: choose Creative, All Ages, Modern; click Next: Choose Color Scheme
      await tester.tap(find.text('Creative').first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('All Ages').first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Modern').first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Next: Choose Color Scheme'));
      await _pumpFrames(tester, seconds: 2);

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('Choose your color scheme'), findsWidgets);
    },
  );
}
