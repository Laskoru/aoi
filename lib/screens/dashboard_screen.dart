import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_koi_screen.dart';
import 'add_measurement_screen.dart';
import 'koi_details_screen.dart';
import '../models/koi.dart';
import '../models/water_measurement.dart';
import '../services/auth_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';
import '../widgets/metric_card.dart';
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddKoiScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildKoiGrid(user.uid),

                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    title: "Paramètres du bassin",
                    icon: Icons.water_drop_rounded,
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMeasurementScreen()),
        ),
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final measurement = WaterMeasurement.fromFirestore(
          snapshot.data!.docs.first,
        );
        final condition = worstCondition([
          WaterLogic.checkPhLevel(measurement.ph),
          WaterLogic.checkTemperature(measurement.temperature),
        ]);

        final color = condition.color(context);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: condition.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              Icon(condition.icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition == WaterCondition.ideal
                          ? "Bassin en bonne santé"
                          : "Le bassin demande votre attention",
                      style: context.texts.labelLarge?.copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(condition.advice, style: context.texts.bodyMedium),
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
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyState(
            icon: Icons.science_rounded,
            title: "Aucune analyse d'eau",
            message:
                "Enregistrez votre premier relevé pour suivre la qualité du bassin.",
            actionLabel: "Ajouter une mesure",
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddMeasurementScreen()),
            ),
          );
        }

        final measurement = WaterMeasurement.fromFirestore(
          snapshot.data!.docs.first,
        );

        return Row(
          children: [
            Expanded(
              child: MetricCard(
                title: "pH",
                value: measurement.ph.toStringAsFixed(1),
                unit: "",
                icon: Icons.science_rounded,
                condition: WaterLogic.checkPhLevel(measurement.ph),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: "Température",
                value: measurement.temperature.toStringAsFixed(1),
                unit: "°C",
                icon: Icons.device_thermostat_rounded,
                condition: WaterLogic.checkTemperature(measurement.temperature),
              ),
            ),
          ],
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
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddKoiScreen()),
            ),
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
          itemBuilder: (context, index) => _KoiCard(koi: kois[index]),
        );
      },
    );
  }
}

/// Vignette d'un koï dans la grille : sa photo en fond, ses repères par-dessus.
class _KoiCard extends StatelessWidget {
  final Koi koi;

  const _KoiCard({required this.koi});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = koi.imageUrl != null;

    // Sur photo, le texte passe en blanc au-dessus d'un voile sombre ; sans
    // photo, il reprend les couleurs normales de la carte.
    final Color primaryText = hasImage ? Colors.white : colors.onSurface;
    final Color secondaryText = hasImage
        ? Colors.white.withValues(alpha: 0.8)
        : colors.onSurfaceVariant;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KoiDetailsScreen(koiId: koi.id, initialKoi: koi),
        ),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: colors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(
                alpha: context.isDark ? 0.35 : 0.05,
              ),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                koi.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(context),
              )
            else
              _placeholder(context),

            // Voile dégradé : sans lui, un nom clair sur une écaille claire
            // devient illisible.
            if (hasImage)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                    stops: const [0.42, 1.0],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusPill(
                        label: "${koi.size.toStringAsFixed(0)} CM",
                        color: hasImage ? Colors.white : colors.primary,
                        background: hasImage
                            ? Colors.black.withValues(alpha: 0.35)
                            : colors.primaryContainer,
                      ),
                      const Spacer(),
                      if (koi.status != KoiStatus.alive)
                        StatusPill(
                          label: koi.status.label.toUpperCase(),
                          color: hasImage ? Colors.white : colors.onSurfaceVariant,
                          background: hasImage
                              ? Colors.black.withValues(alpha: 0.35)
                              : colors.surfaceContainerHigh,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    koi.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: -0.3,
                      color: primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    koi.variety.isEmpty ? "Variété inconnue" : koi.variety,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.cake_rounded, size: 11, color: secondaryText),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          koi.ageLabel(),
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fond des fiches sans photo : un dégradé d'eau et la silhouette d'un koï.
  Widget _placeholder(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer,
            colors.primaryContainer.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.set_meal_rounded,
          size: 44,
          color: colors.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
