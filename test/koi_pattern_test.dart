import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/features/pond/scene/koi_pattern.dart';

void main() {
  group('KoiPattern.fromVariety', () {
    test('reconnaît les grandes variétés, quelle que soit la casse', () {
      expect(KoiPattern.fromVariety('Kohaku').kind, KoiPatternKind.patches);
      expect(KoiPattern.fromVariety('KOHAKU').kind, KoiPatternKind.patches);
      expect(KoiPattern.fromVariety('Taisho Sanke').kind, KoiPatternKind.patchesAndSpots);
      expect(KoiPattern.fromVariety('Showa Sanshoku').kind, KoiPatternKind.patchesAndSpots);
      expect(KoiPattern.fromVariety('Shiro Utsuri').kind, KoiPatternKind.bands);
      expect(KoiPattern.fromVariety('Bekko').kind, KoiPatternKind.spots);
      expect(KoiPattern.fromVariety('Asagi').kind, KoiPatternKind.reticulated);
      expect(KoiPattern.fromVariety('Chagoi').kind, KoiPatternKind.solid);
    });

    test('un showa a le fond noir, un sanke le fond blanc', () {
      expect(KoiPattern.fromVariety('Showa').base, KoiPattern.sumi);
      expect(KoiPattern.fromVariety('Sanke').base, KoiPattern.shiroji);
    });

    test('tancho prime sur la variété de base', () {
      // Un « Tancho Kohaku » se reconnaît à son disque rouge, pas à ses plaques.
      expect(KoiPattern.fromVariety('Tancho Kohaku').kind, KoiPatternKind.tancho);
      expect(KoiPattern.fromVariety('Tancho Showa').kind, KoiPatternKind.tancho);
    });

    test('les métalliques portent un reflet', () {
      expect(KoiPattern.fromVariety('Yamabuki Ogon').metallic, isTrue);
      expect(KoiPattern.fromVariety('Platinum').metallic, isTrue);
      expect(KoiPattern.fromVariety('Kohaku').metallic, isFalse);
    });

    test('une variété inconnue donne le koï orangé à ventre blanc', () {
      final p = KoiPattern.fromVariety('Mystère du bassin');
      expect(p.kind, KoiPatternKind.solid);
      expect(p.base, KoiPattern.hi);
      expect(p.secondary, KoiPattern.belly);
    });

    test('une variété vide ne plante pas', () {
      expect(KoiPattern.fromVariety('').kind, KoiPatternKind.solid);
    });
  });
}
