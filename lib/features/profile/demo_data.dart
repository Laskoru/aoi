import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../models/fish_group.dart';
import '../../models/koi.dart';
import '../../models/plant.dart';
import '../../models/pond.dart';
import '../../models/water_measurement.dart';
import '../../services/fish_group_service.dart';
import '../../services/koi_service.dart';
import '../../services/plant_service.dart';
import '../../services/pond_service.dart';

/// Données de démonstration, pour les captures d'écran de la fiche Play.
///
/// Réservées au mode développement : l'écran Profil ne propose ces boutons
/// qu'en debug. Chaque document créé porte `demo: true`, ce qui permet de les
/// retirer sans toucher aux vraies fiches du compte.
///
/// Les photos viennent d'Unsplash (licence libre, usage commercial compris,
/// sans attribution obligatoire). Le CDN d'Unsplash les recadre sur le sujet
/// avant l'envoi ; elles passent ensuite par les mêmes services que les
/// photos prises dans l'appli. Auteurs : Ricky LK (Hana), Isaiah Kline (Taro),
/// shawn kim (Kin), Nellie Adamyan (Sora), You Le (Kumo), André Filipe
/// (Sakura), Vladislav Anchuk (Mizu), Isha Ralhan (bassin), Yoksel Zok (iris),
/// Nancy Hughes (nénuphar), Lutgarde De Brouwer (jonc fleuri), Trac Vu
/// (pontédérie), American Jael (poissons rouges), Cooper White (esturgeons).
class DemoData {
  const DemoData._();

  static const _flag = 'demo';

  /// Adresse de la photo que [seed] a posée sur le bassin. [clear] ne la
  /// retire que si le bassin l'affiche encore : une photo choisie depuis
  /// reste en place.
  static const _pondPhotoField = 'demoPhotoUrl';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String _unsplash(String photo, String rect, {int width = 1080}) =>
      'https://images.unsplash.com/photo-$photo?rect=$rect&w=$width&q=80&fm=jpg';

  // Chaque photo montre bien la variété annoncée. Yuki, le tancho, reste sans
  // photo : aucune image libre ne montre un vrai tancho, et l'emblème sert
  // justement aux koï qui n'en ont pas.
  static final _koiPhotos = {
    'Hana': _unsplash('1677607218448-bdfd0cf38440', '967,0,3456,3456'),
    'Taro': _unsplash('1722823566101-5d31a550a0c4', '0,747,3648,3648'),
    'Kin': _unsplash('1783273552643-da35cce900ce', '840,196,1909,1909'),
    'Sora': _unsplash('1762036914755-e3af3b8dd9ab', '2403,4433,2901,2901'),
    'Kumo': _unsplash('1768475162923-7c758c0b3c6a', '439,700,2600,2600'),
    'Sakura': _unsplash('1784039798906-e00bd48d9f73', '343,506,1700,1700'),
    'Mizu': _unsplash('1783240129646-80a0c51ee7ae', '1312,0,3376,3376'),
  };

  static final _plantPhotos = {
    'Iris des marais':
        _unsplash('1564293117922-c1752be147aa', '0,349,2008,2008', width: 800),
    'Nénuphar rose':
        _unsplash('1662975636302-7eab89796829', '730,0,3321,3321', width: 800),
    'Jonc fleuri':
        _unsplash('1628533138720-f213adcc2861', '638,0,3648,3648', width: 800),
    'Pontédérie':
        _unsplash('1653147495778-4cbd7ddf14f9', '0,699,4016,4016', width: 800),
  };

  static final _groupPhotos = {
    'Poisson rouge':
        _unsplash('1711664223920-a1285deabf85', '433,0,2603,2603', width: 800),
    'Esturgeon sterlet':
        _unsplash('1763345181042-6f0b846c9679', '0,326,3088,3088', width: 800),
  };

  static final _pondPhoto =
      _unsplash('1696124506484-c47e5fbaead1', '0,289,3023,1643', width: 1600);

