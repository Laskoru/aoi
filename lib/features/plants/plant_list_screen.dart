import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';

/// Les plantes du bassin. Écran d'attente : le domaine arrive en phase 4.
class PlantListScreen extends StatelessWidget {
  const PlantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plantes", style: context.texts.headlineMedium),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: EmptyState(
          icon: Icons.grass_rounded,
          title: "Bientôt",
          message:
              "Le suivi des plantes aquatiques par zone de plantation arrive dans une prochaine version.",
        ),
      ),
    );
  }
}
