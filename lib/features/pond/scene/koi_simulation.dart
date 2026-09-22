import 'dart:math';
import 'dart:ui';
import '../../../models/koi.dart';

/// Un koï en mouvement dans la scène.
class KoiAgent {
  final Koi koi;

  /// Graine stable par koï : le motif de ses plaques ne change pas d'une
  /// image à l'autre, ni d'une ouverture de l'appli à l'autre.
  final int seed;

  /// Longueur à l'écran, en pixels, dérivée de la taille réelle.
  final double length;

  Offset position;

  /// Direction, en radians. 0 = vers la droite.
  double heading;
  double speed;

  /// Phase de l'ondulation du corps.
  double phase;

  /// Direction vers laquelle le koï dérive lentement : c'est elle qui donne
  /// l'errance, plutôt qu'un cap qui tremblerait à chaque image.
  double wanderTarget;

  KoiAgent({
    required this.koi,
    required this.seed,
    required this.length,
    required this.position,
    required this.heading,
    required this.speed,
    this.phase = 0,
  }) : wanderTarget = heading;

  Offset get velocity => Offset(cos(heading), sin(heading)) * speed;
}

/// Déplace les koï : errance, évitement des bords, distance entre eux.
///
/// Tout est en pixels et en secondes, sans dépendance à Flutter : la
/// simulation se teste seule.
class KoiSimulation {
  /// Au-delà, on ne dessine plus : le tableau de bord affiche « +N ».
  static const int maxAgents = 24;

  /// Un pas de temps borné : après une pause, la scène reprend en douceur
  /// au lieu de projeter les poissons à travers le bassin.
  static const double maxStep = 1 / 30;

  final Random _random;
  Size _bounds;
  final List<KoiAgent> agents = [];

  /// Combien de koï vivants n'ont pas trouvé de place dans la scène.
  int hiddenCount = 0;

  KoiSimulation({required Size bounds, Random? random})
    : _bounds = bounds,
      _random = random ?? Random();

  Size get bounds => _bounds;

  /// Longueur à l'écran d'un koï : proportionnelle à sa taille, bornée pour
  /// qu'un alevin reste visible et qu'un jumbo tienne dans l'écran.
  static double lengthFor(Koi koi) => (koi.size * 1.6).clamp(40.0, 140.0);

  /// Les grands nagent plus lentement, en pixels ; c'est ce qui rend leur
  /// masse crédible.
  static double speedFor(double length) => (1100 / length).clamp(9.0, 30.0);

  /// Reçoit la collection. Les koï déjà présents gardent leur position ; les
  /// nouveaux apparaissent à un endroit stable déduit de leur identifiant.
  void setKois(List<Koi> kois) {
    final alive = kois.where((k) => k.status == KoiStatus.alive).toList();
    final shown = alive.take(maxAgents).toList();
    hiddenCount = alive.length - shown.length;

    final existing = {for (final a in agents) a.koi.id: a};
    agents
      ..clear()
      ..addAll(
        shown.map((koi) {
          final seed = koi.id.hashCode;
          final previous = existing[koi.id];
          final length = lengthFor(koi);
          if (previous != null) {
            return KoiAgent(
              koi: koi,
              seed: seed,
              length: length,
              position: previous.position,
              heading: previous.heading,
              speed: speedFor(length),
              phase: previous.phase,
            )..wanderTarget = previous.wanderTarget;
          }
          final placer = Random(seed);
          return KoiAgent(
            koi: koi,
            seed: seed,
            length: length,
            position: Offset(
              _bounds.width * (0.15 + placer.nextDouble() * 0.7),
              _bounds.height * (0.15 + placer.nextDouble() * 0.7),
            ),
            heading: placer.nextDouble() * 2 * pi,
            speed: speedFor(length),
            phase: placer.nextDouble() * 2 * pi,
          );
        }),
      );
  }

