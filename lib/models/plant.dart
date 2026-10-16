import 'package:cloud_firestore/cloud_firestore.dart';

/// Zone de plantation, par profondeur d'immersion du pot.
///
/// C'est la convention des jardineries aquatiques françaises : une plante
/// se choisit d'abord pour la profondeur qu'elle tolère. La hauteur d'eau
/// est celle au-dessus du collet, pas celle du bassin.
enum PlantZone {
  berge('berge', 0),
  marecage('marecage', 20),
  immergee('immergee', 40),
  profonde('profonde', 100);

  const PlantZone(this.code, this.maxDepthCm);

  final String code;

  /// Profondeur d'eau maximale de la zone, en centimètres.
  final int maxDepthCm;

  static PlantZone fromCode(Object? code) {
    return PlantZone.values.firstWhere(
      (z) => z.code == code,
      orElse: () => PlantZone.marecage,
    );
  }
}

/// Une plante aquatique du bassin, comptée par pot ou par pied.
class Plant {
  final String id;
  final String userId;
  final String? pondId;
  final String name;
  final String? species;
  final PlantZone zone;

  /// Flottante : pas enracinée, elle ombrage l'eau et abrite les alevins.
  final bool isFloating;

  /// Oxygénante : immergée, elle consomme les nitrates et produit l'oxygène.
  final bool isOxygenating;
  final int quantity;
  final DateTime? plantedAt;
  final String? imageUrl;
  final String? notes;
  final DateTime? createdAt;

  const Plant({
    required this.id,
    required this.userId,
    required this.name,
    required this.zone,
    this.pondId,
    this.species,
    this.isFloating = false,
    this.isOxygenating = false,
    this.quantity = 1,
    this.plantedAt,
    this.imageUrl,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'pondId': pondId,
    'name': name,
    'species': species,
    'zone': zone.code,
    'isFloating': isFloating,
    'isOxygenating': isOxygenating,
    'quantity': quantity,
    'plantedAt': plantedAt == null ? null : Timestamp.fromDate(plantedAt!),
    'imageUrl': imageUrl,
    'notes': notes,
  };

  factory Plant.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return Plant.fromMap(doc.id, data);
  }

  factory Plant.fromMap(String id, Map<String, dynamic> data) {
    return Plant(
      id: id,
      userId: data['userId'] as String? ?? '',
      pondId: data['pondId'] as String?,
      name: data['name'] as String? ?? 'Plante',
      species: data['species'] as String?,
      zone: PlantZone.fromCode(data['zone']),
      isFloating: data['isFloating'] as bool? ?? false,
      isOxygenating: data['isOxygenating'] as bool? ?? false,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      plantedAt: (data['plantedAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
