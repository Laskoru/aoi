import 'package:aoi/l10n/l10n.dart';
import 'package:aoi/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Un écran de l'appli prêt à tester : thème et textes, en français par
/// défaut, comme pour un téléphone réglé en français.
Widget testApp(Widget home, {Locale locale = const Locale('fr')}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    supportedLocales: appLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}
