import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';
export 'labels.dart';

/// Les langues de l'appli. La première sert pour toute langue du téléphone
/// qu'elle ne parle pas.
const appLocales = [Locale('en'), Locale('fr')];

/// Choisit la langue de l'interface parmi celles du téléphone, dans son ordre
/// de préférence, et garde la région : « en_GB » écrit ses dates à
/// l'anglaise, « en_US » à l'américaine. L'anglais à défaut.
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    if (supported.any((s) => s.languageCode == locale.languageCode)) {
      return locale;
    }
  }
  return appLocales.first;
}

extension L10nContext on BuildContext {
  /// Les textes de l'appli dans la langue de l'interface.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// La langue de l'interface, région comprise, pour formater les dates.
  String get localeName => Localizations.localeOf(this).toString();
}
