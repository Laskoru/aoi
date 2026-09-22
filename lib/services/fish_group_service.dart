import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/fish_group.dart';

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

  static String _photoPath(FishGroup group) =>
      'user_media/${group.userId}/fish_groups/${group.id}.jpg';

  static Future<void> setPhoto(FishGroup group, Uint8List bytes) async {
    final ref = FirebaseStorage.instance.ref(_photoPath(group));
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url = await ref.getDownloadURL();
    await _collection.doc(group.id).update({'imageUrl': url});
  }

  static Future<void> delete(FishGroup group) async {
    await _collection.doc(group.id).delete();
    try {
      await FirebaseStorage.instance.ref(_photoPath(group)).delete();
    } catch (e) {
      debugPrint('[AOI] Photo de groupe non supprimée : $e');
    }
  }
}
