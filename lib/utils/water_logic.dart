import 'package:flutter/material.dart';

class WaterLogic {
  static Color getColor(String param, double value) {
    switch (param) {
      case 'ph':
        if (value >= 7.0 && value <= 8.5) return Colors.green;
        if (value < 6.5 || value > 9.0) return Colors.red;
        return Colors.orange;
      case 'nitrite': // NO2 ppm
        if (value == 0) return Colors.green;
        if (value > 0.5) return Colors.red;
        return Colors.orange;
      case 'nitrate': // NO3 ppm
        if (value < 25) return Colors.green;
        if (value > 50) return Colors.red;
        return Colors.orange;
      case 'chlorine': // Chlore (doit être à 0)
        if (value == 0) return Colors.green;
        return Colors.red;
      case 'carbonate': // KH ppm (idéal > 100)
        if (value >= 100) return Colors.green;
        if (value < 50) return Colors.red;
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  static String getStatusText(Color color) {
    if (color == Colors.green) return "Bon";
    if (color == Colors.orange) return "Moyen";
    if (color == Colors.red) return "Mauvais";
    return "Inconnu";
  }
}
