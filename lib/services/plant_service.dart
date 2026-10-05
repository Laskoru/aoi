import 'package:flutter/foundation.dart' show Uint8List;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import 'photo_store.dart';

/// Accès aux plantes du bassin.
class PlantService {
  const PlantService._();

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('plants');

  static Stream<List<Plant>> watchAll(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Plant.fromFirestore).toList());
  }

  static Stream<Plant?> watchOne(String plantId) {
    return _collection
        .doc(plantId)
        .snapshots()
        .map((doc) => doc.exists ? Plant.fromFirestore(doc) : null);
  }

  static Future<void> create(Plant plant) {
    return _collection.add({
      ...plant.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> update(Plant plant) {
    return _collection.doc(plant.id).update(plant.toMap());
  }

  /// Remplace la photo de la plante. Une seule suffit : un pot de nénuphar
  /// ne change pas de motif d'une année sur l'autre.
  static Future<void> setPhoto(Plant plant, Uint8List bytes) async {
    final url = await PhotoStore.save(plant.userId, bytes);
    await _collection.doc(plant.id).update({'imageUrl': url});
    await PhotoStore.delete(plant.imageUrl);
  }

  static Future<void> delete(Plant plant) async {
    await _collection.doc(plant.id).delete();
    await PhotoStore.delete(plant.imageUrl);
  }
}
