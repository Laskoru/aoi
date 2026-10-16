import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pond.dart';
import 'photo_store.dart';

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
  ///
  /// Une seule vérification par session et par compte : les écrans
  /// s'abonnent au bassin à chaque reconstruction, et chaque vérification
  /// coûterait une lecture.
  static Future<void> ensureDefault(String userId) async {
    if (_ensured.contains(userId)) return;
    final ref = _collection.doc(Pond.defaultIdFor(userId));
    try {
      if ((await ref.get()).exists) {
        _ensured.add(userId);
        return;
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }

    // Sans nom : l'interface l'appelle « Mon bassin » dans sa langue, tant
    // que l'utilisateur n'en choisit pas un.
    await ref.set({
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    _ensured.add(userId);
  }

  static final _ensured = <String>{};

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

  /// Met à jour la fiche, sans toucher à sa photo : seul [setPhoto] la
  /// change. Un formulaire ouvert avant l'envoi d'une photo remettrait sinon
  /// l'ancienne, qui n'existe plus.
  static Future<void> update(Pond pond) {
    return _collection.doc(pond.id).update(pond.toMap()..remove('imageUrl'));
  }

  /// La photo du bassin, affichée en fond de l'accueil à la place de l'eau.
  ///
  /// Plus large que les autres photos : elle couvre toute la largeur de
  /// l'écran. La photo et sa référence partent dans un seul lot ; l'ancienne
  /// n'est effacée qu'une fois la nouvelle en place.
  static Future<void> setPhoto(Pond pond, Uint8List bytes) async {
    final photo = await PhotoStore.prepare(
      pond.userId,
      bytes,
      maxSide: PhotoStore.pondMaxSide,
    );
    final batch = FirebaseFirestore.instance.batch();
    photo.addTo(batch);
    batch.update(_collection.doc(pond.id), {'imageUrl': photo.ref});
    await batch.commit();
    await PhotoStore.delete(pond.imageUrl);
  }

  /// Supprime le bassin et sa photo.
  static Future<void> delete(Pond pond) async {
    await _collection.doc(pond.id).delete();
    await PhotoStore.delete(pond.imageUrl);
  }

  /// Retire la photo : l'accueil revient à l'eau calme.
  static Future<void> removePhoto(Pond pond) async {
    await _collection.doc(pond.id).update({'imageUrl': null});
    await PhotoStore.delete(pond.imageUrl);
  }
}
