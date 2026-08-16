import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/utils/water_logic.dart';

void main() {
  group('WaterLogic.checkPhLevel', () {
    test('la plage idéale du koï est 7.0 à 8.5 inclus', () {
      expect(WaterLogic.checkPhLevel(7.0), WaterCondition.ideal);
      expect(WaterLogic.checkPhLevel(7.6), WaterCondition.ideal);
      expect(WaterLogic.checkPhLevel(8.5), WaterCondition.ideal);
    });

    test('les abords immédiats sont en alerte, pas en danger', () {
      expect(WaterLogic.checkPhLevel(6.5), WaterCondition.warning);
      expect(WaterLogic.checkPhLevel(6.9), WaterCondition.warning);
      expect(WaterLogic.checkPhLevel(8.6), WaterCondition.warning);
      expect(WaterLogic.checkPhLevel(9.0), WaterCondition.warning);
    });

    test('au-delà, l\'eau est signalée dangereuse', () {
      expect(WaterLogic.checkPhLevel(6.4), WaterCondition.danger);
      expect(WaterLogic.checkPhLevel(9.1), WaterCondition.danger);
      expect(WaterLogic.checkPhLevel(0), WaterCondition.danger);
      expect(WaterLogic.checkPhLevel(14), WaterCondition.danger);
    });
  });

  group('WaterLogic.checkTemperature', () {
    test('la plage de métabolisme idéale est 15 à 25 °C', () {
      expect(WaterLogic.checkTemperature(15), WaterCondition.ideal);
      expect(WaterLogic.checkTemperature(20), WaterCondition.ideal);
      expect(WaterLogic.checkTemperature(25), WaterCondition.ideal);
    });

    test('le froid modéré et la chaleur modérée sont en alerte', () {
      expect(WaterLogic.checkTemperature(10), WaterCondition.warning);
      expect(WaterLogic.checkTemperature(14.9), WaterCondition.warning);
      expect(WaterLogic.checkTemperature(26), WaterCondition.warning);
      expect(WaterLogic.checkTemperature(28), WaterCondition.warning);
    });

    test('gel et surchauffe sont dangereux', () {
      expect(WaterLogic.checkTemperature(9.9), WaterCondition.danger);
      expect(WaterLogic.checkTemperature(2), WaterCondition.danger);
      expect(WaterLogic.checkTemperature(28.1), WaterCondition.danger);
      expect(WaterLogic.checkTemperature(35), WaterCondition.danger);
    });
  });

  group('Toxiques du cycle de l\'azote', () {
    test('la seule ammoniaque confortable est proche de zéro', () {
      expect(WaterLogic.checkAmmonia(0), WaterCondition.ideal);
      expect(WaterLogic.checkAmmonia(0.02), WaterCondition.ideal);
      expect(WaterLogic.checkAmmonia(0.1), WaterCondition.warning);
      expect(WaterLogic.checkAmmonia(0.25), WaterCondition.warning);
      expect(WaterLogic.checkAmmonia(0.26), WaterCondition.danger);
      expect(WaterLogic.checkAmmonia(2), WaterCondition.danger);
    });

    test('les nitrites deviennent dangereux très vite', () {
      expect(WaterLogic.checkNitrite(0), WaterCondition.ideal);
      expect(WaterLogic.checkNitrite(0.1), WaterCondition.ideal);
      expect(WaterLogic.checkNitrite(0.2), WaterCondition.warning);
      expect(WaterLogic.checkNitrite(0.25), WaterCondition.warning);
      expect(WaterLogic.checkNitrite(0.3), WaterCondition.danger);
      expect(WaterLogic.checkNitrite(5), WaterCondition.danger);
    });

    test('les nitrates sont tolérés bien plus haut', () {
      expect(WaterLogic.checkNitrate(0), WaterCondition.ideal);
      expect(WaterLogic.checkNitrate(40), WaterCondition.ideal);
      expect(WaterLogic.checkNitrate(60), WaterCondition.warning);
      expect(WaterLogic.checkNitrate(80), WaterCondition.warning);
      expect(WaterLogic.checkNitrate(120), WaterCondition.danger);
    });

    test('un nitrate élevé est moins grave qu\'un nitrite élevé', () {
      // Garde-fou contre une inversion des seuils : à valeur égale, le
      // nitrite doit toujours alerter au moins autant que le nitrate.
      expect(WaterLogic.checkNitrate(1), WaterCondition.ideal);
      expect(WaterLogic.checkNitrite(1), WaterCondition.danger);
    });
  });

  group('Duretés', () {
    test('un KH trop bas est dangereux : le pH peut s\'effondrer', () {
      expect(WaterLogic.checkKh(2), WaterCondition.danger);
      expect(WaterLogic.checkKh(3), WaterCondition.warning);
      expect(WaterLogic.checkKh(5), WaterCondition.ideal);
      expect(WaterLogic.checkKh(15), WaterCondition.ideal);
      expect(WaterLogic.checkKh(18), WaterCondition.warning);
      expect(WaterLogic.checkKh(25), WaterCondition.danger);
    });

    test('le GH suit une plage large', () {
      expect(WaterLogic.checkGh(3), WaterCondition.danger);
      expect(WaterLogic.checkGh(6), WaterCondition.warning);
      expect(WaterLogic.checkGh(12), WaterCondition.ideal);
      expect(WaterLogic.checkGh(25), WaterCondition.warning);
      expect(WaterLogic.checkGh(35), WaterCondition.danger);
    });
  });

  group('Lecture d\'un relevé', () {
    test('chaque paramètre route vers son propre seuil', () {
      expect(
        const WaterReading(WaterParameter.nitrite, 1).condition,
        WaterCondition.danger,
      );
      expect(
        const WaterReading(WaterParameter.nitrate, 1).condition,
        WaterCondition.ideal,
      );
      expect(
        const WaterReading(WaterParameter.ph, 7.5).condition,
        WaterCondition.ideal,
      );
    });

    test('les toxiques se lisent au centième, les nitrates à l\'unité', () {
      expect(
        const WaterReading(WaterParameter.nitrite, 0.25).formattedValue,
        '0.25',
      );
      expect(
        const WaterReading(WaterParameter.nitrate, 42.7).formattedValue,
        '43',
      );
      expect(
        const WaterReading(WaterParameter.temperature, 18).formattedValue,
        '18.0',
      );
    });
  });
}
