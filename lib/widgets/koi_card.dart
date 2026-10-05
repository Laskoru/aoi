import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/koi.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import 'photo_image.dart';

/// Vignette d'un koï dans une grille : sa photo en fond, ses repères
/// par-dessus. Le tap ouvre la fiche, avec la carte en transition partagée.
class KoiCard extends StatelessWidget {
  final Koi koi;

  const KoiCard({super.key, required this.koi});

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

    return Semantics(
      button: true,
      label: '${koi.name}, ${koi.variety}, ${koi.ageLabel()}',
      child: GestureDetector(
        onTap: () => context.push('/koi/${koi.id}', extra: koi),
        child: Hero(
          tag: 'koi-${koi.id}',
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
                  Image(
                    image: photoImage(koi.imageUrl!, width: 600),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _placeholder(context),
                  )
                else
                  _placeholder(context),

                // Voile dégradé : sans lui, un nom clair sur une écaille
                // claire devient illisible.
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
                              color: hasImage
                                  ? Colors.white
                                  : colors.onSurfaceVariant,
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
                          Icon(
                            Icons.cake_rounded,
                            size: 11,
                            color: secondaryText,
                          ),
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
        ),
      ),
    );
  }

  /// Fond des fiches sans photo : un dégradé d'eau et l'emblème.
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
        child: KoiEmblem(
          size: 56,
          color: colors.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