  /// Nouvelle taille de scène : on ramène ce qui déborderait.
  void resize(Size bounds) {
    _bounds = bounds;
    for (final a in agents) {
      a.position = Offset(
        a.position.dx.clamp(0.0, bounds.width),
        a.position.dy.clamp(0.0, bounds.height),
      );
    }
  }

  /// Avance la simulation de [dt] secondes.
  void step(double dt) {
    final delta = dt.clamp(0.0, maxStep);
    if (delta == 0 || _bounds.isEmpty) return;

    final margin = min(_bounds.width, _bounds.height) * 0.12;
    final center = Offset(_bounds.width / 2, _bounds.height / 2);

    for (final a in agents) {
      // Errance : la cible dérive un peu, et le cap la rejoint doucement.
      a.wanderTarget += (_random.nextDouble() - 0.5) * 1.6 * delta;
      double steer = _angleDelta(a.heading, a.wanderTarget) * 1.2;

      // Bords : plus on s'en approche, plus on braque vers le centre.
      final penetration = _edgePenetration(a.position, margin);
      if (penetration > 0) {
        final toCenter = atan2(
          center.dy - a.position.dy,
          center.dx - a.position.dx,
        );
        steer += _angleDelta(a.heading, toCenter) * (2.5 + penetration * 6);
        a.wanderTarget = toCenter;
      }

      // Séparation : un koï ne traverse pas son voisin.
      for (final other in agents) {
        if (identical(a, other)) continue;
        final gap = a.position - other.position;
        final minGap = (a.length + other.length) * 0.4;
        final distance = gap.distance;
        if (distance > 0 && distance < minGap) {
          final away = atan2(gap.dy, gap.dx);
          steer += _angleDelta(a.heading, away) * (1 - distance / minGap) * 3;
        }
      }

      a.heading += steer.clamp(-2.4, 2.4) * delta;
      a.position += a.velocity * delta;
      a.position = Offset(
        a.position.dx.clamp(0.0, _bounds.width),
        a.position.dy.clamp(0.0, _bounds.height),
      );

      // L'ondulation suit la vitesse : un koï qui va vite bat plus vite.
      a.phase += delta * (2.4 + a.speed * 0.12);
    }
  }

  /// Le koï le plus proche d'un point, s'il y en a un à portée de doigt.
  KoiAgent? hitTest(Offset point, {double radius = 28}) {
    KoiAgent? best;
    double bestDistance = double.infinity;
    for (final a in agents) {
      // On teste contre le corps entier, pas seulement le centre.
      final d = _distanceToSegment(point, a);
      if (d < bestDistance) {
        bestDistance = d;
        best = a;
      }
    }
    return bestDistance <= radius ? best : null;
  }

  double _distanceToSegment(Offset p, KoiAgent a) {
    final dir = Offset(cos(a.heading), sin(a.heading));
    final head = a.position + dir * (a.length * 0.35);
    final tail = a.position - dir * (a.length * 0.65);
    final seg = tail - head;
    final len2 = seg.dx * seg.dx + seg.dy * seg.dy;
    if (len2 == 0) return (p - head).distance;
    final t = (((p - head).dx * seg.dx + (p - head).dy * seg.dy) / len2).clamp(0.0, 1.0);
    return (p - (head + seg * t)).distance;
  }

  /// De 0 (loin des bords) à 1 (sur le bord).
  double _edgePenetration(Offset p, double margin) {
    final left = margin - p.dx;
    final right = p.dx - (_bounds.width - margin);
    final top = margin - p.dy;
    final bottom = p.dy - (_bounds.height - margin);
    final worst = [left, right, top, bottom].reduce(max);
    return (worst / margin).clamp(0.0, 1.0);
  }

  /// Plus court chemin angulaire de [from] vers [to], dans [-π, π].
  static double _angleDelta(double from, double to) {
    var d = (to - from) % (2 * pi);
    if (d > pi) d -= 2 * pi;
    if (d < -pi) d += 2 * pi;
    return d;
  }
}
