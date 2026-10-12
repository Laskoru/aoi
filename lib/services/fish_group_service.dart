import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fish_group.dart';
import 'photo_store.dart';

/// Accès aux groupes de poissons autres que les koï.
class FishGroupService {
  const FishGroupService._();

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('fish_groups');

  static Stream<List<FishGroup>> watchAll(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(FishGroup.fromFirestore).toList());
  }

  /// Crée un groupe, avec sa photo s'il y en a une : la fiche et l'image
  /// partent dans un seul lot, jamais l'une sans l'autre.
  static Future<void> create(FishGroup group, {Uint8List? photo}) async {
    final batch = FirebaseFirestore.instance.batch();
    String? imageUrl;
    if (photo != null) {
      final prepared = await PhotoStore.prepare(group.userId, photo);
      prepared.addTo(batch);
      imageUrl = prepared.ref;
    }
    batch.set(_collection.doc(), {
      ...group.toMap(),
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Met à jour la fiche, sans toucher à sa photo : seul [setPhoto] la
  /// change. Un formulaire ouvert avant l'envoi d'une photo remettrait sinon
  /// l'ancienne, qui n'existe plus.
  static Future<void> update(FishGroup group) {
    return _collection.doc(group.id).update(group.toMap()..remove('imageUrl'));
  }

  /// Remplace la photo du groupe : la photo et sa référence partent dans un
  /// seul lot, l'ancienne n'est effacée qu'une fois la nouvelle en place.
  static Future<void> setPhoto(FishGroup group, Uint8List bytes) async {
    final photo = await PhotoStore.prepare(group.userId, bytes);
    final batch = FirebaseFirestore.instance.batch();
    photo.addTo(batch);
    batch.update(_collection.doc(group.id), {'imageUrl': photo.ref});
    await batch.commit();
    await PhotoStore.delete(group.imageUrl);
  }

  static Future<void> delete(FishGroup group) async {
    await _collection.doc(group.id).delete();
    await PhotoStore.delete(group.imageUrl);
  }
}
