/// Les trois états possibles d'un paramètre de l'eau.
enum WaterCondition { ideal, warning, danger }

/// Les paramètres suivis pour un bassin à koï.
///
/// L'ordre de déclaration est celui de l'affichage : d'abord ce qui se mesure
/// à chaque visite, ensuite les toxiques du cycle de l'azote, enfin les
/// duretés qui expliquent la stabilité de l'ensemble.
enum WaterParameter {
  ph('pH', ''),
  temperature('Température', '°C'),
  ammonia('Ammoniaque', 'mg/L'),
  nitrite('Nitrites', 'mg/L'),
  nitrate('Nitrates', 'mg/L'),
  kh('KH', '°d'),
  gh('GH', '°d');

  const WaterParameter(this.label, this.unit);

  final String label;
  final String unit;

  WaterCondition check(double value) => switch (this) {
    WaterParameter.ph => WaterLogic.checkPhLevel(value),
    WaterParameter.temperature => WaterLogic.checkTemperature(value),
    WaterParameter.ammonia => WaterLogic.checkAmmonia(value),
    WaterParameter.nitrite => WaterLogic.checkNitrite(value),
    WaterParameter.nitrate => WaterLogic.checkNitrate(value),
    WaterParameter.kh => WaterLogic.checkKh(value),
    WaterParameter.gh => WaterLogic.checkGh(value),
  };

  /// Ce qu'il faut retenir du paramètre quand il sort de sa plage.
  String get explanation => switch (this) {
    WaterParameter.ph =>
      "Un pH instable stresse les koï et rend l'ammoniaque plus toxique.",
    WaterParameter.temperature =>
      "Sous 10 °C les koï ralentissent ; au-dessus de 28 °C l'eau manque d'oxygène.",
    WaterParameter.ammonia =>
      "L'ammoniaque brûle les branchies. Sa présence signale un filtre débordé.",
    WaterParameter.nitrite =>
      "Les nitrites asphyxient les koï en bloquant le transport de l'oxygène.",
    WaterParameter.nitrate =>
      "Les nitrates s'accumulent lentement. Ils se corrigent par des changements d'eau.",
    WaterParameter.kh =>
      "Le KH tamponne le pH. Trop bas, le pH peut s'effondrer d'un coup.",
    WaterParameter.gh =>
      "Le GH mesure la dureté générale, qui soutient l'osmorégulation des koï.",
  };
}

/// Une valeur relevée, avec l'état qu'elle traduit.
class WaterReading {
  final WaterParameter parameter;
  final double value;

  const WaterReading(this.parameter, this.value);

  WaterCondition get condition => parameter.check(value);

  /// Valeur formatée pour l'affichage : les toxiques se lisent au centième,
  /// le reste au dixième.
  String get formattedValue {
    final decimals = switch (parameter) {
      WaterParameter.ammonia || WaterParameter.nitrite => 2,
      WaterParameter.nitrate => 0,
      _ => 1,
    };
    return value.toStringAsFixed(decimals);
  }
}

/// Seuils de qualité d'eau pour un bassin à koï.
///
/// Les koï tolèrent une plage plus large que la plupart des poissons
/// d'aquarium, sauf sur les toxiques de l'azote — ammoniaque et nitrites —
/// où la seule valeur confortable est zéro.
class WaterLogic {
  const WaterLogic._();

  /// pH idéal entre 7.0 et 8.5. En dessous de 6.5 ou au-dessus de 9.0, le koï
  /// est en souffrance.
  static WaterCondition checkPhLevel(double ph) {
    if (ph >= 7.0 && ph <= 8.5) return WaterCondition.ideal;
    if ((ph >= 6.5 && ph < 7.0) || (ph > 8.5 && ph <= 9.0)) {
      return WaterCondition.warning;
    }
    return WaterCondition.danger;
  }

  /// Plage de métabolisme confortable entre 15 et 25 °C. Trop froid, le koï
  /// hiberne ; trop chaud, l'eau ne retient plus assez d'oxygène.
  static WaterCondition checkTemperature(double temp) {
    if (temp >= 15.0 && temp <= 25.0) return WaterCondition.ideal;
    if ((temp >= 10.0 && temp < 15.0) || (temp > 25.0 && temp <= 28.0)) {
      return WaterCondition.warning;
    }
    return WaterCondition.danger;
  }

  /// Ammoniaque totale. Elle brûle les branchies et devient d'autant plus
  /// toxique que le pH est élevé : la seule cible acceptable est zéro.
  static WaterCondition checkAmmonia(double value) {
    if (value <= 0.02) return WaterCondition.ideal;
    if (value <= 0.25) return WaterCondition.warning;
    return WaterCondition.danger;
  }

  /// Nitrites. Ils bloquent le transport de l'oxygène dans le sang ; une
  /// présence mesurable signale un filtre biologique en défaut.
  static WaterCondition checkNitrite(double value) {
    if (value <= 0.1) return WaterCondition.ideal;
    if (value <= 0.25) return WaterCondition.warning;
    return WaterCondition.danger;
  }

  /// Nitrates. Bien mieux tolérés, ils s'accumulent avec le temps et se
  /// corrigent par des changements d'eau partiels.
  static WaterCondition checkNitrate(double value) {
    if (value <= 40) return WaterCondition.ideal;
    if (value <= 80) return WaterCondition.warning;
    return WaterCondition.danger;
  }

  /// Dureté carbonatée, en degrés allemands. C'est elle qui tamponne le pH :
  /// sous 3 °d, le pH peut s'effondrer brutalement du jour au lendemain.
  static WaterCondition checkKh(double value) {
    if (value >= 5 && value <= 15) return WaterCondition.ideal;
    if ((value >= 3 && value < 5) || (value > 15 && value <= 21)) {
      return WaterCondition.warning;
    }
    return WaterCondition.danger;
  }

  /// Dureté générale, en degrés allemands.
  static WaterCondition checkGh(double value) {
    if (value >= 8 && value <= 20) return WaterCondition.ideal;
    if ((value >= 4 && value < 8) || (value > 20 && value <= 30)) {
      return WaterCondition.warning;
    }
    return WaterCondition.danger;
  }
}
