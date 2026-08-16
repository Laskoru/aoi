import 'package:cloud_firestore/cloud_firestore.dart';

/// Sexe du koï. Souvent indéterminable avant trois ou quatre ans, d'où
/// [KoiSex.unknown] par défaut.
enum KoiSex {
  unknown('unknown', 'Indéterminé'),
  male('male', 'Mâle'),
  female('female', 'Femelle');

  const KoiSex(this.code, this.label);

  final String code;
  final String label;

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
  alive('alive', 'Vivant'),
  deceased('deceased', 'Décédé'),
  sold('sold', 'Vendu'),
  given('given', 'Donné');

  const KoiStatus(this.code, this.label);

  final String code;
  final String label;

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

  /// Âge lisible : « 3 ans et 2 mois », « 8 mois », « ~4 ans » quand il vient
  /// de l'ancien champ, « Âge inconnu » sinon.
  String ageLabel({DateTime? now}) {
    final months = ageInMonths(now: now);

    if (months == null) {
      if (legacyAge != null) {
        return legacyAge == 1 ? '~1 an' : '~$legacyAge ans';
      }
      return 'Âge inconnu';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (years == 0) {
      if (months == 0) return 'Moins d\'un mois';
      return months == 1 ? '1 mois' : '$months mois';
    }

    final yearPart = years == 1 ? '1 an' : '$years ans';
    if (remainingMonths == 0) return yearPart;
    final monthPart = remainingMonths == 1 ? '1 mois' : '$remainingMonths mois';
    return '$yearPart et $monthPart';
  }

  /// Classe d'âge japonaise, comptée en années civiles : un koï né en 2024 est
  /// tosai en 2024, nisai en 2025, et ainsi de suite.
  String? yearClass({DateTime? now}) {
    final birth = birthDate;
    if (birth == null) return null;

    const names = [
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

    final index = (now ?? DateTime.now()).year - birth.year;
    if (index < 0) return null;
    if (index >= names.length) return 'Plus de ${names.length} ans';
    return names[index];
  }

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
      fatherId: data['fatherId'] as String?,
      fatherNameManual: data['fatherNameManual'] as String?,
      motherId: data['motherId'] as String?,
      motherNameManual: data['motherNameManual'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
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
