import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/water_logic.dart';

/// Un relevé des paramètres de l'eau du bassin.
///
/// pH et température sont les deux valeurs relevées systématiquement. Les
/// autres correspondent aux bandelettes de test multi-paramètres et restent
/// facultatives : un document ancien ou une saisie rapide ne les contient pas.
class WaterMeasurement {
  final String id;
  final String userId;
  final DateTime? measuredAt;
  final double ph;
  final double temperature;
  final double? kh;
  final double? gh;
  final double? nitrite;
  final double? nitrate;
  final double? ammonia;

  const WaterMeasurement({
    required this.id,
    required this.userId,
    required this.ph,
    required this.temperature,
    this.measuredAt,
    this.kh,
    this.gh,
    this.nitrite,
    this.nitrate,
    this.ammonia,
  });

  /// Les valeurs effectivement relevées, dans l'ordre d'affichage.
  ///
  /// pH et température figurent toujours ; les autres n'apparaissent que si
  /// elles ont été saisies, une mesure rapide n'en contenant aucune.
  List<WaterReading> get readings => [
    WaterReading(WaterParameter.ph, ph),
    WaterReading(WaterParameter.temperature, temperature),
    if (ammonia != null) WaterReading(WaterParameter.ammonia, ammonia!),
    if (nitrite != null) WaterReading(WaterParameter.nitrite, nitrite!),
    if (nitrate != null) WaterReading(WaterParameter.nitrate, nitrate!),
    if (kh != null) WaterReading(WaterParameter.kh, kh!),
    if (gh != null) WaterReading(WaterParameter.gh, gh!),
  ];

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'ph': ph,
    'temperature': temperature,
    if (kh != null) 'kh': kh,
    if (gh != null) 'gh': gh,
    if (nitrite != null) 'nitrite': nitrite,
    if (nitrate != null) 'nitrate': nitrate,
    if (ammonia != null) 'ammonia': ammonia,
  };

  factory WaterMeasurement.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return WaterMeasurement(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      ph: (data['ph'] as num? ?? 0).toDouble(),
      temperature: (data['temperature'] as num? ?? 0).toDouble(),
      measuredAt: (data['timestamp'] as Timestamp?)?.toDate(),
      kh: (data['kh'] as num?)?.toDouble(),
      gh: (data['gh'] as num?)?.toDouble(),
      nitrite: (data['nitrite'] as num?)?.toDouble(),
      nitrate: (data['nitrate'] as num?)?.toDouble(),
      ammonia: (data['ammonia'] as num?)?.toDouble(),
    );
  }
}
