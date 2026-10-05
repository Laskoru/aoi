import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/plant.dart';
import '../../services/plant_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/photo_store.dart';
import '../../widgets/photo_image.dart';
import '../../services/pending_write.dart';

/// La fiche d'une plante.
class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final Plant? initialPlant;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    this.initialPlant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Plant?>(
        stream: PlantService.watchOne(plantId),
        initialData: initialPlant,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ErrorState(error: snapshot.error),
              ),
            );
          }
          final plant = snapshot.data;
          if (plant == null) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Text(
                "Cette plante n'existe plus.",
                style: context.texts.bodyMedium,
              ),
            );
          }

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
                  plant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Modifier la plante',
                    onPressed: () =>
                        context.push('/plantes/${plant.id}/edit', extra: plant),
                  ),
                ],
              ),
              SliverToBoxAdapter(child: _Header(plant: plant)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: "Plantation",
                        icon: Icons.landscape_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InfoTile(
                                  icon: Icons.water_rounded,
                                  label: "Zone",
                                  value: plant.zone.label,
                                ),
                                const VerticalRule(),
                                InfoTile(
                                  icon: Icons.numbers_rounded,
                                  label: "Quantité",
                                  value: "${plant.quantity}",
                                ),
                                const VerticalRule(),
                                InfoTile(
                                  icon: Icons.event_rounded,
                                  label: "Plantée",
                                  value: plant.plantedAt == null
                                      ? "—"
                                      : DateFormat('MMM yyyy', 'fr_FR')
                                            .format(plant.plantedAt!),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(height: 1),
                            ),
                            LabelledRow(
                              icon: Icons.info_outline_rounded,
                              label: "Profondeur",
                              value: plant.zone.description,
                            ),
                          ],
                        ),
                      ),

                      if (plant.notes != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: "Notes",
                          icon: Icons.sticky_note_2_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCard(
                          child: Text(
                            plant.notes!,
                            style: context.texts.bodyLarge,
                          ),
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
}

class _Header extends StatelessWidget {
  final Plant plant;

  const _Header({required this.plant});

  Future<void> _pickPhoto(BuildContext context) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: PhotoStore.maxSide.toDouble(),
      maxHeight: PhotoStore.maxSide.toDouble(),
      imageQuality: PhotoStore.pickQuality,
    );
    if (picked == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final Uint8List bytes = await picked.readAsBytes();
      final confirmed = await PlantService.setPhoto(
        plant,
        bytes,
      ).confirmedWithin(const Duration(seconds: 20));
      messenger.showSnackBar(
        SnackBar(
          content: Text(confirmed ? "Photo mise à jour." : pendingWriteMessage),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text("Erreur lors du transfert : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Semantics(
            button: true,
            label: "Changer la photo",
            child: GestureDetector(
              onTap: () => _pickPhoto(context),
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
                      backgroundImage: plant.imageUrl != null
                          ? photoImage(plant.imageUrl!, width: 360)
                          : null,
                      child: plant.imageUrl == null
                          ? const Icon(
                              Icons.grass_rounded,
                              size: 42,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppPalette.hi,
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            plant.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          if (plant.species != null) ...[
            const SizedBox(height: 2),
            Text(
              plant.species!,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              StatusPill(
                label: plant.zone.label.toUpperCase(),
                color: Colors.white,
                background: Colors.white.withValues(alpha: 0.18),
              ),
              if (plant.isFloating)
                StatusPill(
                  label: "FLOTTANTE",
                  color: Colors.white,
                  background: Colors.white.withValues(alpha: 0.18),
                ),
              if (plant.isOxygenating)
                StatusPill(
                  label: "OXYGÉNANTE",
                  color: Colors.white,
                  background: AppPalette.hi.withValues(alpha: 0.85),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
