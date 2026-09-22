import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/plant.dart';

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

  static String _photoPath(Plant plant) =>
      'user_media/${plant.userId}/plants/${plant.id}.jpg';

  /// Remplace la photo de la plante. Une seule suffit : un pot de nénuphar
  /// ne change pas de motif d'une année sur l'autre.
  static Future<void> setPhoto(Plant plant, Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref(_photoPath(plant));
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _collection.doc(plant.id).update({'imageUrl': url});
  }

  static Future<void> delete(Plant plant) async {
    await _collection.doc(plant.id).delete();
    // Le fichier est secondaire : son absence ne doit pas faire échouer la
    // suppression de la fiche, déjà effectuée.
    try {
      await FirebaseStorage.instance.ref(_photoPath(plant)).delete();
    } catch (e) {
      debugPrint('[AOI] Photo de plante non supprimée : $e');
    }
  }
}
