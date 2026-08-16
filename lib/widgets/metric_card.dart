import 'package:flutter/material.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';

/// Carte d'un paramètre de l'eau : la valeur en gros, l'état en couleur.
///
/// La couleur et le libellé de l'état viennent de [WaterConditionStyle] : la
/// carte ne décide de rien, elle affiche.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final WaterCondition condition;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
              Icon(icon, color: statusColor, size: 22),
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
          Text(title, style: context.texts.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                    color: colors.onSurface,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: " $unit",
                    style: TextStyle(
                      fontSize: 14,
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
