import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/fish_group.dart';
import '../../models/koi.dart';
import '../../models/plant.dart';
import '../../models/pond.dart';
import '../../models/water_measurement.dart';
import '../../services/koi_service.dart';

/// Données de démonstration, pour les captures d'écran de la fiche Play.
///
/// Réservées au mode développement : l'écran Profil ne propose ces boutons
/// qu'en debug. Chaque document créé porte `demo: true`, ce qui permet de les
/// retirer sans toucher aux vraies fiches du compte.
class DemoData {
  const DemoData._();

  static const _flag = 'demo';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Ajoute une collection crédible : huit koï avec leur croissance et une
  /// filiation, cinq semaines de relevés d'eau, des plantes dans chaque zone
  /// et deux groupes d'autres poissons.
  static Future<void> seed(String uid) async {
    final now = DateTime.now();
    final kois = _db.collection('kois');

    // Les parents d'abord : leurs identifiants servent à la filiation.
    final hana = kois.doc();
    final taro = kois.doc();
    final entries = <(DocumentReference<Map<String, dynamic>>, Koi)>[
      (hana, _koi(uid, 'Hana', 'Kohaku', 68, DateTime(2019, 6, 12), KoiSex.female,
          breeder: 'Sakai Fish Farm', origin: 'Hiroshima, Japon',
          notes: 'Shiroji très propre, bords du hi bien nets.')),
      (taro, _koi(uid, 'Taro', 'Showa Sanshoku', 72, DateTime(2018, 5, 20), KoiSex.male,
          breeder: 'Dainichi', origin: 'Niigata, Japon')),
      (kois.doc(), _koi(uid, 'Yuki', 'Tancho Kohaku', 45, DateTime(2021, 6, 1), KoiSex.female,
          breeder: 'Momotaro', origin: 'Okayama, Japon',
          notes: 'Le disque rouge est parfaitement centré.')),
      (kois.doc(), _koi(uid, 'Kin', 'Yamabuki Ogon', 55, DateTime(2020, 7, 15), KoiSex.male,
          origin: 'Élevage français', notes: 'Le plus familier : vient manger dans la main.')),
      (kois.doc(), _koi(uid, 'Sora', 'Asagi', 38, DateTime(2022, 6, 10), KoiSex.female)),
      (kois.doc(), _koi(uid, 'Kumo', 'Shiro Utsuri', 48, DateTime(2021, 5, 30), KoiSex.male,
          breeder: 'Omosako')),
      (kois.doc(), _koi(uid, 'Sakura', 'Taisho Sanke', 30, DateTime(2023, 6, 5), KoiSex.unknown)),
      (kois.doc(), _koi(uid, 'Mizu', 'Kohaku', 22, DateTime(2024, 6, 15), KoiSex.unknown,
          notes: 'Né au bassin, de Hana et Taro.',
          fatherId: taro.id, motherId: hana.id)),
    ];

    final koiBatch = _db.batch();
    for (var i = 0; i < entries.length; i++) {
      final (ref, koi) = entries[i];
      koiBatch.set(ref, {
        ...koi.toMap(),
        'createdAt': Timestamp.fromDate(now.subtract(Duration(days: 40 - i))),
        _flag: true,
      });
    }
    await koiBatch.commit();

    // La croissance ensuite : les règles vérifient que le koï parent existe,
    // il doit donc être créé avant ses relevés.
    final growthBatch = _db.batch();
    for (final (ref, koi) in entries) {
      const steps = [0.70, 0.77, 0.84, 0.90, 0.95, 1.0];
      for (var j = 0; j < steps.length; j++) {
        final date = now.subtract(Duration(days: 14 + (steps.length - 1 - j) * 120));
        growthBatch.set(ref.collection('growth').doc(), {
          'size': double.parse((koi.size * steps[j]).toStringAsFixed(1)),
          'timestamp': Timestamp.fromDate(date),
        });
      }
    }
    await growthBatch.commit();

    // Cinq semaines de relevés : une eau qui se rafraîchit avec l'automne,
    // une alerte aux nitrites passée, et un dernier relevé sain.
    final measurements = _db.batch();
    const temps = [21.5, 21.0, 20.2, 19.8, 19.0, 18.6, 18.1, 17.4, 17.0, 16.5];
    const phs = [7.6, 7.5, 7.7, 7.8, 7.6, 7.5, 7.4, 7.6, 7.7, 7.6];
    for (var i = 0; i < temps.length; i++) {
      final m = WaterMeasurement(
        id: '',
        userId: uid,
        ph: phs[i],
        temperature: temps[i],
        ammonia: i == 4 ? 0.05 : 0.0,
        nitrite: i == 4 ? 0.15 : 0.02,
        nitrate: 20.0 + i * 1.5,
        kh: 7.0,
        gh: 11.0,
      );
      measurements.set(_db.collection('measurements').doc(), {
        ...m.toMap(),
        'timestamp': Timestamp.fromDate(now.subtract(Duration(days: 35 - i * 3 - 8))),
        _flag: true,
      });
    }
    await measurements.commit();

    final plants = _db.batch();
    for (final p in [
      _plant(uid, 'Iris des marais', 'Iris pseudacorus', PlantZone.berge, 3, DateTime(2023, 4, 15)),
      _plant(uid, 'Laîche pendante', 'Carex pendula', PlantZone.berge, 4, DateTime(2023, 4, 15)),
      _plant(uid, 'Sagittaire', 'Sagittaria latifolia', PlantZone.marecage, 2, DateTime(2024, 5, 2)),
      _plant(uid, 'Pontédérie', 'Pontederia cordata', PlantZone.marecage, 2, DateTime(2024, 5, 2)),
      _plant(uid, 'Jonc fleuri', 'Butomus umbellatus', PlantZone.immergee, 1, DateTime(2024, 5, 20)),
      _plant(uid, 'Nénuphar rose', "Nymphaea 'Attraction'", PlantZone.profonde, 2, DateTime(2022, 5, 10),
          notes: 'À diviser tous les trois ans, au printemps.'),
      _plant(uid, 'Élodée', 'Elodea nuttallii', PlantZone.profonde, 5, DateTime(2023, 6, 1),
          oxygenating: true),
      _plant(uid, 'Morène', 'Hydrocharis morsus-ranae', PlantZone.profonde, 6, DateTime(2025, 5, 18),
          floating: true),
    ]) {
      plants.set(_db.collection('plants').doc(), {
        ...p.toMap(),
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        _flag: true,
      });
    }
    await plants.commit();

    final groups = _db.batch();
    for (final g in [
      FishGroup(id: '', userId: uid, species: 'Ide mélanote', count: 8,
          introducedAt: DateTime(2022, 5, 1), notes: 'Nagent en banc près de la surface.'),
      FishGroup(id: '', userId: uid, species: 'Poisson rouge', count: 5,
          introducedAt: DateTime(2021, 6, 12)),
    ]) {
      groups.set(_db.collection('fish_groups').doc(), {
        ...g.toMap(),
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        _flag: true,
      });
    }
    await groups.commit();

    // Le bassin : on ne complète que ce qui manque, sans écraser son nom.
    final pondRef = _db.collection('ponds').doc(Pond.defaultIdFor(uid));
    final pond = await pondRef.get();
    if (pond.exists) {
      final data = pond.data() ?? const {};
      await pondRef.update({
        if (data['volumeLiters'] == null) 'volumeLiters': 12000,
        if (data['depthCm'] == null) 'depthCm': 150,
      });
    }
  }

