import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/koi.dart';

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

  /// Supprime une fiche, son historique de croissance et sa photo.
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

    final batch = FirebaseFirestore.instance.batch();
    for (final entry in growth.docs) {
      batch.delete(entry.reference);
    }
    batch.delete(doc);
    await batch.commit();

    // La photo est secondaire : son absence ne doit pas faire échouer la
    // suppression de la fiche, déjà effectuée.
    try {
      await FirebaseStorage.instance
          .ref()
          .child('kois_photos')
          .child(koi.userId)
          .child('${koi.id}.jpg')
          .delete();
    } catch (e) {
      debugPrint('[AOI] Photo non supprimée (probablement absente) : $e');
    }
  }
}
