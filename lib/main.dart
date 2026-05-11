import 'package:flutter/material.dart';

// Importation de tes écrans
// Assure-toi que ces fichiers existent bien dans lib/screens/
import 'package:aoi/screens/dashboard_screen.dart';
import 'package:aoi/screens/add_koi_screen.dart';

void main() {
  // Optionnel : garantit que les services Flutter sont prêts avant le lancement
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AoiApp());
}

class AoiApp extends StatelessWidget {
  const AoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aoi Koï Manager',
      debugShowCheckedModeBanner: false,

      // Configuration du thème (Style Premium / Zen)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0077B6), // Un beau bleu profond
          brightness: Brightness.light,
        ),

        // Personnalisation de l'AppBar pour tout le projet
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        // Style des boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Définition de la page de démarrage
      home: DashboardScreen(),

      // Système de navigation par routes (optionnel mais recommandé pour les revenus)
      // Cela permet de structurer les accès aux futures pages Premium
      routes: {'/add-koi': (context) => AddKoiScreen()},
    );
  }
}
