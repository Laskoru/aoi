import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/koi.dart';
import '../../models/pond.dart';
import '../../models/water_measurement.dart';
import '../../services/measurement_service.dart';
import '../../services/pond_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../widgets/koi_card.dart';
import '../../widgets/water_health_banner.dart';
import 'widgets/fish_groups_section.dart';

/// L'accueil : le bassin lui-même. Version intermédiaire, en attendant la
/// scène animée : en-tête du bassin, santé de l'eau, aperçu des habitants.
class PondScreen extends StatelessWidget {
  const PondScreen({super.key});

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
          _buildAppBar(context),
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
                  _PondHeader(uid: user.uid),
                  const SizedBox(height: AppSpacing.lg),

                  // La santé de l'eau avant tout le reste : c'est ce qui peut
                  // demander une action immédiate.
                  StreamBuilder<WaterMeasurement?>(
                    stream: MeasurementService.latest(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ErrorState(error: snapshot.error);
                      }
                      final latest = snapshot.data;
                      if (latest == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                        child: WaterHealthBanner(measurement: latest),
                      );
                    },
                  ),

                  SectionHeader(
                    title: "Mes koï",
                    icon: Icons.auto_awesome_mosaic_rounded,
                    trailing: TextButton(
                      onPressed: () => context.go('/koi'),
                      child: const Text("Voir tout"),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _KoiPreview(uid: user.uid),

                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    title: "Autres habitants",
                    icon: Icons.groups_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FishGroupsSection(uid: user.uid),
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

  Widget _buildAppBar(BuildContext context) {
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
    );
  }
}

/// Nom et dimensions du bassin, avec accès à leur modification.
class _PondHeader extends StatelessWidget {
  final String uid;

  const _PondHeader({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Pond?>(
      stream: PondService.defaultOf(uid),
      builder: (context, snapshot) {
        final pond = snapshot.data;
        final details = [
          if (pond?.volumeLiters != null)
            "${pond!.volumeLiters!.toStringAsFixed(0)} L",
          if (pond?.depthCm != null)
            "${pond!.depthCm!.toStringAsFixed(0)} cm",
        ];

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bienvenue dans ton écosystème,", style: context.texts.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    pond?.name ?? "Mon bassin",
                    style: context.texts.displaySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty)
                    Text(details.join(" · "), style: context.texts.labelMedium),
                ],
              ),
            ),
            if (pond != null)
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                color: context.colors.onSurfaceVariant,
                tooltip: "Modifier le bassin",
                onPressed: () => context.push('/bassin/edit', extra: pond),
              ),
          ],
        );
      },
    );
  }
}

/// Les quatre koï les plus récents. La grille complète vit dans son onglet.
class _KoiPreview extends StatelessWidget {
  final String uid;

  const _KoiPreview({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return EmptyState(
            icon: Icons.waves_rounded,
            title: "Votre collection est vide",
            message:
                "Ajoutez vos premières carpes koï pour suivre leur croissance et leur lignée.",
            actionLabel: "Ajouter un koï",
            onAction: () => context.push('/koi/new'),
          );
        }

        final kois = docs.map(Koi.fromFirestore).toList();
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
