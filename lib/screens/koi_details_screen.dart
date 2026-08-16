import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/koi.dart';
import '../services/koi_service.dart';
import 'koi_form_screen.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../widgets/water_chart.dart' show ChartCard;

class KoiDetailsScreen extends StatelessWidget {
  final String koiId;

  /// Données déjà connues par l'écran appelant : elles évitent un écran de
  /// chargement le temps que le flux Firestore réponde.
  final Koi? initialKoi;

  const KoiDetailsScreen({super.key, required this.koiId, this.initialKoi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kois')
            .doc(koiId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _CenteredMessage(message: "Erreur : ${snapshot.error}");
          }

          final Koi? koi;
          if (snapshot.hasData && snapshot.data!.exists) {
            koi = Koi.fromFirestore(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            koi = initialKoi;
          } else {
            return const _CenteredMessage(message: "Ce koï n'existe plus.");
          }

          if (koi == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Dart ne conserve pas la promotion de type à l'intérieur d'une
          // closure pour une variable affectée après sa déclaration : les
          // fonctions différées ci-dessous ont besoin d'un Koi non nullable.
          final Koi loaded = koi;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                surfaceTintColor: Colors.transparent,
                title: Text(
                  koi.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Modifier la fiche',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KoiFormScreen(existing: koi),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _buildHero(context, koi)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: "Galerie",
                        icon: Icons.photo_library_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PhotoGallery(
                        koi: loaded,
                        onAdd: () => _addPhoto(context, loaded),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Identité",
                        icon: Icons.fingerprint_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildIdentityCard(context, koi),

                      if (koi.breeder != null || koi.origin != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: "Provenance",
                          icon: Icons.storefront_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildOriginCard(koi),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Généalogie",
                        icon: Icons.account_tree_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildGenealogyCard(context, koi),

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Croissance",
                        icon: Icons.straighten_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildCurrentSizeCard(context, koi),
                      const SizedBox(height: AppSpacing.md),
                      ChartCard(child: _buildGrowthChart(context)),

                      if (koi.notes != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: "Notes",
                          icon: Icons.sticky_note_2_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Text(koi.notes!, style: context.texts.bodyLarge),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- En-tête ---

  Widget _buildHero(BuildContext context, Koi koi) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl, top: AppSpacing.sm),
      decoration: pondGradient(
        context,
        radius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _addPhoto(context, koi),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    backgroundImage: koi.imageUrl != null
                        ? NetworkImage(koi.imageUrl!)
                        : null,
                    child: koi.imageUrl == null
                        ? const KoiEmblem(size: 46, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppPalette.hi,
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            koi.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            koi.variety.isEmpty ? "Variété inconnue" : koi.variety,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              StatusPill(
                label: "${koi.size.toStringAsFixed(1)} CM",
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.18),
              ),
              if (koi.yearClass() != null)
                StatusPill(
                  label: koi.yearClass()!.toUpperCase(),
                  color: Colors.white,
                  background: AppPalette.hi.withValues(alpha: 0.85),
                ),
              if (koi.status != KoiStatus.alive)
                StatusPill(
                  label: koi.status.label.toUpperCase(),
                  color: Colors.white,
                  background: Colors.black.withValues(alpha: 0.3),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Identité et âge ---

  Widget _buildIdentityCard(BuildContext context, Koi koi) {
    final birthDate = koi.birthDate;
    final colors = context.colors;

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoTile(
                icon: Icons.color_lens_rounded,
                label: "Variété",
                value: koi.variety.isEmpty ? "—" : koi.variety,
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.cake_rounded,
                label: "Âge",
                value: koi.ageLabel(),
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.wc_rounded,
                label: "Sexe",
                value: koi.sex.label,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),

          // Ligne de naissance : c'est aussi le point d'entrée pour compléter
          // une fiche ancienne, qui n'a qu'un âge figé.
          InkWell(
            onTap: () => _showBirthDatePicker(context, koi),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: birthDate == null
                        ? context.pond.warning
                        : colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          birthDate == null
                              ? "Date de naissance à renseigner"
                              : "Né le ${DateFormat('d MMMM yyyy', 'fr_FR').format(birthDate)}",
                          style: context.texts.labelLarge?.copyWith(
                            color: birthDate == null
                                ? context.pond.warning
                                : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          birthDate == null
                              ? (koi.legacyAge != null
                                    ? "Âge approximatif repris de l'ancienne fiche"
                                    : "Appuyez pour l'ajouter")
                              : "Classe d'âge : ${koi.yearClass()}",
                          style: context.texts.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginCard(Koi koi) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (koi.breeder != null)
            LabelledRow(
              icon: Icons.storefront_rounded,
              label: "Éleveur",
              value: koi.breeder!,
            ),
          if (koi.breeder != null && koi.origin != null)
            const SizedBox(height: AppSpacing.md),
          if (koi.origin != null)
            LabelledRow(
              icon: Icons.place_rounded,
              label: "Provenance",
              value: koi.origin!,
            ),
        ],
      ),
    );
  }

  /// Ouvre le calendrier pour renseigner ou corriger la naissance. Pour une
  /// fiche ancienne, on le pré-positionne sur l'année déduite de l'âge saisi
  /// à l'époque, ce qui évite de faire défiler trente ans.
  Future<void> _showBirthDatePicker(BuildContext context, Koi koi) async {
    final now = DateTime.now();

    final DateTime initial;
    if (koi.birthDate != null) {
      initial = koi.birthDate!;
    } else if (koi.legacyAge != null && koi.legacyAge! > 0) {
      initial = DateTime(now.year - koi.legacyAge!, 1, 1);
    } else {
      initial = DateTime(now.year - 1, now.month, now.day);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Date de naissance de ${koi.name}',
      cancelText: 'Annuler',
      confirmText: 'Enregistrer',
    );

    if (picked == null) return;

    try {
      await FirebaseFirestore.instance.collection('kois').doc(koi.id).update({
        'birthDate': Timestamp.fromDate(picked),
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'enregistrer la date : $e")),
        );
      }
    }
  }

  // --- Généalogie ---

  Widget _buildGenealogyCard(BuildContext context, Koi koi) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _buildParentBox(
              context,
              label: "PÈRE",
              parentId: koi.fatherId,
              manualName: koi.fatherNameManual,
              icon: Icons.male_rounded,
              accent: context.colors.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildParentBox(
              context,
              label: "MÈRE",
              parentId: koi.motherId,
              manualName: koi.motherNameManual,
              icon: Icons.female_rounded,
              accent: context.colors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentBox(
    BuildContext context, {
    required String label,
    String? parentId,
    String? manualName,
    required IconData icon,
    required Color accent,
  }) {
    if (parentId == null) {
      if (manualName != null && manualName.trim().isNotEmpty) {
        return _parentCard(context, label, manualName, "Saisie manuelle", icon, accent);
      }
      return _parentCard(context, label, "Non renseigné", "Inconnu", icon, accent);
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('kois').doc(parentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _parentCard(context, label, "…", "Chargement", icon, accent);
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          final parent = Koi.fromFirestore(snapshot.data!);
          return _parentCard(
            context,
            label,
            parent.name,
            parent.variety.isEmpty ? "Variété inconnue" : parent.variety,
            icon,
            accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    KoiDetailsScreen(koiId: parent.id, initialKoi: parent),
              ),
            ),
          );
        }
        return _parentCard(context, label, "Inconnu", "Introuvable", icon, accent);
      },
    );
  }

  Widget _parentCard(
    BuildContext context,
    String role,
    String name,
    String sub,
    IconData icon,
    Color accent, {
    VoidCallback? onTap,
  }) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: context.texts.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: context.texts.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: context.texts.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // --- Croissance ---

  Widget _buildCurrentSizeCard(BuildContext context, Koi koi) {
    return AppCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dernière taille mesurée", style: context.texts.labelMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "${koi.size.toStringAsFixed(1)} cm",
                style: context.texts.headlineMedium,
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showUpdateSizeSheet(context, koi),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text("Mesurer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.secondaryContainer,
              foregroundColor: context.colors.onSecondaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .doc(koiId)
          .collection('growth')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erreur : ${snapshot.error}",
              style: context.texts.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Enregistrez une mesure pour tracer la courbe de croissance.",
              style: context.texts.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }

        // Du plus ancien au plus récent, pour lire de gauche à droite.
        final entries = snapshot.data!.docs.reversed
            .map(GrowthEntry.fromFirestore)
            .toList();

        final spots = <FlSpot>[
          for (int i = 0; i < entries.length; i++)
            FlSpot(i.toDouble(), entries[i].size),
        ];
        final labels = [
          for (final entry in entries)
            entry.measuredAt == null
                ? ""
                : DateFormat('dd/MM').format(entry.measuredAt!),
        ];

        final axisStyle = context.texts.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        );

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: colors.outlineVariant, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) =>
                      Text(value.toStringAsFixed(0), style: axisStyle),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      space: 10,
                      child: Text(labels[index], style: axisStyle),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.inverseSurface,
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map(
                      (spot) => LineTooltipItem(
                        "${spot.y.toStringAsFixed(1)} cm",
                        TextStyle(
                          color: colors.onInverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.28,
                color: colors.secondary,
                barWidth: 3.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 3.5,
                        color: colors.surface,
                        strokeWidth: 2.5,
                        strokeColor: colors.secondary,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.secondary.withValues(alpha: 0.22),
                      colors.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateSizeSheet(BuildContext context, Koi koi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheet),
          topRight: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (_) => _UpdateSizeSheet(koiId: koi.id, currentSize: koi.size),
    );
  }

  // --- Photo ---

  Future<void> _addPhoto(BuildContext context, Koi koi) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 15),
            Text("Envoi de la photo…"),
          ],
        ),
        duration: Duration(minutes: 2),
      ),
    );

    try {
      final Uint8List imageBytes = await pickedFile.readAsBytes();
      await KoiService.addPhoto(koi, imageBytes);

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text("Photo ajoutée à la galerie ! 🎉")),
      );
    } catch (e) {
      debugPrint("[AOI] Erreur Firebase Storage : $e");
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text("Erreur lors du transfert : $e")),
      );
    }
  }
}

