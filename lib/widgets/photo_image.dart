import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../services/photo_store.dart';

/// L'image d'une photo de l'appli, d'où qu'elle vienne : document Firestore
/// (`photo:{id}`) ou ancienne adresse web.
///
/// [width] décode la photo à cette largeur au plus, en pixels : une vignette
/// de 56 points n'a pas à occuper en mémoire une image de 1 280 pixels, et
/// une grille de koï y gagne des dizaines de mégaoctets.
ImageProvider photoImage(String ref, {int? width}) {
  if (PhotoStore.isStored(ref)) {
    return StoredPhotoImage(PhotoStore.idOf(ref), width: width);
  }
  final network = NetworkImage(ref);
  return width == null ? network : ResizeImage(network, width: width);
}

/// Une photo rangée dans Firestore, décodée puis gardée en cache par Flutter
/// comme n'importe quelle image : deux écrans qui montrent la même photo à la
/// même taille ne la téléchargent qu'une fois.
@immutable
class StoredPhotoImage extends ImageProvider<StoredPhotoImage> {
  final String id;

  /// Largeur de décodage, en pixels ; nulle pour la taille d'origine.
  final int? width;

  const StoredPhotoImage(this.id, {this.width});

  @override
  Future<StoredPhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<StoredPhotoImage>(this);

  @override
  ImageStreamCompleter loadImage(
    StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: 1,
      debugLabel: 'photo:$id',
    );
  }

  Future<ui.Codec> _load(StoredPhotoImage key, ImageDecoderCallback decode) async {
    try {
      final bytes = await PhotoStore.read(id);
      final target = width;
      return await decode(
        await ui.ImmutableBuffer.fromUint8List(bytes),
        getTargetSize: target == null
            ? null
            : (w, h) => w <= target
                  ? ui.TargetImageSize(width: w, height: h)
                  : ui.TargetImageSize(width: target),
      );
    } catch (_) {
      // Un échec (hors réseau, par exemple) resterait sinon en cache jusqu'au
      // redémarrage : on l'en retire, l'affichage suivant réessaiera.
      scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is StoredPhotoImage && other.id == id && other.width == width;

  @override
  int get hashCode => Object.hash(id, width);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'StoredPhotoImage')}("$id", width: $width)';
}
