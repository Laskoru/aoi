import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;

/// Photos de l'appli, rangées dans Firestore.
///
/// Cloud Storage n'est plus accessible sans la formule Blaze, payante à
/// l'usage, depuis février 2026 ; Firestore reste gratuit jusqu'à 1 Gio.
/// Chaque photo est un document `photos/{id}` qui porte l'image en JPEG, sous
/// la limite d'un document (1 Mio). Les fiches y renvoient par une référence
/// `photo:{id}` rangée dans leur champ `imageUrl` ; les anciennes adresses web
/// y restent lisibles telles quelles.
///
/// Une photo ne change jamais : on en enregistre une nouvelle et on supprime
/// l'ancienne. Le cache local de Firestore peut donc toujours servir.
class PhotoStore {
  const PhotoStore._();

  static const _scheme = 'photo:';

  /// Poids maximal d'une photo enregistrée. Les règles Firestore appliquent
  /// la même limite.
  static const maxBytes = 900 * 1024;

  /// Plus grand côté d'une photo de fiche, en pixels : assez pour l'afficher
  /// en grand, assez peu pour loger quelques milliers de photos dans le
  /// gigaoctet gratuit.
  static const maxSide = 1280;

  /// Plus grand côté de la photo du bassin, montrée en bandeau sur toute la
  /// largeur, tablettes comprises.
  static const pondMaxSide = 1920;

  /// Qualité JPEG demandée au sélecteur de photos.
  static const pickQuality = 85;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('photos');

  /// Vrai si [ref] désigne une photo rangée dans Firestore.
  static bool isStored(String? ref) => ref != null && ref.startsWith(_scheme);

  static String idOf(String ref) => ref.substring(_scheme.length);

  static String refFor(String id) => '$_scheme$id';

  /// Compresse une photo et prépare son document, sans l'écrire : l'appelant
  /// l'ajoute au même lot que la fiche qui la désigne, pour que la photo et
  /// sa référence partent ensemble ou pas du tout.
  static Future<PreparedPhoto> prepare(
    String userId,
    Uint8List bytes, {
    int maxSide = maxSide,
  }) async {
    final jpeg = await compress(bytes, maxSide: maxSide);
    return PreparedPhoto._(_collection.doc(), {
      'userId': userId,
      'data': Blob(jpeg),
      'createdAt': FieldValue.serverTimestamp(),
    });
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
      // Pas l'adresse elle-même : celle d'un fichier Storage porte un jeton
      // d'accès, qui n'a rien à faire dans les journaux.
      debugPrint('[AOI] Photo non supprimée '
          '(${isStored(ref) ? ref : 'ancienne photo Storage'}) : $e');
    }
  }

  static bool _isStorageUrl(String ref) =>
      ref.startsWith('gs://') || ref.contains('firebasestorage.googleapis.com');

  /// Supprime les photos d'un utilisateur qui restent encore. Appelée en fin
  /// de suppression du compte, une fois les fiches parties avec leurs photos :
  /// ne restent alors que d'éventuelles orphelines.
  static Future<void> deleteAllOf(String userId) async {
    final docs = (await _collection
            .where('userId', isEqualTo: userId)
            .get(const GetOptions(source: Source.server)))
        .docs;
    for (var start = 0; start < docs.length; start += 400) {
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in docs.skip(start).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Réencode une image en JPEG d'au plus [maxBytes], réduite à [maxSide]
  /// pixels, hors du fil de l'interface quand la plateforme le permet.
  ///
  /// Toujours réencodée, même déjà légère : c'est ce qui retire les
  /// métadonnées, dont la position GPS qu'un téléphone inscrit dans ses
  /// photos — celle du jardin, donc du domicile.
  static Future<Uint8List> compress(Uint8List bytes, {int maxSide = maxSide}) =>
      compute(_reencode, (bytes, maxSide));

  static Uint8List _reencode((Uint8List, int) job) {
    final (bytes, side) = job;
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException("Format d'image non reconnu.");
    }
    // Le sens de prise de vue est lui aussi une métadonnée : on l'applique
    // aux pixels avant de tout effacer.
    final image = img.bakeOrientation(decoded)..exif = img.ExifData();
    for (final (factor, quality) in const [(1.0, 82), (0.8, 74), (0.64, 66)]) {
      final limit = (side * factor).round();
      final resized = image.width > limit || image.height > limit
          ? img.copyResize(
              image,
              width: image.width >= image.height ? limit : null,
              height: image.height > image.width ? limit : null,
              interpolation: img.Interpolation.average,
            )
          : image;
      final jpeg = img.encodeJpg(resized, quality: quality);
      if (jpeg.length <= maxBytes) return jpeg;
    }
    throw StateError('Photo trop lourde, même compressée.');
  }
}

/// Une photo compressée, prête à rejoindre un lot d'écritures.
class PreparedPhoto {
  final DocumentReference<Map<String, dynamic>> _doc;
  final Map<String, dynamic> _data;

  const PreparedPhoto._(this._doc, this._data);

  /// La référence à ranger dans le champ `imageUrl` de la fiche.
  String get ref => PhotoStore.refFor(_doc.id);

  void addTo(WriteBatch batch) => batch.set(_doc, _data);
}
