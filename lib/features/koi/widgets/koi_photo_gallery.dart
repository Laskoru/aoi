import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../models/koi.dart';
import '../../../services/koi_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';
import '../../../widgets/photo_image.dart';
import '../../../services/pending_write.dart';

/// Bande de photos d'un koï.
///
/// Le motif d'un koï change avec les années : la galerie garde la suite des
/// clichés, là où l'ancienne version écrasait l'unique photo à chaque envoi.
class KoiPhotoGallery extends StatelessWidget {
  final Koi koi;
  final Future<void> Function() onAdd;

  const KoiPhotoGallery({super.key, required this.koi, required this.onAdd});

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

    return Semantics(
      button: true,
      label: context.l10n.addPhoto,
      child: InkWell(
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
              Text(context.l10n.commonAdd, style: context.texts.labelMedium),
            ],
          ),
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
    return Semantics(
      button: true,
      label: isMain ? context.l10n.photoMain : context.l10n.photo,
      child: InkWell(
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
              Image(
                image: photoImage(photo.url, width: 400),
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
                        context.l10n.photoMainBadge,
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
              child: Center(child: Image(image: photoImage(photo.url))),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: context.l10n.commonClose,
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
                        label: Text(context.l10n.photoSetMain),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final l10n = context.l10n;
                          try {
                            final confirmed = await KoiService.setMainPhoto(
                              koi,
                              photo,
                            ).confirmedWithin();
                            if (!confirmed) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(l10n.pendingWrite)),
                              );
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(l10n.updateError(e))),
                            );
                          }
                          navigator.pop();
                        },
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: Text(context.l10n.commonDelete),
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
        title: Text(dialogContext.l10n.photoDeleteTitle),
        content: Text(dialogContext.l10n.photoDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: dialogContext.pond.danger,
            ),
            child: Text(dialogContext.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final confirmed = await KoiService.deletePhoto(
        koi,
        photo,
      ).confirmedWithin();
      navigator.pop();
      if (!confirmed) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.pendingWrite)));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteError(e))));
    }
  }
}
