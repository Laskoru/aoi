import 'package:flutter/material.dart';

/// Palette de l'application, empruntée au vocabulaire des nishikigoi.
///
/// Les koï se décrivent par leurs couleurs : `shiroji` le blanc de fond,
/// `hi` la plaque rouge-orangé, `sumi` le noir d'encre. On y ajoute les tons
/// de l'eau du bassin, qui portent la structure de l'interface.
///
/// Ces constantes ne sont utilisées que par [AppTheme] : les écrans lisent
/// leurs couleurs depuis le thème, jamais ici.
class AppPalette {
  const AppPalette._();

  // --- Shiroji : le blanc du koï, jamais tout à fait pur ---
  static const shiroji = Color(0xFFF8F5F0);
  static const shirojiPure = Color(0xFFFFFFFF);
  static const shirojiShade = Color(0xFFF1ECE4);
  static const shirojiLine = Color(0xFFE4DCD1);

  // --- Hi : la plaque rouge-orangé, couleur d'accent ---
  static const hi = Color(0xFFD4502E);
  static const hiBright = Color(0xFFF0714A);
  static const hiDeep = Color(0xFFA83A1E);
  static const hiWash = Color(0xFFFBEBE5);

  // --- Sumi : le noir d'encre, légèrement bleuté ---
  static const sumi = Color(0xFF1C1B1A);
  static const sumiSoft = Color(0xFF3D3B38);
  static const sumiMuted = Color(0xFF7A736A);

  // --- L'eau du bassin, du bord vers le fond ---
  static const mizuDeep = Color(0xFF14425A);
  static const mizuMid = Color(0xFF2C6E8F);
  static const mizuLight = Color(0xFF5FA8C7);
  static const mizuWash = Color(0xFFE6EFF4);

  // --- Fonds sombres : le bassin la nuit ---
  static const nightBase = Color(0xFF121417);
  static const nightSurface = Color(0xFF1A1E22);
  static const nightRaised = Color(0xFF232830);
  static const nightLine = Color(0xFF2E353D);
  static const nightText = Color(0xFFF2EFEA);
  static const nightTextMuted = Color(0xFF9BA3AC);

  // --- États de l'eau ---
  // Le danger reste un cramoisi franc, distinct du `hi` orangé de l'accent :
  // une alerte ne doit jamais se confondre avec la couleur de marque.
  static const idealLight = Color(0xFF2F7D5B);
  static const idealDark = Color(0xFF4FBF8B);
  static const warningLight = Color(0xFFC97A16);
  static const warningDark = Color(0xFFE8A33D);
  static const dangerLight = Color(0xFFB3261E);
  static const dangerDark = Color(0xFFF0685E);
}

/// Rayons d'arrondi, pour que toutes les surfaces s'accordent.
class AppRadius {
  const AppRadius._();

  static const double card = 24;
  static const double field = 16;
  static const double chip = 12;
  static const double pill = 100;
  static const double sheet = 28;
}

/// Échelle d'espacement. S'y tenir évite les marges arbitraires.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}
