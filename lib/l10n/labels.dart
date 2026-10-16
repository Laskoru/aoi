import '../models/koi.dart';
import '../models/plant.dart';
import '../models/pond.dart';
import '../utils/water_logic.dart';
import 'app_localizations.dart';

// Le texte des valeurs que les modèles rangent sous forme de codes. Les
// modèles restent sans langue : seul l'affichage en a une.

extension KoiSexLabel on KoiSex {
  String label(AppLocalizations l) => switch (this) {
    KoiSex.unknown => l.koiSexUnknown,
    KoiSex.male => l.koiSexMale,
    KoiSex.female => l.koiSexFemale,
  };
}

extension KoiStatusLabel on KoiStatus {
  String label(AppLocalizations l) => switch (this) {
    KoiStatus.alive => l.koiStatusAlive,
    KoiStatus.deceased => l.koiStatusDeceased,
    KoiStatus.sold => l.koiStatusSold,
    KoiStatus.given => l.koiStatusGiven,
  };
}

extension KoiAgeLabel on Koi {
  /// Âge lisible : « 3 ans et 2 mois », « 8 mois », « ~4 ans » quand il vient
  /// de l'ancien champ, « Âge inconnu » sinon.
  String ageLabel(AppLocalizations l, {DateTime? now}) {
    final months = ageInMonths(now: now);

    if (months == null) {
      final legacy = legacyAge;
      return legacy != null ? l.ageApproxYears(legacy) : l.ageUnknown;
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      return months == 0 ? l.ageLessThanAMonth : l.ageMonths(months);
    }
    if (remainingMonths == 0) return l.ageYears(years);
    return l.ageYearsAndMonths(l.ageYears(years), l.ageMonths(remainingMonths));
  }

  /// Classe d'âge japonaise (tosai, nisai…), le même mot dans toutes les
  /// langues ; au-delà de la dernière, le nombre d'années.
  String? yearClass(AppLocalizations l, {DateTime? now}) {
    final index = yearClassIndex(now: now);
    if (index == null) return null;
    if (index >= Koi.yearClassNames.length) {
      return l.yearClassOver(Koi.yearClassNames.length);
    }
    return Koi.yearClassNames[index];
  }
}

extension PondNameLabel on Pond {
  /// Le nom du bassin, ou « Mon bassin » dans la langue de l'interface pour
  /// celui que l'appli a créé d'office.
  String displayName(AppLocalizations l) =>
      name.isEmpty || name == Pond.legacyDefaultName ? l.pondDefaultName : name;
}

extension PlantZoneLabel on PlantZone {
  String label(AppLocalizations l) => switch (this) {
    PlantZone.berge => l.plantZoneBerge,
    PlantZone.marecage => l.plantZoneMarecage,
    PlantZone.immergee => l.plantZoneImmergee,
    PlantZone.profonde => l.plantZoneProfonde,
  };

  String description(AppLocalizations l) => switch (this) {
    PlantZone.berge => l.plantZoneBergeDescription,
    PlantZone.marecage => l.plantZoneMarecageDescription,
    PlantZone.immergee => l.plantZoneImmergeeDescription,
    PlantZone.profonde => l.plantZoneProfondeDescription,
  };
}

extension WaterParameterLabel on WaterParameter {
  String label(AppLocalizations l) => switch (this) {
    WaterParameter.ph => l.waterPh,
    WaterParameter.temperature => l.waterTemperature,
    WaterParameter.ammonia => l.waterAmmonia,
    WaterParameter.nitrite => l.waterNitrite,
    WaterParameter.nitrate => l.waterNitrate,
    WaterParameter.kh => l.waterKh,
    WaterParameter.gh => l.waterGh,
  };

  /// Ce qu'il faut retenir du paramètre quand il sort de sa plage.
  String explanation(AppLocalizations l) => switch (this) {
    WaterParameter.ph => l.waterPhExplanation,
    WaterParameter.temperature => l.waterTemperatureExplanation,
    WaterParameter.ammonia => l.waterAmmoniaExplanation,
    WaterParameter.nitrite => l.waterNitriteExplanation,
    WaterParameter.nitrate => l.waterNitrateExplanation,
    WaterParameter.kh => l.waterKhExplanation,
    WaterParameter.gh => l.waterGhExplanation,
  };
}

extension WaterReadingLabel on WaterReading {
  /// « Nitrites : 0.15 mg/L », la ponctuation de chaque langue comprise.
  String summary(AppLocalizations l) => l
      .waterReadingSummary(parameter.label(l), formattedValue, parameter.unit)
      .trim();
}

extension WaterConditionLabel on WaterCondition {
  /// L'état d'un paramètre, en capitales : « SAIN », « ALERTE », « DANGER ».
  String label(AppLocalizations l) => switch (this) {
    WaterCondition.ideal => l.waterConditionIdeal,
    WaterCondition.warning => l.waterConditionWarning,
    WaterCondition.danger => l.waterConditionDanger,
  };

  /// L'état de l'eau dans son ensemble. En français, accordé au féminin :
  /// [label] qualifie un paramètre (« pH sain »), pas l'eau.
  String waterSummary(AppLocalizations l) => switch (this) {
    WaterCondition.ideal => l.waterSummaryIdeal,
    WaterCondition.warning => l.waterSummaryWarning,
    WaterCondition.danger => l.waterSummaryDanger,
  };

  /// Phrase d'explication affichée sous le bandeau de synthèse du bassin.
  String advice(AppLocalizations l) => switch (this) {
    WaterCondition.ideal => l.waterAdviceIdeal,
    WaterCondition.warning => l.waterAdviceWarning,
    WaterCondition.danger => l.waterAdviceDanger,
  };
}
