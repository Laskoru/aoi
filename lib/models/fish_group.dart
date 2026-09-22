import 'package:cloud_firestore/cloud_firestore.dart';

/// Un groupe de poissons d'une même espèce, autres que les koï.
///
/// Un banc de vingt ides ne se suit pas poisson par poisson : on note
/// l'espèce, l'effectif et la date d'introduction. Les koï, eux, gardent
/// leur fiche individuelle.
class FishGroup {
  final String id;
  final String userId;
  final String? pondId;
  final String species;
  final int count;
  final DateTime? introducedAt;
  final String? imageUrl;
  final String? notes;
  final DateTime? createdAt;

  const FishGroup({
    required this.id,
    required this.userId,
    required this.species,
    required this.count,
    this.pondId,
    this.introducedAt,
    this.imageUrl,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'pondId': pondId,
    'species': species,
    'count': count,
    'introducedAt': introducedAt == null
        ? null
        : Timestamp.fromDate(introducedAt!),
    'imageUrl': imageUrl,
    'notes': notes,
  };

  factory FishGroup.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return FishGroup.fromMap(doc.id, data);
  }

  factory FishGroup.fromMap(String id, Map<String, dynamic> data) {
    return FishGroup(
      id: id,
      userId: data['userId'] as String? ?? '',
      pondId: data['pondId'] as String?,
      species: data['species'] as String? ?? 'Espèce inconnue',
      count: (data['count'] as num?)?.toInt() ?? 0,
      introducedAt: (data['introducedAt'] as Timestamp?)?.toDate(),
      imageUrl: data['imageUrl'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
