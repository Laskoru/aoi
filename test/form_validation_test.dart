import 'package:aoi/features/plants/plant_form_screen.dart';
import 'package:aoi/features/pond/fish_group_form_screen.dart';
import 'package:aoi/features/pond/pond_form_screen.dart';
import 'package:aoi/features/water/add_measurement_screen.dart';
import 'package:aoi/models/pond.dart';
import 'package:aoi/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// Les vrais formulaires, enregistrés depuis leur bouton tout en bas avec un
// champ obligatoire vide tout en haut. L'envoi doit s'arrêter avant le
// serveur : Firebase n'est pas initialisé ici, et le moindre appel ferait
// échouer le test. Le message du champ doit être à l'écran.

Future<void> _saveFromBottom(
  WidgetTester tester,
  Widget screen,
  String button,
) async {
  // Un téléphone, clavier ouvert : le haut du formulaire sort de l'écran.
  tester.view.physicalSize = const Size(360, 400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.light(), home: screen));
  final save = find.text(button);
  await tester.scrollUntilVisible(
    save,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(save);
  await tester.pumpAndSettle();
}

void _expectOnScreen(WidgetTester tester, Finder finder) {
  final screen = Offset.zero & tester.view.physicalSize;
  final rect = tester.getRect(finder);
  expect(
    screen.contains(rect.topLeft) && screen.contains(rect.bottomRight),
    isTrue,
    reason: '$finder hors de l’écran : $rect',
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('plante sans nom', (tester) async {
    await _saveFromBottom(tester, const PlantFormScreen(), 'Ajouter la plante');
    _expectOnScreen(tester, find.text('Veuillez entrer un nom'));
  });

  testWidgets('autres habitants sans espèce', (tester) async {
    await _saveFromBottom(
      tester,
      const FishGroupFormScreen(),
      'Ajouter le groupe',
    );
    _expectOnScreen(tester, find.text("Veuillez entrer l'espèce"));
  });

  testWidgets('mesure sans pH ni température', (tester) async {
    await _saveFromBottom(
      tester,
      const AddMeasurementScreen(),
      'Enregistrer la mesure',
    );
    expect(find.text('Obligatoire'), findsNWidgets(2));
    _expectOnScreen(tester, find.text('Obligatoire').first);
  });

  testWidgets('bassin sans nom', (tester) async {
    await _saveFromBottom(
      tester,
      const PondFormScreen(
        pond: Pond(id: 'default_test', userId: 'test', name: ''),
      ),
      'Enregistrer',
    );
    _expectOnScreen(tester, find.text('Veuillez entrer un nom'));
  });
}
