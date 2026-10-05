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

  static Future<void> create(FishGroup group) {
    return _collection.add({
      ...group.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> update(FishGroup group) {
    return _collection.doc(group.id).update(group.toMap());
  }

  static Future<void> setPhoto(FishGroup group, Uint8List bytes) async {
    final url = await PhotoStore.save(group.userId, bytes);
    await _collection.doc(group.id).update({'imageUrl': url});
    await PhotoStore.delete(group.imageUrl);
  }

  static Future<void> delete(FishGroup group) async {
    await _collection.doc(group.id).delete();
    await PhotoStore.delete(group.imageUrl);
  }
}
