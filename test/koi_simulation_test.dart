import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:aoi/features/pond/scene/koi_simulation.dart';
import 'package:aoi/models/koi.dart';

Koi koi(String id, {double size = 40, KoiStatus status = KoiStatus.alive}) {
  return Koi(
    id: id,
    userId: 'u',
    name: 'Koi $id',
    variety: 'Kohaku',
    size: size,
    status: status,
  );
}

void main() {
  const bounds = Size(400, 600);

  group('KoiSimulation.setKois', () {
    test('ne simule que les koï vivants, dans la limite du plafond', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(1));
      final kois = [
        for (int i = 0; i < 30; i++) koi('k$i'),
        koi('dead', status: KoiStatus.deceased),
        koi('sold', status: KoiStatus.sold),
      ];
      sim.setKois(kois);

      expect(sim.agents.length, KoiSimulation.maxAgents);
      expect(sim.hiddenCount, 30 - KoiSimulation.maxAgents);
      expect(sim.agents.any((a) => a.koi.id == 'dead'), isFalse);
    });

    test('un koï déjà présent garde sa position quand la liste est rafraîchie', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(1));
      sim.setKois([koi('a'), koi('b')]);
      sim.step(1 / 60);
      final before = sim.agents.firstWhere((a) => a.koi.id == 'a').position;

      sim.setKois([koi('a'), koi('b'), koi('c')]);
      final after = sim.agents.firstWhere((a) => a.koi.id == 'a').position;

      expect(after, before);
      expect(sim.agents.length, 3);
    });

    test('la position initiale est stable pour un même identifiant', () {
      final s1 = KoiSimulation(bounds: bounds)..setKois([koi('same')]);
      final s2 = KoiSimulation(bounds: bounds)..setKois([koi('same')]);
      expect(s1.agents.single.position, s2.agents.single.position);
    });
  });

  group('Taille et vitesse', () {
    test('la longueur suit la taille réelle, bornée', () {
      expect(KoiSimulation.lengthFor(koi('x', size: 10)), 40);
      expect(KoiSimulation.lengthFor(koi('x', size: 50)), 80);
      expect(KoiSimulation.lengthFor(koi('x', size: 120)), 140);
    });

    test('les grands nagent plus lentement', () {
      expect(
        KoiSimulation.speedFor(140),
        lessThan(KoiSimulation.speedFor(40)),
      );
    });
  });

  group('KoiSimulation.step', () {
    test('les koï restent dans le cadre, longtemps', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(7));
      sim.setKois([for (int i = 0; i < 12; i++) koi('k$i', size: 20.0 + i * 8)]);

      for (int i = 0; i < 60 * 60; i++) {
        sim.step(1 / 60);
      }

      for (final a in sim.agents) {
        expect(a.position.dx, inInclusiveRange(0, bounds.width));
        expect(a.position.dy, inInclusiveRange(0, bounds.height));
      }
    });

    test('un pas de temps énorme est borné : pas de saut après une pause', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(3));
      sim.setKois([koi('a')]);
      final before = sim.agents.single.position;

      sim.step(5.0); // cinq secondes d'un coup

      final moved = (sim.agents.single.position - before).distance;
      expect(moved, lessThan(KoiSimulation.speedFor(64) * KoiSimulation.maxStep + 0.01));
    });

    test('les koï finissent par se mouvoir', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(5));
      sim.setKois([koi('a')]);
      final before = sim.agents.single.position;
      for (int i = 0; i < 120; i++) {
        sim.step(1 / 60);
      }
      expect((sim.agents.single.position - before).distance, greaterThan(5));
    });
  });

  group('KoiSimulation.hitTest', () {
    test('trouve le koï sous le doigt, et rien à côté', () {
      final sim = KoiSimulation(bounds: bounds, random: Random(1));
      sim.setKois([koi('a')]);
      final agent = sim.agents.single;

      expect(sim.hitTest(agent.position)?.koi.id, 'a');
      expect(sim.hitTest(agent.position + const Offset(300, 300)), isNull);
    });
  });
}
