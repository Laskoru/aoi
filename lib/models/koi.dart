import 'package:cloud_firestore/cloud_firestore.dart';

class Koi {
  final String id;
  final String name;
  final String variety;
  final double size;
  final int age;

  Koi({
    required this.id,
    required this.name,
    required this.variety,
    required this.size,
    required this.age,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'variety': variety,
    'size': size,
    'age': age,
  };

  factory Koi.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Koi(
      id: doc.id,
      name: data['name'] ?? 'Inconnu',
      variety: data['variety'] ?? '',
      size: (data['size'] ?? 0).toDouble(),
      age: data['age'] ?? 0,
    );
  }
}

class WaterMeasurement {
  final String id;
  final DateTime date;
  final double temperature;
  final double ph;
  final double carbonate;
  final double hardness;
  final double totalChlorine;
  final double freeChlorine;
  final double nitrate;
  final double nitrite;

  WaterMeasurement({
    required this.id,
    required this.date,
    required this.temperature,
    required this.ph,
    required this.carbonate,
    required this.hardness,
    required this.totalChlorine,
    required this.freeChlorine,
    required this.nitrate,
    required this.nitrite,
  });

  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'temperature': temperature,
    'ph': ph,
    'carbonate': carbonate,
    'hardness': hardness,
    'totalChlorine': totalChlorine,
    'freeChlorine': freeChlorine,
    'nitrate': nitrate,
    'nitrite': nitrite,
  };

  factory WaterMeasurement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return WaterMeasurement(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      temperature: (data['temperature'] ?? 0).toDouble(),
      ph: (data['ph'] ?? 0).toDouble(),
      carbonate: (data['carbonate'] ?? 0).toDouble(),
      hardness: (data['hardness'] ?? 0).toDouble(),
      totalChlorine: (data['totalChlorine'] ?? 0).toDouble(),
      freeChlorine: (data['freeChlorine'] ?? 0).toDouble(),
      nitrate: (data['nitrate'] ?? 0).toDouble(),
      nitrite: (data['nitrite'] ?? 0).toDouble(),
    );
  }
}
