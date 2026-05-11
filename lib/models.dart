class PondStatus {
  final double temperature;
  final double ph;
  final double nitrites; // NO2
  final DateTime lastUpdate;

  PondStatus({
    required this.temperature,
    required this.ph,
    required this.nitrites,
    required this.lastUpdate,
  });

  // Logique métier : Est-ce que l'eau est sûre ?
  String get healthStatus {
    if (nitrites > 0.1) return "DANGER : Nitrites élevés !";
    if (ph < 6.5 || ph > 8.5) return "ATTENTION : pH instable";
    return "Eau saine";
  }
}
