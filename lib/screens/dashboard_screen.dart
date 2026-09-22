import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../models/koi.dart';
import '../models/water_measurement.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';
import '../widgets/metric_card.dart';
import '../widgets/koi_card.dart';
import '../widgets/water_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Session expirée")));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(context, user),
                  const SizedBox(height: AppSpacing.lg),

                  // Synthèse de l'eau, avant tout le reste : c'est ce qui peut
                  // demander une action immédiate.
                  _buildPondBanner(user.uid),
                  const SizedBox(height: AppSpacing.xl),

                  SectionHeader(
                    title: "Ma collection",
                    icon: Icons.auto_awesome_mosaic_rounded,
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_rounded, size: 28),
                      color: context.colors.secondary,
                      tooltip: "Ajouter un koï",
                      onPressed: () => context.push('/koi/new'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildKoiGrid(user.uid),

                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: "Paramètres du bassin",
                    icon: Icons.water_drop_rounded,
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text("Historique"),
                      onPressed: () => context.push('/eau/historique'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildWaterMonitor(user.uid),

                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    title: "Évolution du pH",
                    icon: Icons.analytics_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ChartCard(
                    child: WaterChart(
                      userId: user.uid,
                      field: "ph",
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
                      field: "temperature",
                      color: context.colors.secondary,
                    ),
                  ),
                ],
              ),
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

  // --- En-tête ---

  Widget _buildAppBar(BuildContext context, User user) {
    final colors = context.colors;

    return SliverAppBar(
      floating: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 15,
            color: colors.onSurface,
          ),
          children: [
            const TextSpan(text: "AOI "),
            TextSpan(
              text: "KOI",
              style: TextStyle(color: colors.secondary),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          color: colors.onSurfaceVariant,
          tooltip: "Se déconnecter",
          onPressed: AuthService.signOut,
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context, User user) {
    final String firstName = (user.displayName ?? "Passionné").split(' ').first;
    final photoUrl = user.photoURL;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Bienvenue dans ton écosystème,", style: context.texts.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                firstName,
                style: context.texts.displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (photoUrl != null)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.outline, width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage(photoUrl),
              backgroundColor: context.colors.surfaceContainerHigh,
            ),
          ),
      ],
    );
  }

  // --- Synthèse de l'eau ---

  /// Bandeau qui résume l'état du bassin d'un coup d'œil, en retenant le plus
  /// préoccupant des paramètres relevés.
  Widget _buildPondBanner(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _latestMeasurementStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ErrorState(error: snapshot.error),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final readings = WaterMeasurement.fromFirestore(
          snapshot.data!.docs.first,
        ).readings;

        final condition = worstCondition(readings.map((r) => r.condition));
        final concerning = mostConcerningReading(readings);
        final color = condition.color(context);

        // Nommer le paramètre fautif vaut mieux qu'un « un paramètre est hors
        // plage » : on sait quoi corriger sans ouvrir un autre écran.
        final headline = switch (condition) {
          WaterCondition.ideal => "Bassin en bonne santé",
          _ =>
            "${concerning!.parameter.label} : ${concerning.formattedValue} ${concerning.parameter.unit}"
                .trim(),
        };
        final detail = concerning?.parameter.explanation ?? condition.advice;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: condition.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(condition.icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: context.texts.labelLarge?.copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(detail, style: context.texts.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _latestMeasurementStream(String uid) {
    return FirebaseFirestore.instance
        .collection('measurements')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots();
  }

  Widget _buildWaterMonitor(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: _latestMeasurementStream(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyState(
            icon: Icons.science_rounded,
            title: "Aucune analyse d'eau",
            message:
                "Enregistrez votre premier relevé pour suivre la qualité du bassin.",
            actionLabel: "Ajouter une mesure",
            onAction: () => context.push('/eau/nouvelle'),
          );
        }

        // Deux cartes par ligne, et seulement les paramètres réellement
        // relevés : une mesure rapide ne contient que pH et température.
        final readings = WaterMeasurement.fromFirestore(
          snapshot.data!.docs.first,
        ).readings;

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
          itemBuilder: (context, index) =>
              MetricCard(reading: readings[index]),
        );
      },
    );
  }

  // --- Collection ---

  Widget _buildKoiGrid(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // L'erreur passe avant l'état vide : sans cela, un refus de permission
        // s'afficherait « votre collection est vide », ce qui laisserait
        // croire à une perte de données.
        if (snapshot.hasError) return ErrorState(error: snapshot.error);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyState(
            icon: Icons.waves_rounded,
            title: "Votre collection est vide",
            message:
                "Ajoutez vos premières carpes koï pour suivre leur croissance et leur lignée.",
            actionLabel: "Ajouter un koï",
            onAction: () => context.push('/koi/new'),
          );
        }

        final kois = snapshot.data!.docs.map(Koi.fromFirestore).toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.78,
          ),
          itemCount: kois.length,
          itemBuilder: (context, index) => KoiCard(koi: kois[index]),
        );
      },
    );
  }
}
