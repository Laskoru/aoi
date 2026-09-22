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
  static Future<void> ensureDefault(String userId) async {
    final ref = _collection.doc(Pond.defaultIdFor(userId));
    final snapshot = await ref.get();
    if (snapshot.exists) return;

    await ref.set({
      'userId': userId,
      'name': 'Mon bassin',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Le bassin par défaut, en flux.
  static Stream<Pond?> defaultOf(String userId) {
    return _collection
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
