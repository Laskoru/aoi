import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/water_measurement.dart';

/// Accès aux relevés d'eau.
///
/// Jusqu'ici quatre écrans interrogeaient Firestore chacun de leur côté,
/// avec la même requête recopiée. Un point d'entrée unique évite qu'un
/// changement de collection ou d'index se propage à la main.
class MeasurementService {
  const MeasurementService._();

  static CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance.collection('measurements');

  static Query<Map<String, dynamic>> _ofUser(String userId) => _collection
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true);

  /// Le dernier relevé, ou `null` s'il n'y en a aucun.
  static Stream<WaterMeasurement?> latest(String userId) {
    return _ofUser(userId).limit(1).snapshots().map(
      (snap) => snap.docs.isEmpty
          ? null
          : WaterMeasurement.fromFirestore(snap.docs.first),
    );
  }

  /// L'historique, du plus récent au plus ancien.
  static Stream<List<WaterMeasurement>> history(
    String userId, {
    int limit = 200,
  }) {
    return _ofUser(userId).limit(limit).snapshots().map(
      (snap) => snap.docs.map(WaterMeasurement.fromFirestore).toList(),
    );
  }

  /// Les derniers relevés dans l'ordre chronologique, pour tracer une
  /// courbe de gauche à droite.
  static Stream<List<WaterMeasurement>> series(String userId, {int limit = 7}) {
    return _ofUser(userId).limit(limit).snapshots().map(
      (snap) => snap.docs.reversed.map(WaterMeasurement.fromFirestore).toList(),
    );
  }

  static Future<void> create(WaterMeasurement measurement) {
    return _collection.add({
      ...measurement.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> delete(String id) => _collection.doc(id).delete();
}
