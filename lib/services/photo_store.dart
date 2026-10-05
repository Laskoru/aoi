import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

/// Photos de l'appli, rangées dans Firestore.
///
/// Cloud Storage n'est plus accessible sans la formule Blaze, payante à
/// l'usage, depuis février 2026 ; Firestore reste gratuit jusqu'à 1 Gio.
/// Chaque photo est un document `photos/{id}` qui porte l'image compressée en
/// JPEG, sous la limite d'un document (1 Mio). Les fiches y renvoient par une
/// référence `photo:{id}` rangée dans leur champ `imageUrl` ; les anciennes
/// adresses web y restent lisibles telles quelles.
///
/// Une photo ne change jamais : on en enregistre une nouvelle et on supprime
/// l'ancienne. Le cache local de Firestore peut donc toujours servir.
class PhotoStore {
  const PhotoStore._();

  static const _scheme = 'photo:';

  /// Poids maximal d'une photo enregistrée. Les règles Firestore appliquent
  /// la même limite.
  static const maxBytes = 900 * 1024;

  /// Plus grand côté d'une photo, en pixels : à la sélection dans la
  /// galerie du téléphone comme à la recompression.
  static const maxSide = 1600;

  /// Qualité JPEG demandée au sélecteur de photos.
  static const pickQuality = 80;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('photos');

  /// Vrai si [ref] désigne une photo rangée dans Firestore.
  static bool isStored(String? ref) => ref != null && ref.startsWith(_scheme);

  static String idOf(String ref) => ref.substring(_scheme.length);

  static String refFor(String id) => '$_scheme$id';

  /// Compresse puis enregistre une photo, et rend sa référence.
  static Future<String> save(String userId, Uint8List bytes) async {
    final jpeg = await compress(bytes);
    final doc = _collection.doc();
    await doc.set({
      'userId': userId,
      'data': Blob(jpeg),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return refFor(doc.id);
  }

  /// Les octets d'une photo : le cache local d'abord, le serveur sinon.
  static Future<Uint8List> read(String id) async {
    final doc = _collection.doc(id);
    DocumentSnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await doc.get(const GetOptions(source: Source.cache));
    } catch (_) {
      // Absente du cache, ou pas de cache du tout (le web n'en tient pas).
      snapshot = await doc.get();
    }
    final data = snapshot.data()?['data'];
    if (data is! Blob) throw StateError('Photo $id introuvable');
    return data.bytes;
  }

  /// Supprime la photo désignée par [ref] : son document Firestore, ou le
  /// fichier Cloud Storage d'une photo plus ancienne (sans la formule Blaze,
  /// Storage refuse et la tentative reste sans effet). Un échec n'interrompt
  /// pas l'opération en cours, déjà faite : il laisse au pire une photo
  /// orpheline, que la suppression du compte rattrape.
  static Future<void> delete(String? ref) async {
    if (ref == null || ref.isEmpty) return;
    try {
      if (isStored(ref)) {
        await _collection.doc(idOf(ref)).delete();
      } else if (_isStorageUrl(ref)) {
        await FirebaseStorage.instance.refFromURL(ref).delete();
      }
    } catch (e) {
      debugPrint('[AOI] Photo non supprimée ($ref) : $e');
    }
  }

  static bool _isStorageUrl(String ref) =>
      ref.startsWith('gs://') || ref.contains('firebasestorage.googleapis.com');

  /// Supprime les photos d'un utilisateur qui restent encore. Appelée en fin
  /// de suppression du compte, une fois les fiches parties avec leurs photos :
  /// ne restent alors que d'éventuelles orphelines.
  static Future<void> deleteAllOf(String userId) async {
    final docs =
        (await _collection.where('userId', isEqualTo: userId).get()).docs;
    for (var start = 0; start < docs.length; start += 400) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in docs.skip(start).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Ramène une image sous [maxBytes]. Un JPEG déjà assez léger passe tel
  /// quel ; le reste est réduit à [maxSide] pixels et réencodé, hors du fil
  /// de l'interface quand la plateforme le permet.
  static Future<Uint8List> compress(Uint8List bytes) async {
    if (bytes.length <= maxBytes && _isJpeg(bytes)) return bytes;
    return compute(_reencode, bytes);
  }

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length > 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;

  static Uint8List _reencode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException("Format d'image non reconnu.");
    }
    // Une photo de téléphone porte souvent son sens de prise de vue en
    // métadonnée : on l'applique avant de la perdre au réencodage.
    final image = img.bakeOrientation(decoded);
    for (final (side, quality) in const [(maxSide, 82), (1280, 75), (1024, 65)]) {
      final resized = image.width > side || image.height > side
          ? img.copyResize(
              image,
              width: image.width >= image.height ? side : null,
              height: image.height > image.width ? side : null,
              interpolation: img.Interpolation.average,
            )
          : image;
      final jpeg = img.encodeJpg(resized, quality: quality);
      if (jpeg.length <= maxBytes) return jpeg;
    }
    throw StateError('Photo trop lourde, même compressée.');
  }
}
