import 'dart:math';
import 'package:flutter/material.dart';
import 'koi_pattern.dart';
import 'koi_simulation.dart';

/// Dessine un koï vu d'en haut : un corps fuselé qui ondule, deux nageoires
/// pectorales, une caudale, et le motif de sa variété.
///
/// Tout est procédural. Les chemins sont recalculés à chaque image parce que
/// le corps ondule, mais sans allocation superflue : un seul `Path` par
/// poisson, réutilisé pour le corps, l'ombre et le découpage du motif.
class KoiPainter {
  const KoiPainter._();

  static const int _segments = 10;

  static void paint(Canvas canvas, KoiAgent agent, KoiPattern pattern) {
    final length = agent.length;
    final body = _bodyPath(agent);

    canvas.save();
    canvas.translate(agent.position.dx, agent.position.dy);
    canvas.rotate(agent.heading);

    // Ombre portée, décalée : c'est elle qui donne la profondeur d'eau.
    canvas.save();
    canvas.translate(length * 0.06, length * 0.10);
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.restore();

    // Nageoires, sous le corps.
    final finPaint = Paint()..color = pattern.base.withValues(alpha: 0.75);
    _drawFins(canvas, agent, finPaint);

    // Corps et motif, découpé au contour.
    canvas.drawPath(body, Paint()..color = pattern.base);
    canvas.save();
    canvas.clipPath(body);
    _drawPattern(canvas, agent, pattern);
    if (pattern.metallic) _drawSheen(canvas, agent);
    canvas.restore();

    // Un fin liseré sombre : le poisson se détache de l'eau.
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black.withValues(alpha: 0.22),
    );

    // Œil.
    canvas.drawCircle(
      Offset(length * 0.24, -length * 0.06),
      length * 0.022,
      Paint()..color = KoiPattern.sumi,
    );
    canvas.drawCircle(
      Offset(length * 0.24, length * 0.06),
      length * 0.022,
      Paint()..color = KoiPattern.sumi,
    );