  /// Retire tout ce que [seed] a ajouté, et rien d'autre.
  static Future<void> clear(String uid) async {
    Query<Map<String, dynamic>> demo(String collection) => _db
        .collection(collection)
        .where('userId', isEqualTo: uid)
        .where(_flag, isEqualTo: true);

    for (final doc in (await demo('kois').get()).docs) {
      await KoiService.delete(Koi.fromFirestore(doc));
    }
    for (final collection in ['measurements', 'plants', 'fish_groups']) {
      final docs = (await demo(collection).get()).docs;
      final batch = _db.batch();
      for (final doc in docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  static Koi _koi(
    String uid,
    String name,
    String variety,
    double size,
    DateTime birth,
    KoiSex sex, {
    String? breeder,
    String? origin,
    String? notes,
    String? fatherId,
    String? motherId,
  }) {
    return Koi(
      id: '',
      userId: uid,
      name: name,
      variety: variety,
      size: size,
      birthDate: birth,
      sex: sex,
      breeder: breeder,
      origin: origin,
      notes: notes,
      fatherId: fatherId,
      motherId: motherId,
    );
  }

  static Plant _plant(
    String uid,
    String name,
    String species,
    PlantZone zone,
    int quantity,
    DateTime planted, {
    String? notes,
    bool floating = false,
    bool oxygenating = false,
  }) {
    return Plant(
      id: '',
      userId: uid,
      name: name,
      species: species,
      zone: zone,
      quantity: quantity,
      plantedAt: planted,
      notes: notes,
      isFloating: floating,
      isOxygenating: oxygenating,
    );
  }
}
