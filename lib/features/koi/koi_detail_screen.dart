import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/koi.dart';
import '../../services/koi_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import 'widgets/koi_genealogy_card.dart';
import 'widgets/koi_growth_section.dart';
import 'widgets/koi_hero_header.dart';
import 'widgets/koi_identity_card.dart';
import 'widgets/koi_photo_gallery.dart';
import '../../services/photo_store.dart';
import '../../services/pending_write.dart';

/// La fiche d'un koï. Elle orchestre ; chaque section vit dans son widget.
class KoiDetailScreen extends StatelessWidget {
  final String koiId;

  /// Données déjà connues par l'écran appelant : elles évitent un écran de
  /// chargement le temps que le flux Firestore réponde.
  final Koi? initialKoi;

  const KoiDetailScreen({super.key, required this.koiId, this.initialKoi});

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
            return _message(context, "Erreur : ${snapshot.error}");
          }

          final Koi? found;
          if (snapshot.hasData && snapshot.data!.exists) {
            found = Koi.fromFirestore(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            found = initialKoi;
          } else {
            return _message(context, "Ce koï n'existe plus.");
          }

          if (found == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Dart ne conserve pas la promotion de type à l'intérieur d'une
          // closure pour une variable affectée après sa déclaration.
          final Koi koi = found;

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
                    onPressed: () =>
                        context.push('/koi/${koi.id}/edit', extra: koi),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: KoiHeroHeader(
                  koi: koi,
                  onAddPhoto: () => _addPhoto(context, koi),
                ),
              ),
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
                      KoiPhotoGallery(
                        koi: koi,
                        onAdd: () => _addPhoto(context, koi),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Identité",
                        icon: Icons.fingerprint_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      KoiIdentityCard(koi: koi),

                      if (koi.breeder != null || koi.origin != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(
                          title: "Provenance",
                          icon: Icons.storefront_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        KoiOriginCard(koi: koi),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Généalogie",
                        icon: Icons.account_tree_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      KoiGenealogyCard(koi: koi),

                      const SizedBox(height: AppSpacing.lg),
                      const SectionHeader(
                        title: "Croissance",
                        icon: Icons.straighten_rounded,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      KoiGrowthSection(koi: koi),

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

  Widget _message(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.texts.bodyMedium,
        ),
      ),
    );
  }

  Future<void> _addPhoto(BuildContext context, Koi koi) async {
    final XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Sans les métadonnées, dont l'appli n'a pas l'usage : iOS n'a alors pas
      // à demander l'accès à toute la photothèque.
      requestFullMetadata: false,
      maxWidth: PhotoStore.maxSide.toDouble(),
      maxHeight: PhotoStore.maxSide.toDouble(),
      imageQuality: PhotoStore.pickQuality,
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
      // Une photo pèse plusieurs centaines de kilo-octets : plus de patience
      // que pour une fiche.
      final confirmed = await KoiService.addPhoto(
        koi,
        imageBytes,
      ).confirmedWithin(const Duration(seconds: 20));

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            confirmed ? "Photo ajoutée à la galerie." : pendingWriteMessage,
          ),
        ),
      );
    } catch (e) {
      debugPrint("[AOI] Photo non enregistrée : $e");
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text("Erreur lors du transfert : $e")),
      );
    }
  }
}
