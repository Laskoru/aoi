import 'package:cloud_firestore/cloud_firestore.dart';

/// Un bassin. L'application n'en gère qu'un pour l'instant, mais tout
/// document qui s'y rattache porte un `pondId` optionnel pour pouvoir en
/// accueillir d'autres sans réécrire les données existantes.
///
/// Le bassin par défaut d'un utilisateur a l'identifiant déterministe
/// `default_{uid}` : on peut le créer à l'aveugle avec `merge` sans risquer
/// de doublon entre deux appareils.
class Pond {
  final String id;
  final String userId;
  final String name;
  final double? volumeLiters;
  final double? depthCm;
  final String? imageUrl;
  final String? notes;
  final DateTime? createdAt;

  const Pond({
    required this.id,
    required this.userId,
    required this.name,
    this.volumeLiters,
    this.depthCm,
    this.imageUrl,
    this.notes,
    this.createdAt,
  });

  static String defaultIdFor(String userId) => 'default_$userId';

  bool get isDefault => id == defaultIdFor(userId);

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'volumeLiters': volumeLiters,
    'depthCm': depthCm,
    'imageUrl': imageUrl,
    'notes': notes,
  };

  factory Pond.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return Pond.fromMap(doc.id, data);
  }

  /// Nom que les versions 2.0 enregistraient d'office, en français. Il
  /// s'affiche désormais dans la langue de l'interface, comme un bassin sans
  /// nom : voir `PondNameLabel`.
  static const legacyDefaultName = 'Mon bassin';

  factory Pond.fromMap(String id, Map<String, dynamic> data) {
    return Pond(
      id: id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      volumeLiters: (data['volumeLiters'] as num?)?.toDouble(),
      depthCm: (data['depthCm'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
