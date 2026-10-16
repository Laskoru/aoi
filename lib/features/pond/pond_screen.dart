import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/koi.dart';
import '../../models/pond.dart';
import '../../models/water_measurement.dart';
import '../../services/measurement_service.dart';
import '../../services/pond_service.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../theme/pond_status.dart';
import '../../widgets/koi_card.dart';
import '../../widgets/water_health_banner.dart';
import 'widgets/calm_water_header.dart';
import 'widgets/fish_groups_section.dart';
import '../../services/pending_write.dart';

/// L'accueil : un en-tête d'eau calme — ou la photo du bassin — avec son nom
/// et l'état de l'eau, puis ce qu'on veut savoir en arrivant : les koï, en
/// photos, et les autres habitants.
class PondScreen extends StatelessWidget {
  const PondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text(context.l10n.sessionExpired)));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(uid: user.uid)),
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
                    title: context.l10n.koiListTitle,
                    icon: Icons.auto_awesome_mosaic_rounded,
                    trailing: TextButton(
                      onPressed: () => context.go('/koi'),
                      child: Text(context.l10n.pondSeeAll),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _KoiCarousel(uid: user.uid),

                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: context.l10n.pondOtherFish,
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
        label: Text(
          context.l10n.pondNewReading,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Marque, nom et dimensions du bassin, état de l'eau — sur l'eau calme, ou
/// sur la photo du bassin si l'utilisateur en a choisi une.
class _Header extends StatelessWidget {
  final String uid;

  const _Header({required this.uid});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return StreamBuilder<Pond?>(
      stream: PondService.defaultOf(uid),
      builder: (context, snapshot) {
        final pond = snapshot.data;
        return CalmWaterHeader(
          height: 232 + topInset,
          imageUrl: pond?.imageUrl,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _Wordmark(),
                      const Spacer(),
                      if (pond != null) _PondMenu(pond: pond),
                    ],
                  ),
                  const Spacer(),
                  _PondName(pond: pond),
                  const SizedBox(height: AppSpacing.md),
                  _WaterPill(uid: uid),
                ],
              ),
            ),
          ),
        );
      },
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

/// Modifier le bassin, choisir ou retirer sa photo.
class _PondMenu extends StatelessWidget {
  final Pond pond;

  const _PondMenu({required this.pond});

  Future<void> _pickPhoto(BuildContext context) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Sans les métadonnées, dont l'appli n'a pas l'usage : iOS n'a alors pas
      // à demander l'accès à toute la photothèque.
      requestFullMetadata: false,
      imageQuality: 75,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (picked == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    messenger.showSnackBar(SnackBar(content: Text(l10n.photoUploading)));
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final confirmed = await PondService.setPhoto(
        pond,
        bytes,
      ).confirmedWithin(const Duration(seconds: 20));
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            confirmed ? l10n.pondPhotoUpdated : l10n.pendingWrite,
          ),
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.uploadError(e))),
      );
    }
  }

  Future<void> _removePhoto(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final confirmed = await PondService.removePhoto(pond).confirmedWithin();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            confirmed ? l10n.pondPhotoRemoved : l10n.pendingWrite,
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
      tooltip: context.l10n.pondOptions,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            context.push('/bassin/edit', extra: pond);
          case 'photo':
            _pickPhoto(context);
          case 'remove':
            _removePhoto(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: Text(context.l10n.pondEdit),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'photo',
          child: ListTile(
            leading: const Icon(Icons.add_a_photo_rounded),
            title: Text(
              pond.imageUrl == null
                  ? context.l10n.pondAddPhoto
                  : context.l10n.changePhoto,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (pond.imageUrl != null)
          PopupMenuItem(
            value: 'remove',
            child: ListTile(
              leading: Icon(Icons.water_rounded, color: context.colors.primary),
              title: Text(context.l10n.pondRemovePhoto),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

class _PondName extends StatelessWidget {
  final Pond? pond;

  const _PondName({required this.pond});

  @override
  Widget build(BuildContext context) {
    final details = [
      if (pond?.volumeLiters != null)
        "${pond!.volumeLiters!.toStringAsFixed(0)} L",
      if (pond?.depthCm != null)
        context.l10n.pondDepthCm(pond!.depthCm!.toStringAsFixed(0)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.pondWelcome,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          pond?.displayName(context.l10n) ?? context.l10n.pondDefaultName,
          style: const TextStyle(
            fontSize: 30,
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
  }
}

/// L'état de l'eau, résumé en une pastille ; toucher ouvre l'onglet Eau.
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
            label: context.l10n.pondNoReading,
            color: Colors.white,
            background: Colors.black.withValues(alpha: 0.35),
            icon: Icons.science_outlined,
          );
        }
        final condition = worstCondition(latest.readings.map((r) => r.condition));
        return Semantics(
          button: true,
          label: condition.waterSummary(context.l10n),
          child: GestureDetector(
            onTap: () => context.go('/eau'),
            child: StatusPill(
              label: condition.waterSummary(context.l10n).toUpperCase(),
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

/// Les koï en photos, à faire défiler du doigt. La grille complète vit dans
/// son onglet.
class _KoiCarousel extends StatelessWidget {
  final String uid;

  const _KoiCarousel({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final kois = (snapshot.data?.docs ?? const [])
            .map(Koi.fromFirestore)
            .toList();
        if (kois.isEmpty) {
          return EmptyState(
            icon: Icons.waves_rounded,
            title: context.l10n.koiListEmptyTitle,
            message: context.l10n.koiListEmptyMessage,
            actionLabel: context.l10n.koiFormTitleAdd,
            onAction: () => context.push('/koi/new'),
          );
        }

        return SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: kois.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => StaggerIn(
              key: ValueKey(kois[index].id),
              index: index,
              child: SizedBox(width: 160, child: KoiCard(koi: kois[index])),
            ),
          ),
        );
      },
    );
  }
}
