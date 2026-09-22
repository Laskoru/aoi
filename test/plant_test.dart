import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/models/plant.dart';

void main() {
  group('PlantZone', () {
    test('se lit depuis son code, avec un repli sûr', () {
      expect(PlantZone.fromCode('profonde'), PlantZone.profonde);
      expect(PlantZone.fromCode('berge'), PlantZone.berge);
      expect(PlantZone.fromCode('inconnu'), PlantZone.marecage);
      expect(PlantZone.fromCode(null), PlantZone.marecage);
    });

    test('les zones vont de la berge vers le fond, par profondeur croissante', () {
      final depths = PlantZone.values.map((z) => z.maxDepthCm).toList();
      final sorted = [...depths]..sort();
      expect(depths, sorted);
      expect(PlantZone.berge.maxDepthCm, 0);
      expect(PlantZone.profonde.maxDepthCm, 100);
    });
  });

  group('Plant', () {
    test('sérialise et relit ses champs sans perte', () {
      final planted = DateTime(2024, 4, 12);
      final plant = Plant(
        id: 'p1',
        userId: 'u',
        name: 'Nénuphar rose',
        species: 'Nymphaea Attraction',
        zone: PlantZone.profonde,
        isFloating: false,
        isOxygenating: false,
        quantity: 2,
        plantedAt: planted,
        notes: 'Diviser tous les trois ans.',
      );

      final map = plant.toMap();
      expect(map['zone'], 'profonde');
      expect(map['quantity'], 2);
      expect(map.containsKey('userId'), isTrue);

      final back = Plant.fromMap('p1', {
        ...map,
        'plantedAt': null, // un Timestamp Firestore n'est pas construisible ici
      });
      expect(back.name, 'Nénuphar rose');
      expect(back.zone, PlantZone.profonde);
      expect(back.quantity, 2);
      expect(back.species, 'Nymphaea Attraction');
    });

    test('tolère un document minimal', () {
      final plant = Plant.fromMap('p2', const {'userId': 'u'});
      expect(plant.name, 'Plante');
      expect(plant.quantity, 1);
      expect(plant.zone, PlantZone.marecage);
      expect(plant.isFloating, isFalse);
    });
  });
}
