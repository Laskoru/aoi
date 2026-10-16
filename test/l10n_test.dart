import 'dart:convert';
import 'dart:io';

import 'package:aoi/l10n/l10n.dart';
import 'package:aoi/models/pond.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

/// Les textes d'une langue, sans les métadonnées (@clé, @@locale).
Map<String, String> _messages(String lang) => {
  for (final entry in _arb(lang).entries)
    if (!entry.key.startsWith('@')) entry.key: entry.value as String,
};

/// Les variables d'un texte : « {name} », « {count, plural, …} » donnent
/// name et count.
Set<String> _placeholders(String message) => RegExp(r'\{(\w+)[,}]')
    .allMatches(message)
    .map((m) => m.group(1)!)
    .where((name) => !const {'one', 'other', 'zero', 'two', 'few', 'many'}.contains(name))
    .toSet();

void main() {
  final fr = _messages('fr');
  final en = _messages('en');

  test('chaque texte existe dans les deux langues', () {
    expect(en.keys.toSet().difference(fr.keys.toSet()), isEmpty);
    expect(fr.keys.toSet().difference(en.keys.toSet()), isEmpty);
  });

  test('les deux langues ont les mêmes variables', () {
    for (final key in fr.keys) {
      expect(
        _placeholders(en[key]!),
        _placeholders(fr[key]!),
        reason: key,
      );
    }
  });

  test("l'anglais ne laisse pas passer de texte resté en français", () {
    // Quelques mots qui trahiraient une traduction oubliée.
    final french = RegExp(r"\b(le|la|les|des|une|vos|votre|été|être)\b|[éèàùç]");
    final leftovers = [
      for (final entry in en.entries)
        if (french.hasMatch(entry.value)) '${entry.key} : ${entry.value}',
    ];
    expect(leftovers, isEmpty);
  });

  group('nom du bassin', () {
    final frL = lookupAppLocalizations(const Locale('fr'));
    final enL = lookupAppLocalizations(const Locale('en'));
    Pond pond(String name) => Pond(id: 'p', userId: 'u', name: name);

    test("le bassin créé d'office porte le nom de la langue", () {
      expect(pond('').displayName(frL), 'Mon bassin');
      expect(pond('').displayName(enL), 'My pond');
    });

    test('l\'ancien nom enregistré en français se traduit', () {
      expect(pond(Pond.legacyDefaultName).displayName(enL), 'My pond');
    });

    test("un nom choisi par l'utilisateur ne change pas", () {
      expect(pond('Étang du fond').displayName(enL), 'Étang du fond');
    });
  });

  group('choix de la langue', () {
    test('suit la première langue du téléphone que l\'appli parle', () {
      expect(
        resolveAppLocale(const [Locale('de'), Locale('fr', 'BE')], appLocales),
        const Locale('fr', 'BE'),
      );
      expect(
        resolveAppLocale(const [Locale('en', 'GB')], appLocales),
        const Locale('en', 'GB'),
      );
    });

    test("passe à l'anglais pour les autres langues", () {
      expect(
        resolveAppLocale(const [Locale('de'), Locale('ja')], appLocales),
        const Locale('en'),
      );
      expect(resolveAppLocale(null, appLocales), const Locale('en'));
    });
  });
}
