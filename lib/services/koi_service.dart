import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/koi.dart';
import 'photo_store.dart';

/// Écritures sur la collection des koï qui touchent à plusieurs endroits à la
/// fois, et qu'on ne veut pas voir dupliquées d'un écran à l'autre.
class KoiService {
  const KoiService._();

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('kois');

  /// Crée une fiche et l'horodate.
  static Future<void> create(Koi koi) {
    return _collection.add({
      ...koi.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Met à jour une fiche existante.
  ///
  /// `createdAt` n'est pas dans [Koi.toMap] et reste donc intact ; l'ancien
  /// champ `age` est effacé dès qu'une date de naissance est renseignée, pour
  /// qu'une valeur périmée ne traîne pas à côté de la vraie.
  static Future<void> update(Koi koi) {
    return _collection.doc(koi.id).update({
      ...koi.toMap(),
      if (koi.birthDate != null) 'age': FieldValue.delete(),
    });
  }

  // --- Croissance et naissance ---

  /// Les derniers relevés de taille, du plus ancien au plus récent : prêts à
  /// tracer de gauche à droite.
  static Stream<List<GrowthEntry>> growthOf(String koiId, {int limit = 10}) {
    return _collection
        .doc(koiId)
        .collection('growth')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.reversed.map(GrowthEntry.fromFirestore).toList());
  }

  /// Enregistre une nouvelle taille.
  ///
  /// La taille courante sur la fiche et le point d'historique doivent
  /// toujours bouger ensemble : un batch garantit qu'aucun des deux ne part
  /// sans l'autre.
  static Future<void> recordSize(String koiId, double size) {
    final koiRef = _collection.doc(koiId);
    final batch = FirebaseFirestore.instance.batch();
    batch.update(koiRef, {'size': size});
    batch.set(koiRef.collection('growth').doc(), {
      'size': size,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return batch.commit();
  }

  /// Renseigne ou corrige la naissance, et retire l'ancien champ `age` pour
  /// qu'une valeur périmée ne subsiste pas à côté de la vraie.
  static Future<void> setBirthDate(String koiId, DateTime date) {
    return _collection.doc(koiId).update({
      'birthDate': Timestamp.fromDate(date),
      'age': FieldValue.delete(),
    });
  }

  // --- Galerie photo ---

  /// Flux des photos d'un koï, de la plus récente à la plus ancienne.
  static Stream<List<KoiPhoto>> photosOf(String koiId) {
    return _collection
        .doc(koiId)
        .collection('photos')
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(KoiPhoto.fromFirestore).toList());
  }

  /// Ajoute une photo à la galerie.
  ///
  /// La première photo devient d'office la principale : sans cela, un koï
  /// resterait sans vignette alors qu'une photo existe.
  static Future<void> addPhoto(Koi koi, Uint8List bytes) async {
    final url = await PhotoStore.save(koi.userId, bytes);

    await _collection.doc(koi.id).collection('photos').add({
      'url': url,
      'takenAt': FieldValue.serverTimestamp(),
    });

    if (koi.imageUrl == null) {
      await _collection.doc(koi.id).update({'imageUrl': url});
    }
  }

  /// Désigne la photo qui représente le koï dans la grille et l'en-tête.
  static Future<void> setMainPhoto(Koi koi, KoiPhoto photo) {
    return _collection.doc(koi.id).update({'imageUrl': photo.url});
  }

  /// Retire une photo de la galerie.
  ///
  /// Si c'était la photo principale, une autre prend sa place, à défaut le koï
  /// revient à sa vignette par défaut.
  static Future<void> deletePhoto(Koi koi, KoiPhoto photo) async {
    await _collection.doc(koi.id).collection('photos').doc(photo.id).delete();
    await PhotoStore.delete(photo.url);

    if (koi.imageUrl != photo.url) return;

    final remaining = await _collection
        .doc(koi.id)
        .collection('photos')
        .orderBy('takenAt', descending: true)
        .limit(1)
        .get();

    await _collection.doc(koi.id).update({
      'imageUrl': remaining.docs.isEmpty
          ? null
          : remaining.docs.first.data()['url'],
    });
  }

  /// Supprime une fiche, son historique de croissance, sa galerie et sa photo.
  ///
  /// Firestore ne supprime pas les sous-collections avec le document parent :
  /// les relevés de croissance resteraient orphelins et invisibles, il faut
  /// donc les effacer explicitement.
  ///
  /// Les koï qui désignent celui-ci comme parent conservent une référence
  /// morte ; la fiche généalogique affiche alors « Introuvable ». C'est
  /// volontaire : effacer aussi la filiation des descendants ferait perdre
  /// l'information qu'un parent a existé.
  static Future<void> delete(Koi koi) async {
    final doc = _collection.doc(koi.id);
    final growth = await doc.collection('growth').get();
    final photos = await doc.collection('photos').get();

    final batch = FirebaseFirestore.instance.batch();
    for (final entry in growth.docs) {
      batch.delete(entry.reference);
    }
    for (final photo in photos.docs) {
      batch.delete(photo.reference);
    }
    batch.delete(doc);
    await batch.commit();

    final galleryUrls = [
      for (final photo in photos.docs) photo.data()['url'] as String?,
    ];
    for (final url in galleryUrls) {
      await PhotoStore.delete(url);
    }

    // Photo unique des versions antérieures à la galerie : principale sans
    // figurer dans la galerie.
    if (!galleryUrls.contains(koi.imageUrl)) {
      await PhotoStore.delete(koi.imageUrl);
    }
  }
}
