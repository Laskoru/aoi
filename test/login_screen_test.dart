import 'package:aoi/features/auth/login_screen.dart';
import 'package:aoi/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpLogin(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(theme: AppTheme.light(), home: const LoginScreen()),
);

Finder _buttonOf(Finder label) =>
    find.ancestor(of: label, matching: find.bySubtype<ElevatedButton>());

void main() {
  testWidgets(
    'sur iPhone, Apple est proposé au-dessus de Google, aussi grand',
    (tester) async {
      await _pumpLogin(tester);
      final apple = find.text('Se connecter avec Apple');
      final google = find.text('Se connecter avec Google');

      expect(apple, findsOneWidget);
      expect(google, findsOneWidget);
      expect(
        tester.getSize(_buttonOf(apple)),
        tester.getSize(_buttonOf(google)),
      );
      expect(
        tester.getTopLeft(_buttonOf(apple)).dy,
        lessThan(tester.getTopLeft(_buttonOf(google)).dy),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'sur Android, Google seul',
    (tester) async {
      await _pumpLogin(tester);
      expect(find.text('Se connecter avec Apple'), findsNothing);
      expect(find.text('Se connecter avec Google'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
