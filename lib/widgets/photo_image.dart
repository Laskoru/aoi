import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import '../services/photo_store.dart';

/// L'image d'une photo de l'appli, d'où qu'elle vienne : document Firestore
/// (`photo:{id}`) ou ancienne adresse web.
ImageProvider photoImage(String ref) => PhotoStore.isStored(ref)
    ? StoredPhotoImage(PhotoStore.idOf(ref))
    : NetworkImage(ref);

/// Une photo rangée dans Firestore, décodée puis gardée en cache par Flutter
/// comme n'importe quelle image : deux écrans qui montrent la même photo ne
/// la téléchargent qu'une fois.
@immutable
class StoredPhotoImage extends ImageProvider<StoredPhotoImage> {
  final String id;

  const StoredPhotoImage(this.id);

  @override
  Future<StoredPhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<StoredPhotoImage>(this);

  @override
  ImageStreamCompleter loadImage(
    StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: 'photo:$id',
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await PhotoStore.read(id);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is StoredPhotoImage && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${objectRuntimeType(this, 'StoredPhotoImage')}("$id")';
}
