import 'package:cloud_firestore/cloud_firestore.dart';

/// Sexe du koï. Souvent indéterminable avant trois ou quatre ans, d'où
/// [KoiSex.unknown] par défaut.
enum KoiSex {
  unknown('unknown'),
  male('male'),
  female('female');

  const KoiSex(this.code);

  final String code;

  static KoiSex fromCode(Object? code) {
    return KoiSex.values.firstWhere(
      (s) => s.code == code,
      orElse: () => KoiSex.unknown,
    );
  }
}

/// Devenir du poisson. Un koï vendu ou décédé reste dans la base : il peut
/// figurer dans la généalogie de ses descendants.
enum KoiStatus {
  alive('alive'),
  deceased('deceased'),
  sold('sold'),
  given('given');

  const KoiStatus(this.code);

  final String code;

  static KoiStatus fromCode(Object? code) {
    return KoiStatus.values.firstWhere(
      (s) => s.code == code,
      orElse: () => KoiStatus.alive,
    );
  }
}

/// Une carpe koï du bassin.
///
/// Le champ historique `age` (un entier saisi une fois puis jamais remis à
/// jour) est remplacé par [birthDate], à partir de laquelle l'âge se recalcule
/// tout seul. Les documents créés avant ce changement sont toujours lisibles :
/// leur `age` est conservé dans [legacyAge] et sert de repli d'affichage.
class Koi {
  final String id;
  final String userId;
  final String name;
  final String variety;
  final double size;
  final DateTime? birthDate;
  final int? legacyAge;
  final KoiSex sex;
  final KoiStatus status;
  final String? breeder;
  final String? origin;
  final String? notes;
  final String? imageUrl;

  /// Bassin d'appartenance. `null` désigne le bassin par défaut : les fiches
  /// créées avant l'arrivée des bassins n'ont pas eu à être réécrites.
  final String? pondId;
  final String? fatherId;
  final String? fatherNameManual;
  final String? motherId;
  final String? motherNameManual;
  final DateTime? createdAt;

  const Koi({
    required this.id,
    required this.userId,
    required this.name,
    required this.variety,
    required this.size,
    this.birthDate,
    this.legacyAge,
    this.sex = KoiSex.unknown,
    this.status = KoiStatus.alive,
    this.breeder,
    this.origin,
    this.notes,
    this.imageUrl,
    this.pondId,
    this.fatherId,
    this.fatherNameManual,
    this.motherId,
    this.motherNameManual,
    this.createdAt,
  });

  // --- Âge ---

  /// Vrai si l'âge est calculé depuis une date de naissance réelle, et non
  /// déduit de l'ancien champ `age`.
  bool get hasBirthDate => birthDate != null;

  /// Nombre de mois complets depuis la naissance, `null` si la date est
  /// inconnue.
  int? ageInMonths({DateTime? now}) {
    final birth = birthDate;
    if (birth == null) return null;

    final today = now ?? DateTime.now();
    if (today.isBefore(birth)) return 0;

    int months = (today.year - birth.year) * 12 + (today.month - birth.month);
    if (today.day < birth.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  /// Âge en années révolues, `null` si la date de naissance est inconnue.
  int? ageInYears({DateTime? now}) {
    final months = ageInMonths(now: now);
    return months == null ? null : months ~/ 12;
  }

  /// Rang de la classe d'âge japonaise, compté en années civiles : 0 pour un
  /// koï né cette année (tosai), 1 l'an prochain (nisai), et ainsi de suite.
  /// `null` si la date de naissance est inconnue. Le texte de l'âge et de la
  /// classe vient de `KoiAgeLabel`, dans la langue de l'interface.
  int? yearClassIndex({DateTime? now}) {
    final birth = birthDate;
    if (birth == null) return null;
    final index = (now ?? DateTime.now()).year - birth.year;
    return index < 0 ? null : index;
  }

  /// Les classes d'âge japonaises, de la première à la dixième année : le
  /// même mot dans toutes les langues.
  static const yearClassNames = [
    'Tosai',
    'Nisai',
    'Sansai',
    'Yonsai',
    'Gosai',
    'Rokusai',
    'Nanasai',
    'Hassai',
    'Kyusai',
    'Jussai',
  ];

  // --- Généalogie ---

  bool get hasFather => fatherId != null || _isFilled(fatherNameManual);
  bool get hasMother => motherId != null || _isFilled(motherNameManual);

  static bool _isFilled(String? value) => value != null && value.trim().isNotEmpty;

  // --- Sérialisation ---

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'variety': variety,
    'size': size,
    'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate!),
    'sex': sex.code,
    'status': status.code,
    'breeder': breeder,
    'origin': origin,
    'notes': notes,
    'imageUrl': imageUrl,
    'pondId': pondId,
    'fatherId': fatherId,
    'fatherNameManual': fatherNameManual,
    'motherId': motherId,
    'motherNameManual': motherNameManual,
  };

  factory Koi.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return Koi.fromMap(doc.id, data);
  }

  factory Koi.fromMap(String id, Map<String, dynamic> data) {
    return Koi(
      id: id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Inconnu',
      variety: data['variety'] as String? ?? '',
      size: (data['size'] as num? ?? 0).toDouble(),
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      legacyAge: (data['age'] as num?)?.toInt(),
      sex: KoiSex.fromCode(data['sex']),
      status: KoiStatus.fromCode(data['status']),
      breeder: data['breeder'] as String?,
      origin: data['origin'] as String?,
      notes: data['notes'] as String?,
      imageUrl: data['imageUrl'] as String?,
      pondId: data['pondId'] as String?,
      fatherId: data['fatherId'] as String?,
      fatherNameManual: data['fatherNameManual'] as String?,
      motherId: data['motherId'] as String?,
      motherNameManual: data['motherNameManual'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Une photo de la galerie d'un koï, stockée dans sa sous-collection `photos`.
///
/// Le motif d'un koï évolue d'une année sur l'autre : garder la suite des
/// clichés vaut mieux qu'écraser la seule photo à chaque envoi.
class KoiPhoto {
  final String id;

  /// Référence `photo:{id}` vers le document Firestore qui porte l'image, ou
  /// adresse Cloud Storage d'une photo plus ancienne.
  final String url;
  final DateTime? takenAt;

  const KoiPhoto({
    required this.id,
    required this.url,
    this.takenAt,
  });

  factory KoiPhoto.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return KoiPhoto(
      id: doc.id,
      url: data['url'] as String? ?? '',
      takenAt: (data['takenAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Un relevé de taille, stocké dans la sous-collection `growth` du koï.
class GrowthEntry {
  final String id;
  final double size;
  final DateTime? measuredAt;

  const GrowthEntry({required this.id, required this.size, this.measuredAt});

  factory GrowthEntry.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? const {};
    return GrowthEntry(
      id: doc.id,
      size: (data['size'] as num? ?? 0).toDouble(),
      measuredAt: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
