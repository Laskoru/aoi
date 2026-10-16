import 'package:aoi/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Finder _buttonOf(Finder label) =>
    find.ancestor(of: label, matching: find.bySubtype<ElevatedButton>());

void main() {
  testWidgets(
    'sur iPhone, Apple est proposé au-dessus de Google, aussi grand',
    (tester) async {
      await tester.pumpWidget(testApp(const LoginScreen()));
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
      await tester.pumpWidget(testApp(const LoginScreen()));
      expect(find.text('Se connecter avec Apple'), findsNothing);
      expect(find.text('Se connecter avec Google'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'en anglais sur un téléphone réglé en anglais',
    (tester) async {
      await tester.pumpWidget(
        testApp(const LoginScreen(), locale: const Locale('en')),
      );
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Your pond journal'), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
}
