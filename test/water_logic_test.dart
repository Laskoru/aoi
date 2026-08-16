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
}