    canvas.restore();
  }

  /// Contour du corps dans le repère du poisson : la tête vers +x, le corps
  /// ondulant latéralement selon la phase.
  static Path _bodyPath(KoiAgent agent) {
    final length = agent.length;
    final amplitude = length * 0.07;
    final left = <Offset>[];
    final right = <Offset>[];

    for (int i = 0; i <= _segments; i++) {
      final t = i / _segments; // 0 = tête, 1 = queue
      final x = length * 0.35 - t * length;
      // L'ondulation croît de la tête vers la queue : la tête reste stable,
      // c'est la queue qui propulse.
      final sway = sin(agent.phase - t * 3.4) * amplitude * t * t;
      final halfWidth = _halfWidth(t) * length;
      left.add(Offset(x, sway - halfWidth));
      right.add(Offset(x, sway + halfWidth));
    }

    // Caudale : une fourche à l'arrière, qui bat avec la queue.
    final tailSway = sin(agent.phase - 3.4) * amplitude;
    final tailX = length * 0.35 - length;
    final tail = [
      Offset(tailX - length * 0.16, tailSway - length * 0.13),
      Offset(tailX - length * 0.06, tailSway),
      Offset(tailX - length * 0.16, tailSway + length * 0.13),
    ];

    final path = Path()..moveTo(left.first.dx, left.first.dy);
    for (int i = 1; i < left.length; i++) {
      final prev = left[i - 1];
      final cur = left[i];
      path.quadraticBezierTo(prev.dx, prev.dy, (prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
    }
    path.lineTo(left.last.dx, left.last.dy);
    for (final p in tail) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(right.last.dx, right.last.dy);
    for (int i = right.length - 2; i >= 0; i--) {
      final prev = right[i + 1];
      final cur = right[i];
      path.quadraticBezierTo(prev.dx, prev.dy, (prev.dx + cur.dx) / 2, (prev.dy + cur.dy) / 2);
    }
    path.close();
    return path;
  }

  /// Demi-largeur relative à la longueur : un museau arrondi, une épaule
  /// large, un pédoncule fin.
  static double _halfWidth(double t) {
    if (t < 0.18) return 0.09 + 0.08 * (t / 0.18);
    final u = (t - 0.18) / 0.82;
    return 0.17 * pow(1 - u, 0.85).toDouble() + 0.02;
  }

  static void _drawFins(Canvas canvas, KoiAgent agent, Paint paint) {
    final length = agent.length;
    final flap = sin(agent.phase * 1.3) * 0.25;
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(length * 0.10, side * length * 0.14);
      canvas.rotate(side * (0.9 + flap));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-length * 0.06, 0),
          width: length * 0.22,
          height: length * 0.09,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  static void _drawPattern(Canvas canvas, KoiAgent agent, KoiPattern pattern) {
    final length = agent.length;
    final random = Random(agent.seed);
    final accent = pattern.accent;
    final secondary = pattern.secondary;

    switch (pattern.kind) {
      case KoiPatternKind.solid:
        // Ventre plus clair sur les koï unis orangés : un dégradé suffit.
        if (secondary != null) {
          canvas.drawRect(
            Rect.fromLTWH(-length, -length, length * 2, length * 2),
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [pattern.base, secondary.withValues(alpha: 0.45)],
                stops: const [0.55, 1.0],
              ).createShader(Rect.fromLTWH(-length * 0.65, 0, length, 1)),
          );
        }
      case KoiPatternKind.patches:
        _patches(canvas, length, random, accent!, count: 3);
      case KoiPatternKind.patchesAndSpots:
        _patches(canvas, length, random, accent!, count: 3);
        _spots(canvas, length, random, secondary!, count: 5);
      case KoiPatternKind.spots:
        _spots(canvas, length, random, accent!, count: 6);
      case KoiPatternKind.tancho:
        canvas.drawCircle(
          Offset(length * 0.22, 0),
          length * 0.085,
          Paint()..color = accent!,
        );
      case KoiPatternKind.bands:
        for (int i = 0; i < 3; i++) {
          final x = length * (0.15 - i * 0.28) + random.nextDouble() * length * 0.06;
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset(x, 0),
              width: length * (0.10 + random.nextDouble() * 0.06),
              height: length,
            ),
            Paint()..color = accent!,
          );
        }
      case KoiPatternKind.reticulated:
        _reticulation(canvas, length, secondary ?? KoiPattern.shiroji);
        if (accent != null) {
          // Le hi de l'asagi court sur les flancs, sous la ligne du dos.
          for (final side in const [-1.0, 1.0]) {
            canvas.drawRect(
              Rect.fromLTWH(-length * 0.55, side * length * 0.10, length * 0.8, length * 0.07),
              Paint()..color = accent.withValues(alpha: 0.85),
            );
          }
        }
    }
  }

  static void _patches(Canvas canvas, double length, Random random, Color color, {required int count}) {
    final paint = Paint()..color = color;
    for (int i = 0; i < count; i++) {
      final x = length * (0.25 - i * 0.32) + (random.nextDouble() - 0.5) * length * 0.12;
      final y = (random.nextDouble() - 0.5) * length * 0.10;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: length * (0.22 + random.nextDouble() * 0.12),
          height: length * (0.22 + random.nextDouble() * 0.10),
        ),
        paint,
      );
    }
  }

  static void _spots(Canvas canvas, double length, Random random, Color color, {required int count}) {
    final paint = Paint()..color = color;
    for (int i = 0; i < count; i++) {
      final x = length * (0.2 - random.nextDouble() * 0.75);
      final y = (random.nextDouble() - 0.5) * length * 0.16;
      canvas.drawCircle(Offset(x, y), length * (0.025 + random.nextDouble() * 0.03), paint);
    }
  }

  static void _reticulation(Canvas canvas, double length, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color.withValues(alpha: 0.55);
    final step = length * 0.07;
    for (double x = -length * 0.6; x < length * 0.3; x += step) {
      for (double y = -length * 0.10; y <= length * 0.10; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.42, paint);
      }
    }
  }

  static void _drawSheen(Canvas canvas, KoiAgent agent) {
    final length = agent.length;
    canvas.drawRect(
      Rect.fromLTWH(-length * 0.6, -length * 0.06, length * 0.9, length * 0.05),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }
}

/// Peint tous les koï de la simulation. Le motif de chacun est mis en cache
/// par identifiant : il ne se recalcule pas à chaque image.
class KoiSwarmPainter extends CustomPainter {
  final List<KoiAgent> agents;
  final Map<String, KoiPattern> _patterns = {};

  /// Compteur d'images, pour forcer le repaint à chaque tick.
  final int frame;

  KoiSwarmPainter({required this.agents, required this.frame});

  @override
  void paint(Canvas canvas, Size size) {
    for (final agent in agents) {
      final key = '${agent.koi.id}|${agent.koi.variety}';
      final pattern = _patterns.putIfAbsent(
        key,
        () => KoiPattern.fromVariety(agent.koi.variety),
      );
      KoiPainter.paint(canvas, agent, pattern);
    }
  }

  @override
  bool shouldRepaint(covariant KoiSwarmPainter old) =>
      old.frame != frame || old.agents != agents;
}
