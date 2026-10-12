import 'package:aoi/widgets/form_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un formulaire long : un nom obligatoire en haut, le bouton tout en bas.
Widget _longForm(GlobalKey<FormState> form, {String name = ''}) {
  return MaterialApp(
    home: Scaffold(
      body: Form(
        key: form,
        child: FormBody(
          children: [
            TextFormField(
              initialValue: name,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Veuillez entrer un nom'
                  : null,
            ),
            for (var i = 0; i < 30; i++) const SizedBox(height: 100),
            const Text('Sauvegarder'),
          ],
        ),
      ),
    ),
  );
}

Future<void> _scrollToButton(WidgetTester tester) => tester.scrollUntilVisible(
  find.text('Sauvegarder'),
  300,
  // Le premier : celui du formulaire, pas celui du champ de texte.
  scrollable: find.byType(Scrollable).first,
);

void main() {
  testWidgets(
    "un champ vide sorti de l'écran bloque l'envoi et revient à l'écran",
    (tester) async {
      final form = GlobalKey<FormState>();
      await tester.pumpWidget(_longForm(form));
      await _scrollToButton(tester);
      expect(find.text('Veuillez entrer un nom'), findsNothing);

      expect(form.currentState!.validateAndReveal(), isFalse);
      await tester.pumpAndSettle();

      final error = tester.getRect(find.text('Veuillez entrer un nom'));
      final screen = tester.getRect(find.byType(Scaffold));
      expect(screen.contains(error.topLeft), isTrue);
      expect(screen.contains(error.bottomRight), isTrue);
    },
  );

  testWidgets('un formulaire complet passe, même vu depuis le bas', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(_longForm(form, name: 'Hana'));
    await _scrollToButton(tester);

    expect(form.currentState!.validateAndReveal(), isTrue);
  });
}
