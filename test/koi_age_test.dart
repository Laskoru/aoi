import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/models/koi.dart';

/// Construit un koï minimal : seuls les champs liés à l'âge nous intéressent ici.
Koi koiWith({DateTime? birthDate, int? legacyAge}) {
  return Koi(
    id: 'test',
    userId: 'user',
    name: 'Hanako',
    variety: 'Kohaku',
    size: 42,
    birthDate: birthDate,
    legacyAge: legacyAge,
  );
}

void main() {
  group('Âge calculé depuis la date de naissance', () {
    test('compte les mois complets, pas les mois entamés', () {
      final koi = koiWith(birthDate: DateTime(2020, 5, 10));

      // La veille de l'anniversaire, le mois n'est pas encore acquis.
      expect(koi.ageInMonths(now: DateTime(2024, 5, 9)), 47);
      expect(koi.ageInMonths(now: DateTime(2024, 5, 10)), 48);
    });

    test('exprime l\'âge en années et mois', () {
      final koi = koiWith(birthDate: DateTime(2020, 5, 10));

      expect(koi.ageLabel(now: DateTime(2024, 5, 10)), '4 ans');
      expect(koi.ageLabel(now: DateTime(2024, 7, 10)), '4 ans et 2 mois');
      expect(koi.ageLabel(now: DateTime(2021, 6, 10)), '1 an et 1 mois');
    });

    test('sous un an, ne parle qu\'en mois', () {
      final koi = koiWith(birthDate: DateTime(2024, 1, 15));

      expect(koi.ageLabel(now: DateTime(2024, 1, 20)), 'Moins d\'un mois');
      expect(koi.ageLabel(now: DateTime(2024, 2, 15)), '1 mois');
      expect(koi.ageLabel(now: DateTime(2024, 9, 15)), '8 mois');
    });

    test('une date future ne produit pas d\'âge négatif', () {
      final koi = koiWith(birthDate: DateTime(2030, 1, 1));

      expect(koi.ageInMonths(now: DateTime(2024, 1, 1)), 0);
    });

    test('ageInYears suit les années révolues', () {
      final koi = koiWith(birthDate: DateTime(2018, 3, 1));

      expect(koi.ageInYears(now: DateTime(2024, 2, 28)), 5);
      expect(koi.ageInYears(now: DateTime(2024, 3, 1)), 6);
    });
  });

  group('Repli sur les fiches créées avant la date de naissance', () {
    test('affiche l\'ancien âge comme une approximation', () {
      expect(koiWith(legacyAge: 4).ageLabel(), '~4 ans');
      expect(koiWith(legacyAge: 1).ageLabel(), '~1 an');
    });

    test('sans aucune information, le dit franchement', () {
      expect(koiWith().ageLabel(), 'Âge inconnu');
      expect(koiWith().ageInMonths(), isNull);
    });

    test('la date de naissance prime sur l\'ancien champ', () {
      final koi = koiWith(birthDate: DateTime(2022, 1, 1), legacyAge: 99);

      expect(koi.hasBirthDate, isTrue);
      expect(koi.ageLabel(now: DateTime(2024, 1, 1)), '2 ans');
    });
  });

  group('Classe d\'âge japonaise', () {
    test('se compte en années civiles', () {
      final koi = koiWith(birthDate: DateTime(2024, 8, 1));

      expect(koi.yearClass(now: DateTime(2024, 12, 31)), 'Tosai');
      expect(koi.yearClass(now: DateTime(2025, 1, 1)), 'Nisai');
      expect(koi.yearClass(now: DateTime(2026, 6, 1)), 'Sansai');
    });

    test('n\'existe pas sans date de naissance', () {
      expect(koiWith(legacyAge: 3).yearClass(), isNull);
    });
  });

  group('Généalogie', () {
    test('un parent lié ou saisi à la main compte comme renseigné', () {
      const linked = Koi(
        id: 'a',
        userId: 'u',
        name: 'x',
        variety: 'y',
        size: 1,
        fatherId: 'parent-123',
      );
      const manual = Koi(
        id: 'b',
        userId: 'u',
        name: 'x',
        variety: 'y',
        size: 1,
        motherNameManual: 'Femelle sauvage',
      );

      expect(linked.hasFather, isTrue);
      expect(linked.hasMother, isFalse);
      expect(manual.hasMother, isTrue);
    });

    test('un nom vide ou en espaces ne compte pas', () {
      const blank = Koi(
        id: 'c',
        userId: 'u',
        name: 'x',
        variety: 'y',
        size: 1,
        fatherNameManual: '   ',
      );

      expect(blank.hasFather, isFalse);
    });
  });
}
