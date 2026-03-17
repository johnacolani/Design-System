import 'package:design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

/// Pumps frames for a bounded time so the app has time to build and paint.
/// Use after pumpWidget so the second test (and later runs) don't see a blank screen.
Future<void> _pumpFrames(WidgetTester tester, {int seconds = 2}) async {
  for (var i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  patrolTest(
    'app starts and shows home content',
    tags: const ['smoke'],
    ($) async {
      await $.pumpWidget(const DesignSystemApp());
      await _pumpFrames($.tester, seconds: 2);

      expect(find.byType(Scaffold), findsWidgets);
      await Future.delayed(const Duration(seconds: 2));
    },
  );

  patrolTest(
    'home screen has scaffold',
    tags: const ['smoke'],
    ($) async {
      await $.pumpWidget(const DesignSystemApp());
      // Give the app time to paint (each test gets a fresh app; second test was blank without this)
      await _pumpFrames($.tester, seconds: 2);

      expect(find.byType(Scaffold), findsWidgets);
    },
  );

  // Short navigation test only (no form submit/onboarding) to avoid browser crash.
  patrolTest(
    'navigate from home to Create New Project screen',
    ($) async {
      await $.pumpWidget(const DesignSystemApp());
      await _pumpFrames($.tester, seconds: 2);

      await $.tester.tap(find.text('Get started').first);
      await _pumpFrames($.tester, seconds: 2);

      await $.tester.tap(find.text('Continue as Guest'));
      await _pumpFrames($.tester, seconds: 2);

      // We should be on Create New Project screen
      expect(find.text('Project name *'), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    },
  );
}
