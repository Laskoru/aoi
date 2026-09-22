import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// L'eau du bassin.
///
/// Un fragment shader quand il est disponible et que le mouvement est
/// souhaité ; sinon, un dégradé et trois ondulations fixes peints à la main.
/// Les deux rendus partagent les mêmes couleurs, tirées du thème : passer
/// de l'un à l'autre ne change pas l'ambiance, seulement la vie.
class WaterLayer extends StatelessWidget {
  final double time;
  final bool animated;
  final Color shallow;
  final Color deep;

  /// Force des filets de lumière : 0 les éteint, 0.22 est la scène pleine.
  final double causticIntensity;

  /// Amplitude des ondulations : 0 fige la surface, 0.6 est la scène pleine.
  final double waveAmplitude;

  const WaterLayer({
    super.key,
    required this.time,
    required this.animated,
    required this.shallow,
    required this.deep,
    this.causticIntensity = 0.22,
    this.waveAmplitude = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    if (!animated) {
      return CustomPaint(
        painter: _WaterFallbackPainter(shallow: shallow, deep: deep),
        size: Size.infinite,
      );
    }

    return FutureBuilder<FragmentProgram?>(
      future: _WaterShader.program,
      builder: (context, snapshot) {
        final program = snapshot.data;
        if (program == null) {
          return CustomPaint(
            painter: _WaterFallbackPainter(shallow: shallow, deep: deep),
            size: Size.infinite,
          );
        }
        return CustomPaint(
          painter: _WaterShaderPainter(
            shader: _WaterShader.shaderFor(program),
            time: time,
            shallow: shallow,
            deep: deep,
            causticIntensity: causticIntensity,
            waveAmplitude: waveAmplitude,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Chargement unique du programme, et un seul `FragmentShader` réutilisé
/// d'image en image : en recréer un à chaque tick coûterait cher pour rien.
class _WaterShader {
  static Future<FragmentProgram?>? _loading;
  static FragmentShader? _shader;

  static Future<FragmentProgram?> get program {
    return _loading ??= FragmentProgram.fromAsset('shaders/pond_water.frag')
        .then<FragmentProgram?>((p) => p)
        .catchError((Object e) {
          // Sans shader, la scène reste belle : on passe au repli.
          debugPrint('[AOI] Shader d\'eau indisponible : $e');
          return null;
        });
  }

  static FragmentShader shaderFor(FragmentProgram program) =>
      _shader ??= program.fragmentShader();
}

class _WaterShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  final Color shallow;
  final Color deep;
  final double causticIntensity;
  final double waveAmplitude;

  _WaterShaderPainter({
    required this.shader,
    required this.time,
    required this.shallow,
    required this.deep,
    required this.causticIntensity,
    required this.waveAmplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ordre de déclaration du .frag : uResolution, uTime, uColorShallow,
    // uColorDeep, uCausticIntensity, uWaveAmplitude.
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, shallow.r)
      ..setFloat(4, shallow.g)
      ..setFloat(5, shallow.b)
      ..setFloat(6, deep.r)
      ..setFloat(7, deep.g)
      ..setFloat(8, deep.b)
      ..setFloat(9, causticIntensity)
      ..setFloat(10, waveAmplitude);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _WaterShaderPainter old) =>
      old.time != time ||
      old.shallow != shallow ||
      old.deep != deep ||
      old.causticIntensity != causticIntensity ||
      old.waveAmplitude != waveAmplitude;
}

/// Repli sans shader : le même dégradé de profondeur, et trois ondulations
/// dessinées une fois pour toutes.
class _WaterFallbackPainter extends CustomPainter {
  final Color shallow;
  final Color deep;

  const _WaterFallbackPainter({required this.shallow, required this.deep});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.25),
          radius: 1.1,
          colors: [deep, shallow],
          stops: const [0.15, 1.0],
        ).createShader(rect),
    );

    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.10);
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final baseY = size.height * (0.25 + i * 0.22);
      for (double x = 0; x <= size.width; x += 8) {
        final y = baseY + sin(x / size.width * 2 * pi * (2 + i) + i) * 6;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, ripple);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterFallbackPainter old) =>
      old.shallow != shallow || old.deep != deep;
}
