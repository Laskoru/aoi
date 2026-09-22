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
import '../../theme/pond_status.dart';
import '../../widgets/koi_card.dart';
import '../../widgets/water_health_banner.dart';
import 'scene/pond_scene.dart';
import 'widgets/fish_groups_section.dart';

/// L'accueil : le bassin lui-même, vu d'en haut, avec les koï de la
/// collection qui y nagent. En dessous, ce qu'on veut savoir en arrivant :
/// l'eau, les koï, les autres habitants.
class PondScreen extends StatelessWidget {
  const PondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Session expirée")));
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        // Un seul flux pour la scène et l'aperçu : les mêmes koï.
        stream: FirebaseFirestore.instance
            .collection('kois')
            .where('userId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final kois = (snapshot.data?.docs ?? const [])
              .map(Koi.fromFirestore)
              .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _SceneHeader(uid: user.uid, kois: kois),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // La santé de l'eau avant tout le reste : c'est ce qui
                      // peut demander une action immédiate.
                      StreamBuilder<WaterMeasurement?>(
                        stream: MeasurementService.latest(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return ErrorState(error: snapshot.error);
                          }
                          final latest = snapshot.data;
                          if (latest == null) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xl,
                            ),
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
                      _KoiPreview(snapshot: snapshot, kois: kois),

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
          );
        },
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

/// La scène, et par-dessus : la marque, le nom du bassin, l'état de l'eau,
/// et le nombre de koï que la scène n'a pas pu dessiner.
class _SceneHeader extends StatelessWidget {
  final String uid;
  final List<Koi> kois;

  const _SceneHeader({required this.uid, required this.kois});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.46;
    final alive = kois.where((k) => k.status == KoiStatus.alive).length;
    final hidden = alive > 24 ? alive - 24 : 0;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PondScene(
              kois: kois,
              onKoiTap: (koi) => context.push('/koi/${koi.id}', extra: koi),
            ),

            // Voile en haut, pour que la marque et le nom restent lisibles
            // quelle que soit l'eau derrière.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.42),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45],
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _Wordmark(),
                        const Spacer(),
                        _PondEditButton(uid: uid),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _PondName(uid: uid),
                    const Spacer(),
                    Row(
                      children: [
                        _WaterPill(uid: uid),
                        const Spacer(),
                        if (hidden > 0)
                          StatusPill(
                            label: "+$hidden KOÏ",
                            color: Colors.white,
                            background: Colors.black.withValues(alpha: 0.35),
                            icon: Icons.visibility_off_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 15,
          color: Colors.white,
        ),
        children: [
          TextSpan(text: "AOI "),
          TextSpan(text: "KOI", style: TextStyle(color: AppPalette.hiBright)),
        ],
      ),
    );
  }
}

class _PondName extends StatelessWidget {
  final String uid;

  const _PondName({required this.uid});

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
            "${pond!.depthCm!.toStringAsFixed(0)} cm de profondeur",
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pond?.name ?? "Mon bassin",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.6,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (details.isNotEmpty)
              Text(
                details.join(" · "),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PondEditButton extends StatelessWidget {
  final String uid;

  const _PondEditButton({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Pond?>(
      stream: PondService.defaultOf(uid),
      builder: (context, snapshot) {
        final pond = snapshot.data;
        if (pond == null) return const SizedBox(width: 48, height: 48);
        return IconButton(
          icon: const Icon(Icons.tune_rounded),
          color: Colors.white,
          tooltip: "Modifier le bassin",
          onPressed: () => context.push('/bassin/edit', extra: pond),
        );
      },
    );
  }
}

/// L'état de l'eau, résumé en une pastille sur la scène.
class _WaterPill extends StatelessWidget {
  final String uid;

  const _WaterPill({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WaterMeasurement?>(
      stream: MeasurementService.latest(uid),
      builder: (context, snapshot) {
        final latest = snapshot.data;
        if (latest == null) {
          return StatusPill(
            label: "AUCUN RELEVÉ",
            color: Colors.white,
            background: Colors.black.withValues(alpha: 0.35),
            icon: Icons.science_outlined,
          );
        }
        final condition = worstCondition(latest.readings.map((r) => r.condition));
        return Semantics(
          button: true,
          label: "Eau : ${condition.label}",
          child: GestureDetector(
            onTap: () => context.go('/eau'),
            child: StatusPill(
              label: "EAU ${condition.label}",
              color: Colors.white,
              background: condition.color(context).withValues(alpha: 0.85),
              icon: condition.icon,
            ),
          ),
        );
      },
    );
  }
}

/// Les quatre koï les plus récents. La grille complète vit dans son onglet.
class _KoiPreview extends StatelessWidget {
  final AsyncSnapshot<QuerySnapshot> snapshot;
  final List<Koi> kois;

  const _KoiPreview({required this.snapshot, required this.kois});

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) return ErrorState(error: snapshot.error);
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (kois.isEmpty) {
      return EmptyState(
        icon: Icons.waves_rounded,
        title: "Votre collection est vide",
        message:
            "Ajoutez vos premières carpes koï : elles apparaîtront dans le bassin.",
        actionLabel: "Ajouter un koï",
        onAction: () => context.push('/koi/new'),
      );
    }

    final preview = kois.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemCount: preview.length,
      itemBuilder: (context, index) => KoiCard(koi: preview[index]),
    );
  }
}
