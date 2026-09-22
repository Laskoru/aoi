import 'package:cloud_firestore/cloud_firestore.dart';
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
}
