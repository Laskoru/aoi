import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fish_group.dart';
import '../models/koi.dart';
import '../models/plant.dart';
import '../models/pond.dart';
import 'fish_group_service.dart';
import 'koi_service.dart';
import 'photo_store.dart';
import 'plant_service.dart';
import 'pond_service.dart';

/// Suppression complète d'un compte.
///
/// Google Play l'exige de toute application qui crée des comptes, et elle est
/// due à l'utilisateur : ses données lui appartiennent.
class AccountService {
  const AccountService._();

  /// Efface toutes les données de l'utilisateur, fichiers compris.
  ///
  /// Chaque domaine passe par son propre service, qui sait quels fichiers et
  /// quelles sous-collections accompagnent ses documents : la galerie et
  /// l'historique de croissance d'un koï, la photo d'une plante ou du bassin.
  ///
  /// L'opération est reprenable : interrompue, elle se relance et repart de
  /// ce qui reste.
  static Future<void> deleteAllData(String userId) async {
    final db = FirebaseFirestore.instance;
    Query<Map<String, dynamic>> mine(String collection) =>
        db.collection(collection).where('userId', isEqualTo: userId);

    for (final doc in (await mine('kois').get()).docs) {
      await KoiService.delete(Koi.fromFirestore(doc));
    }
    for (final doc in (await mine('plants').get()).docs) {
      await PlantService.delete(Plant.fromFirestore(doc));
    }
    for (final doc in (await mine('fish_groups').get()).docs) {
      await FishGroupService.delete(FishGroup.fromFirestore(doc));
    }
    for (final doc in (await mine('ponds').get()).docs) {
      await PondService.delete(Pond.fromFirestore(doc));
    }

    // Les relevés n'ont ni fichier ni sous-collection : suppression par lots,
    // Firestore plafonnant un lot à 500 écritures.
    final measurements = (await mine('measurements').get()).docs;
    for (var start = 0; start < measurements.length; start += 400) {
      final batch = db.batch();
      for (final doc in measurements.skip(start).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    // Les fiches sont parties avec leurs photos ; restent d'éventuelles
    // orphelines, laissées par un envoi interrompu.
    await PhotoStore.deleteAllOf(userId);
  }
}