/// Bande de photos d'un koï.
///
/// Le motif d'un koï change avec les années : la galerie garde la suite des
/// clichés, là où l'ancienne version écrasait l'unique photo à chaque envoi.
class _PhotoGallery extends StatelessWidget {
  final Koi koi;
  final Future<void> Function() onAdd;

  const _PhotoGallery({required this.koi, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<KoiPhoto>>(
      stream: KoiService.photosOf(koi.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);

        final photos = snapshot.data ?? const <KoiPhoto>[];

        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: photos.length + 1,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              if (index == 0) return _AddPhotoTile(onTap: onAdd);
              final photo = photos[index - 1];
              return _PhotoTile(
                photo: photo,
                isMain: photo.url == koi.imageUrl,
                onTap: () => _openViewer(context, photo),
              );
            },
          ),
        );
      },
    );
  }

  void _openViewer(BuildContext context, KoiPhoto photo) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (dialogContext) => _PhotoViewer(koi: koi, photo: photo),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final Future<void> Function() onTap;

  const _AddPhotoTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        width: 88,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: colors.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, color: colors.primary, size: 22),
            const SizedBox(height: 6),
            Text("Ajouter", style: context.texts.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final KoiPhoto photo;
  final bool isMain;
  final VoidCallback onTap;

  const _PhotoTile({
    required this.photo,
    required this.isMain,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        width: 88,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(
            color: isMain ? AppPalette.hi : context.colors.outlineVariant,
            width: isMain ? 2 : 1,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: context.colors.surfaceContainerHigh,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            if (isMain)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ColoredBox(
                  color: AppPalette.hi,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "PRINCIPALE",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Vue plein écran d'une photo, avec les deux actions qui s'y rapportent.
class _PhotoViewer extends StatelessWidget {
  final Koi koi;
  final KoiPhoto photo;

  const _PhotoViewer({required this.koi, required this.photo});

  @override
  Widget build(BuildContext context) {
    final isMain = photo.url == koi.imageUrl;

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 4,
              child: Center(child: Image.network(photo.url)),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isMain)
                      TextButton.icon(
                        icon: const Icon(Icons.star_rounded),
                        label: const Text("Définir comme principale"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          await KoiService.setMainPhoto(koi, photo);
                          navigator.pop();
                        },
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text("Supprimer"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppPalette.hiBright,
                      ),
                      onPressed: () => _confirmDelete(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette photo ?'),
        content: const Text("Le cliché sera définitivement effacé."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.pond.danger,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await KoiService.deletePhoto(koi, photo);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Suppression impossible : $e")),
      );
    }
  }
}

/// Feuille de saisie d'une nouvelle mesure de taille.
///
/// C'est un widget à part entière pour que son [TextEditingController] soit
/// créé et libéré avec elle — l'ancienne version le construisait dans `build`
/// et ne le libérait jamais.
class _UpdateSizeSheet extends StatefulWidget {
  final String koiId;
  final double currentSize;

  const _UpdateSizeSheet({required this.koiId, required this.currentSize});

  @override
  State<_UpdateSizeSheet> createState() => _UpdateSizeSheetState();
}

class _UpdateSizeSheetState extends State<_UpdateSizeSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentSize > 0 ? widget.currentSize.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newSize = double.tryParse(_controller.text.trim().replaceAll(',', '.'));

    if (newSize == null || newSize <= 0 || newSize > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entrez une taille valide, en centimètres.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final koiRef = FirebaseFirestore.instance
          .collection('kois')
          .doc(widget.koiId);

      // La taille courante sur la fiche et le point d'historique doivent
      // toujours bouger ensemble : un batch garantit qu'aucun des deux ne part
      // sans l'autre.
      final batch = FirebaseFirestore.instance.batch();
      batch.update(koiRef, {'size': newSize});
      batch.set(koiRef.collection('growth').doc(), {
        'size': newSize,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Enregistrement impossible : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.outline,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Text("Mettre à jour la taille", style: context.texts.headlineMedium),
          const SizedBox(height: 6),
          Text(
            "Elle sera ajoutée à la courbe de croissance.",
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            onSubmitted: (_) => _isSaving ? null : _save(),
            decoration: const InputDecoration(
              labelText: "Nouvelle taille",
              suffixText: "cm",
              prefixIcon: Icon(Icons.straighten_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : const Text("Confirmer la mesure"),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;

  const _CenteredMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium,
        ),
      ),
    );
  }
}
