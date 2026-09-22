import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/water_measurement.dart';
import '../services/measurement_service.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../utils/water_logic.dart';

/// Courbe d'un paramètre de l'eau sur les derniers relevés.
class WaterChart extends StatelessWidget {
  final String userId;
  final WaterParameter parameter;
  final Color color;

  const WaterChart({
    super.key,
    required this.userId,
    required this.parameter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<List<WaterMeasurement>>(
      // Sept points suffisent à lire une tendance.
      stream: MeasurementService.series(userId, limit: 7),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: ErrorState(error: snapshot.error));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Un relevé rapide peut ne pas contenir ce paramètre : on l'ignore
        // plutôt que de tracer un zéro qui ressemblerait à une chute.
        final points = (snapshot.data ?? const <WaterMeasurement>[])
            .where((m) => m.valueOf(parameter) != null)
            .toList();

        if (points.isEmpty) {
          return Center(
            child: Text(
              "Aucune donnée pour le moment",
              style: context.texts.bodyMedium,
            ),
          );
        }

        final spots = <FlSpot>[
          for (int i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].valueOf(parameter)!),
        ];
        final labels = [
          for (final m in points)
            m.measuredAt == null
                ? ""
                : DateFormat('dd/MM').format(m.measuredAt!),
        ];

        final axisStyle = context.texts.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        );

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: colors.outlineVariant, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) =>
                      Text(value.toStringAsFixed(1), style: axisStyle),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      meta: meta,
                      space: 10,
                      child: Text(labels[index], style: axisStyle),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => colors.inverseSurface,
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map(
                      (spot) => LineTooltipItem(
                        "${spot.y.toStringAsFixed(1)}${parameter.unit.isEmpty ? '' : ' ${parameter.unit}'}",
                        TextStyle(
                          color: colors.onInverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.28,
                color: color,
                barWidth: 3.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 3.5,
                        color: colors.surface,
                        strokeWidth: 2.5,
                        strokeColor: color,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Conteneur commun aux graphiques : hauteur fixe, surface de carte.
class ChartCard extends StatelessWidget {
  final Widget child;
  final double height;

  const ChartCard({super.key, required this.child, this.height = 230});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: context.isDark ? 0.30 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