  /// Ajoute une collection crédible : huit koï avec leur croissance, une
  /// filiation et leurs photos, cinq semaines de relevés d'eau, des plantes
  /// dans chaque zone, trois groupes d'autres poissons et, s'il n'en a pas
  /// encore, une photo du bassin. Les données d'un ajout précédent sont
  /// d'abord retirées : deux clics ne font pas de doublons.
  ///
  /// Renvoie le message à afficher.
  static Future<String> seed(String uid) async {
    await clear(uid);
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
      (kois.doc(), _koi(uid, 'Kumo', 'Shiro Bekko', 48, DateTime(2021, 5, 30), KoiSex.male,
          origin: 'Niigata, Japon', notes: 'Le plus discret : reste souvent près du fond.')),
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

    // Des espèces indigènes ou sans risque : l'élodée et la sagittaire
    // américaine, invasives en Europe, n'ont rien à faire dans un exemple.
    final plants = [
      for (final p in [
        _plant(uid, 'Iris des marais', 'Iris pseudacorus', PlantZone.berge, 3, DateTime(2023, 4, 15)),
        _plant(uid, 'Laîche pendante', 'Carex pendula', PlantZone.berge, 4, DateTime(2023, 4, 15)),
        _plant(uid, 'Sagittaire', 'Sagittaria sagittifolia', PlantZone.marecage, 2, DateTime(2024, 5, 2)),
        _plant(uid, 'Pontédérie', 'Pontederia cordata', PlantZone.marecage, 2, DateTime(2024, 5, 2)),
        _plant(uid, 'Jonc fleuri', 'Butomus umbellatus', PlantZone.immergee, 1, DateTime(2024, 5, 20)),
        _plant(uid, 'Nénuphar rose', "Nymphaea 'Rose Arey'", PlantZone.profonde, 2, DateTime(2022, 5, 10),
            notes: 'À diviser tous les trois ans, au printemps.'),
        _plant(uid, 'Cornifle', 'Ceratophyllum demersum', PlantZone.profonde, 5, DateTime(2023, 6, 1),
            oxygenating: true),
        _plant(uid, 'Morène', 'Hydrocharis morsus-ranae', PlantZone.profonde, 6, DateTime(2025, 5, 18),
            floating: true),
      ])
        (_db.collection('plants').doc(), p),
    ];
    final plantBatch = _db.batch();
    for (final (ref, plant) in plants) {
      plantBatch.set(ref, {
        ...plant.toMap(),
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        _flag: true,
      });
    }
    await plantBatch.commit();

    final groups = [
      for (final g in [
        FishGroup(id: '', userId: uid, species: 'Ide mélanote', count: 8,
            introducedAt: DateTime(2022, 5, 1), notes: 'Nagent en banc près de la surface.'),
        FishGroup(id: '', userId: uid, species: 'Esturgeon sterlet', count: 2,
            introducedAt: DateTime(2023, 5, 14),
            notes: 'Se nourrissent au fond : granulés coulants, le soir.'),
        FishGroup(id: '', userId: uid, species: 'Poisson rouge', count: 5,
            introducedAt: DateTime(2021, 6, 12)),
      ])
        (_db.collection('fish_groups').doc(), g),
    ];
    final groupBatch = _db.batch();
    for (final (ref, group) in groups) {
      groupBatch.set(ref, {
        ...group.toMap(),
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        _flag: true,
      });
    }
    await groupBatch.commit();

    // Les photos en dernier, toutes à la fois : chaque fiche existe déjà, et
    // une photo qui échoue n'empêche pas les autres.
    final uploads = <Future<bool>>[
      for (final (ref, koi) in entries)
        if (_koiPhotos[koi.name] case final url?)
          _addPhoto(url, (bytes) => KoiService.addPhoto(Koi.fromMap(ref.id, koi.toMap()), bytes)),
      for (final (ref, plant) in plants)
        if (_plantPhotos[plant.name] case final url?)
          _addPhoto(url, (bytes) => PlantService.setPhoto(Plant.fromMap(ref.id, plant.toMap()), bytes)),
      for (final (ref, group) in groups)
        if (_groupPhotos[group.species] case final url?)
          _addPhoto(url, (bytes) => FishGroupService.setPhoto(FishGroup.fromMap(ref.id, group.toMap()), bytes)),
    ];

    // Le bassin : on ne complète que ce qui manque, sans écraser son nom ni
    // sa photo.
    final pondRef = _db.collection('ponds').doc(Pond.defaultIdFor(uid));
    final pondSnap = await pondRef.get();
    if (pondSnap.exists) {
      final data = pondSnap.data() ?? const <String, dynamic>{};
      final missing = {
        if (data['volumeLiters'] == null) 'volumeLiters': 12000,
        if (data['depthCm'] == null) 'depthCm': 150,
      };
      if (missing.isNotEmpty) await pondRef.update(missing);
      if (data['imageUrl'] == null) {
        uploads.add(_addPhoto(_pondPhoto, (bytes) async {
          await PondService.setPhoto(Pond.fromMap(pondRef.id, data), bytes);
          final url = (await pondRef.get()).data()?['imageUrl'];
          await pondRef.update({_pondPhotoField: url});
        }));
      }
    }

    final failed = (await Future.wait(uploads)).where((ok) => !ok).length;
    return failed == 0
        ? "Données de démonstration ajoutées, photos comprises."
        : "Données ajoutées, mais $failed photo(s) n'ont pas pu être "
            "téléchargées. Vérifiez la connexion puis recommencez.";
  }

  /// Retire tout ce que [seed] a ajouté, et rien d'autre. Renvoie le message
  /// à afficher.
  static Future<String> clear(String uid) async {
    Query<Map<String, dynamic>> demo(String collection) => _db
        .collection(collection)
        .where('userId', isEqualTo: uid)
        .where(_flag, isEqualTo: true);

    // Par les services : ils effacent aussi les photos et les sous-collections.
    await Future.wait([
      for (final doc in (await demo('kois').get()).docs)
        KoiService.delete(Koi.fromFirestore(doc)),
      for (final doc in (await demo('plants').get()).docs)
        PlantService.delete(Plant.fromFirestore(doc)),
      for (final doc in (await demo('fish_groups').get()).docs)
        FishGroupService.delete(FishGroup.fromFirestore(doc)),
    ]);

    final batch = _db.batch();
    for (final doc in (await demo('measurements').get()).docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    final pondRef = _db.collection('ponds').doc(Pond.defaultIdFor(uid));
    final pond = await pondRef.get();
    final demoUrl = pond.data()?[_pondPhotoField];
    if (demoUrl != null) {
      if (pond.data()?['imageUrl'] == demoUrl) {
        await PondService.removePhoto(Pond.fromFirestore(pond));
      }
      await pondRef.update({_pondPhotoField: FieldValue.delete()});
    }
    return "Données de démonstration retirées.";
  }

  /// Télécharge une photo puis la confie à [upload]. Une photo manquante ne
  /// bloque pas le reste : elle est seulement comptée.
  static Future<bool> _addPhoto(
    String url,
    Future<void> Function(Uint8List bytes) upload,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', Uri.parse(url));
      }
      await upload(response.bodyBytes);
      return true;
    } catch (e) {
      debugPrint('[AOI] Photo de démonstration non ajoutée ($url) : $e');
      return false;
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
