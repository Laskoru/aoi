import 'package:flutter/material.dart';
import '../utils/water_logic.dart';
import 'app_theme.dart';

/// Habillage visuel des trois états de l'eau.
///
/// Regrouper ici la couleur, le libellé et l'icône garantit qu'un paramètre en
/// alerte se présente pareil partout : carte de mesure, graphique, bandeau.
extension WaterConditionStyle on WaterCondition {
  Color color(BuildContext context) => switch (this) {
    WaterCondition.ideal => context.pond.ideal,
    WaterCondition.warning => context.pond.warning,
    WaterCondition.danger => context.pond.danger,
  };

  Color surface(BuildContext context) => switch (this) {
    WaterCondition.ideal => context.pond.idealSurface,
    WaterCondition.warning => context.pond.warningSurface,
    WaterCondition.danger => context.pond.dangerSurface,
  };

  String get label => switch (this) {
    WaterCondition.ideal => 'SAIN',
    WaterCondition.warning => 'ALERTE',
    WaterCondition.danger => 'DANGER',
  };

  IconData get icon => switch (this) {
    WaterCondition.ideal => Icons.check_circle_rounded,
    WaterCondition.warning => Icons.error_rounded,
    WaterCondition.danger => Icons.warning_rounded,
  };

  /// Phrase d'explication affichée sous le bandeau de synthèse du bassin.
  String get advice => switch (this) {
    WaterCondition.ideal => "Les paramètres relevés sont dans la bonne plage.",
    WaterCondition.warning =>
      "Un paramètre s'écarte de la plage idéale. À surveiller.",
    WaterCondition.danger =>
      "Un paramètre est hors plage. Intervenez sans attendre.",
  };
}

/// Retient l'état le plus préoccupant d'une série de mesures : c'est lui qui
/// résume la santé du bassin.
WaterCondition worstCondition(Iterable<WaterCondition> conditions) {
  var worst = WaterCondition.ideal;
  for (final condition in conditions) {
    if (condition == WaterCondition.danger) return WaterCondition.danger;
    if (condition == WaterCondition.warning) worst = WaterCondition.warning;
  }
  return worst;
}
