import 'package:flutter/material.dart';
import '../../../models/koi.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_widgets.dart';

/// En-tête de la fiche : la photo principale sur le dégradé d'eau, le nom,
/// la variété, et les repères en pastilles.
///
/// C'est la cible de la transition partagée lancée depuis la vignette de la
/// grille : la carte s'étire jusqu'à cet en-tête.
class KoiHeroHeader extends StatelessWidget {
  final Koi koi;
  final VoidCallback onAddPhoto;

  const KoiHeroHeader({super.key, required this.koi, required this.onAddPhoto});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'koi-${koi.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            bottom: AppSpacing.xl,
            top: AppSpacing.sm,
          ),
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
                label: "Ajouter une photo",
                child: GestureDetector(
                  onTap: onAddPhoto,
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
                              ? const KoiEmblem(size: 60, color: Colors.white)
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
        ),
      ),
    );
  }
}
