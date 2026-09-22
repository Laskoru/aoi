import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';

/// Coquille des cinq onglets. Chaque branche garde sa propre pile et son
/// défilement : revenir sur un onglet le retrouve tel qu'on l'a laissé.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // Retaper l'onglet courant ramène à sa racine, comme sur iOS.
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 68,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.water_outlined),
            selectedIcon: Icon(Icons.water_rounded),
            label: "Bassin",
          ),
          // Material n'a pas d'icône de poisson convenable : l'emblème de
          // l'application tient ce rôle, comme sur les vignettes sans photo.
          NavigationDestination(
            icon: KoiEmblem(size: 24, color: colors.onSurfaceVariant),
            selectedIcon: KoiEmblem(size: 24, color: colors.onPrimaryContainer),
            label: "Koï",
          ),
          const NavigationDestination(
            icon: Icon(Icons.grass_outlined),
            selectedIcon: Icon(Icons.grass_rounded),
            label: "Plantes",
          ),
          const NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science_rounded),
            label: "Eau",
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
