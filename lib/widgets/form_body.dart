import 'package:flutter/material.dart';
import '../theme/app_motion.dart';

/// Corps défilant d'un formulaire, dont tous les champs restent construits,
/// même hors de l'écran.
///
/// Une ListView retire les champs qu'on a fait défiler, et la validation du
/// [Form] ne voit plus que ceux qui restent : un nom laissé vide en haut
/// passait inaperçu quand on touchait le bouton tout en bas. Le serveur
/// refusait alors l'enregistrement, ou l'appli retenait une valeur par défaut
/// à la place d'une taille ou d'un pH.
class FormBody extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;

  const FormBody({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      // Comme une ListView : le bas du formulaire ne finit pas sous la barre
      // de navigation du téléphone.
      padding:
          padding + EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

extension RevealingValidation on FormState {
  /// Valide tout le formulaire. En cas d'erreur, fait défiler jusqu'au champ
  /// fautif le plus haut : son message ne doit pas rester hors de l'écran.
  bool validateAndReveal() {
    final invalid = validateGranularly();
    if (invalid.isEmpty) return true;
    final first = invalid.reduce((a, b) => _topOf(a) <= _topOf(b) ? a : b);
    Scrollable.ensureVisible(
      first.context,
      alignment: 0.2,
      duration: AppMotion.reduced(context) ? Duration.zero : AppMotion.enter,
      curve: AppMotion.enterCurve,
    );
    return false;
  }
}

/// Position verticale d'un champ à l'écran, pour trouver le plus haut.
double _topOf(FormFieldState<Object?> field) {
  final box = field.context.findRenderObject();
  return box is RenderBox && box.attached
      ? box.localToGlobal(Offset.zero).dy
      : double.infinity;
}
