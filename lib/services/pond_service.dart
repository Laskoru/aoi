import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/pond.dart';

/// Accès au bassin de l'utilisateur.
class PondService {
  const PondService._();

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('ponds');

  /// Garantit l'existence du bassin par défaut sans jamais écraser ce que
  /// l'utilisateur y a déjà saisi : on ne crée que s'il n'existe pas.
  ///
  /// Les règles d'origine refusent de lire un bassin encore absent : elles
  /// vérifient le propriétaire du document lu, et il n'y en a pas. La lecture
  /// préalable échouait donc, et le bassin n'était jamais créé. Un refus à la
  /// lecture vaut ici « absent » ; la création reste permise au seul
  /// propriétaire.
  static Future<void> ensureDefault(String userId) async {
    final ref = _collection.doc(Pond.defaultIdFor(userId));
    try {
      if ((await ref.get()).exists) return;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    await ref.set({
      'userId': userId,
      'name': 'Mon bassin',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Le bassin par défaut, en flux. Il est créé au besoin avant l'écoute :
  /// la connexion le crée aussi, mais l'écran peut s'abonner avant, et un
  /// abonnement refusé par les règles ne se rétablit pas de lui-même.
  static Stream<Pond?> defaultOf(String userId) async* {
    try {
      await ensureDefault(userId);
    } catch (e) {
      debugPrint('[AOI] Bassin par défaut non vérifié : $e');
    }
    yield* _collection
        .doc(Pond.defaultIdFor(userId))
        .snapshots()
        .map((doc) => doc.exists ? Pond.fromFirestore(doc) : null);
  }

  static Future<void> update(Pond pond) {
    return _collection.doc(pond.id).update(pond.toMap());
  }

  static String _photoPath(Pond pond) =>
      'user_media/${pond.userId}/ponds/${pond.id}.jpg';

  /// La photo du bassin, affichée en fond de l'accueil à la place de l'eau.
  static Future<void> setPhoto(Pond pond, Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref(_photoPath(pond));
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _collection.doc(pond.id).update({'imageUrl': url});
  }

  /// Supprime le bassin et sa photo.
  static Future<void> delete(Pond pond) async {
    await _collection.doc(pond.id).delete();
    try {
      await FirebaseStorage.instance.ref(_photoPath(pond)).delete();
    } catch (e) {
      debugPrint('[AOI] Photo de bassin non supprimée (sans doute absente) : $e');
    }
  }

  /// Retire la photo : l'accueil revient à l'eau calme.
  static Future<void> removePhoto(Pond pond) async {
    await _collection.doc(pond.id).update({'imageUrl': null});
    try {
      await FirebaseStorage.instance.ref(_photoPath(pond)).delete();
    } catch (e) {
      debugPrint('[AOI] Photo de bassin non supprimée : $e');
    }
  }
}
