import 'package:aoi/theme/app_widgets.dart';
import 'package:aoi/theme/koi_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le tracé du koï tient dans le carré unité', () {
    for (final outline in [
      KoiMarkShape.body,
      KoiMarkShape.tail,
      KoiMarkShape.leftFin,
      KoiMarkShape.rightFin,
    ]) {
      for (final point in outline) {
        expect(point.dx, inInclusiveRange(0, 1));
        expect(point.dy, inInclusiveRange(0, 1));
      }
    }
  });

  testWidgets("l'emblème se dessine, opaque comme translucide", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            const KoiEmblem(size: 24),
            KoiEmblem(size: 46, color: Colors.teal.withValues(alpha: 0.35)),
          ],
        ),
      ),
    );

    expect(find.byType(KoiEmblem), findsNWidgets(2));
    expect(tester.getSize(find.byType(KoiEmblem).first), const Size.square(24));
    expect(tester.takeException(), isNull);
  });
}
