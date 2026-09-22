import 'package:flutter/material.dart';
import '../models/water_measurement.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';

/// Bandeau qui résume l'état du bassin d'un coup d'œil, en nommant le
/// paramètre le plus préoccupant : on sait quoi corriger sans chercher.
class WaterHealthBanner extends StatelessWidget {
  final WaterMeasurement measurement;

  const WaterHealthBanner({super.key, required this.measurement});

  @override
  Widget build(BuildContext context) {
    final readings = measurement.readings;
    final condition = worstCondition(readings.map((r) => r.condition));
    final concerning = mostConcerningReading(readings);
    final color = condition.color(context);

    final headline = switch (condition) {
      WaterCondition.ideal => "Bassin en bonne santé",
      _ =>
        "${concerning!.parameter.label} : ${concerning.formattedValue} ${concerning.parameter.unit}"
            .trim(),
    };
    final detail = concerning?.parameter.explanation ?? condition.advice;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: condition.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(condition.icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headline,
                    style: context.texts.labelLarge?.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(detail, style: context.texts.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
