import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';

/// Carte d'un paramètre de l'eau : la valeur en gros, l'état en couleur.
///
/// La carte ne décide de rien : le seuil vient de [WaterLogic], la couleur de
/// [WaterConditionStyle]. Elle affiche.
class MetricCard extends StatelessWidget {
  final WaterReading reading;

  const MetricCard({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final condition = reading.condition;
    final statusColor = condition.color(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: context.isDark ? 0.30 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(reading.parameter.icon, color: statusColor, size: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: condition.surface(context),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  condition.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            reading.parameter.label,
            style: context.texts.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: reading.formattedValue,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: colors.onSurface,
                  ),
                ),
                if (reading.parameter.unit.isNotEmpty)
                  TextSpan(
                    text: " ${reading.parameter.unit}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
