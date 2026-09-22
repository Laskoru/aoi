import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/water_measurement.dart';
import '../../services/measurement_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../utils/water_logic.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/water_chart.dart';
import '../../widgets/water_health_banner.dart';

/// Qualité de l'eau : synthèse, dernier relevé, tendances.
class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Session expirée")));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text("Eau", style: context.texts.headlineMedium),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text("Historique"),
                onPressed: () => context.push('/eau/historique'),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<WaterMeasurement?>(
              stream: MeasurementService.latest(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ErrorState(error: snapshot.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final latest = snapshot.data;
                if (latest == null) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EmptyState(
                      icon: Icons.science_rounded,
                      title: "Aucune analyse d'eau",
                      message:
                          "Enregistrez votre premier relevé pour suivre la qualité du bassin.",
                      actionLabel: "Ajouter une mesure",
                      onAction: () => context.push('/eau/nouvelle'),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WaterHealthBanner(measurement: latest),
                      const SizedBox(height: AppSpacing.xl),

                      const SectionHeader(
                        title: "Dernier relevé",
                        icon: Icons.water_drop_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ReadingsGrid(readings: latest.readings),

                      const SizedBox(height: AppSpacing.xl),
                      const SectionHeader(
                        title: "Évolution du pH",
                        icon: Icons.analytics_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ChartCard(
                        child: WaterChart(
                          userId: user.uid,
                          parameter: WaterParameter.ph,
                          color: context.colors.tertiary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Suivi de la température",
                        icon: Icons.thermostat_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ChartCard(
                        child: WaterChart(
                          userId: user.uid,
                          parameter: WaterParameter.temperature,
                          color: context.colors.secondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/eau/nouvelle'),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        icon: const Icon(Icons.speed_rounded),
        label: const Text(
          "Nouvelle mesure",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Deux cartes par ligne, et seulement les paramètres réellement relevés :
/// une mesure rapide ne contient que pH et température.
class _ReadingsGrid extends StatelessWidget {
  final List<WaterReading> readings;

  const _ReadingsGrid({required this.readings});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        mainAxisExtent: 132,
      ),
      itemCount: readings.length,
      itemBuilder: (context, index) => MetricCard(reading: readings[index]),
    );
  }
}
