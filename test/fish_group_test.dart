import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/models/fish_group.dart';

void main() {
  group('FishGroup', () {
    test('sérialise et relit ses champs', () {
      const group = FishGroup(
        id: 'g1',
        userId: 'u',
        species: 'Ide mélanote',
        count: 12,
        notes: 'Introduits avec les koï.',
      );

      final map = group.toMap();
      expect(map['species'], 'Ide mélanote');
      expect(map['count'], 12);
      expect(map['introducedAt'], isNull);

      final back = FishGroup.fromMap('g1', map);
      expect(back.species, 'Ide mélanote');
      expect(back.count, 12);
      expect(back.notes, 'Introduits avec les koï.');
    });

    test('tolère un document minimal', () {
      final group = FishGroup.fromMap('g2', const {'userId': 'u'});
      expect(group.species, 'Espèce inconnue');
      expect(group.count, 0);
      expect(group.introducedAt, isNull);
    });
  });
}
