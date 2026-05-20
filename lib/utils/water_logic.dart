// Définition des 3 états possibles pour l'eau
enum WaterCondition { ideal, warning, danger }

class WaterLogic {
  // --- LOGIQUE POUR LE PH ---
  // Le pH idéal pour un Koï est généralement entre 7.0 et 8.5
  static WaterCondition checkPhLevel(double ph) {
    if (ph >= 7.0 && ph <= 8.5) {
      return WaterCondition.ideal;
    } else if ((ph >= 6.5 && ph < 7.0) || (ph > 8.5 && ph <= 9.0)) {
      return WaterCondition.warning; // Limite acceptable mais à surveiller
    } else {
      return WaterCondition.danger; // Danger pour les Koï
    }
  }

  // --- LOGIQUE POUR LA TEMPÉRATURE ---
  // La température idéale de métabolisme est souvent entre 15°C et 25°C
  static WaterCondition checkTemperature(double temp) {
    if (temp >= 15.0 && temp <= 25.0) {
      return WaterCondition.ideal;
    } else if ((temp >= 10.0 && temp < 15.0) || (temp > 25.0 && temp <= 28.0)) {
      return WaterCondition.warning;
    } else {
      return WaterCondition
          .danger; // Trop froid (hibernation/risque) ou trop chaud (manque d'oxygène)
    }
  }
}
