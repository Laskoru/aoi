import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/models/water_measurement.dart';
import 'package:aoi/utils/water_logic.dart';

void main() {
  group('WaterMeasurement.toMap', () {
    test("n'écrit que les paramètres relevés", () {
      const quick = WaterMeasurement(
        id: '',
        userId: 'u',
        ph: 7.4,
        temperature: 18,
      );

      final map = quick.toMap();
      expect(map, containsPair('ph', 7.4));
      expect(map, containsPair('temperature', 18));
      expect(map.containsKey('ammonia'), isFalse);
      expect(map.containsKey('nitrite'), isFalse);
      expect(map.containsKey('kh'), isFalse);
    });

    test("écrit l'ammoniaque quand elle est saisie", () {
      const full = WaterMeasurement(
        id: '',
        userId: 'u',
        ph: 7.4,
        temperature: 18,
        ammonia: 0.05,
        nitrite: 0,
      );

      expect(full.toMap(), containsPair('ammonia', 0.05));
      expect(full.toMap(), containsPair('nitrite', 0));
    });
  });

  group('WaterMeasurement.readings', () {
    test('pH et température figurent toujours, les autres seulement si relevés', () {
      const m = WaterMeasurement(
        id: '',
        userId: 'u',
        ph: 7,
        temperature: 20,
        nitrate: 30,
      );

      final parameters = m.readings.map((r) => r.parameter).toList();
      expect(parameters, [
        WaterParameter.ph,
        WaterParameter.temperature,
        WaterParameter.nitrate,
      ]);
    });
  });

  group('WaterMeasurement.valueOf', () {
    test("rend la valeur du paramètre, ou null s'il manque", () {
      const m = WaterMeasurement(
        id: '',
        userId: 'u',
        ph: 7.2,
        temperature: 21,
        kh: 6,
      );

      expect(m.valueOf(WaterParameter.ph), 7.2);
      expect(m.valueOf(WaterParameter.kh), 6);
      expect(m.valueOf(WaterParameter.ammonia), isNull);
    });
  });
}
