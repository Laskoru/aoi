import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../models/koi.dart';
import '../../../services/koi_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';
import '../../../widgets/water_chart.dart' show ChartCard;
import 'update_size_sheet.dart';

/// Dernière taille, saisie d'une nouvelle mesure, et courbe de croissance.
class KoiGrowthSection extends StatelessWidget {
  final Koi koi;

  const KoiGrowthSection({super.key, required this.koi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.koiLastSize,
                    style: context.texts.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    "${koi.size.toStringAsFixed(1)} cm",
                    style: context.texts.headlineMedium,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _openSizeSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.l10n.koiMeasure),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                  foregroundColor: context.colors.onSecondaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ChartCard(child: _GrowthChart(koiId: koi.id)),
      ],
    );
  }

  void _openSizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheet),
          topRight: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (_) => UpdateSizeSheet(koiId: koi.id, currentSize: koi.size),
    );
  }
}

class _GrowthChart extends StatelessWidget {
  final String koiId;

  const _GrowthChart({required this.koiId});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<List<GrowthEntry>>(
      stream: KoiService.growthOf(koiId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: ErrorState(error: snapshot.error));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data ?? const <GrowthEntry>[];
        if (entries.isEmpty) {
          return Center(
            child: Text(
              context.l10n.koiGrowthEmpty,
              style: context.texts.bodyMedium,
              textAlign: TextAlign.center,
            ),
          );
        }

        final spots = <FlSpot>[
          for (int i = 0; i < entries.length; i++)
            FlSpot(i.toDouble(), entries[i].size),
        ];
        final labels = [
          for (final entry in entries)
            entry.measuredAt == null
                ? ""
                : DateFormat.Md(context.localeName).format(entry.measuredAt!),
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
                      Text(value.toStringAsFixed(0), style: axisStyle),
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
                        "${spot.y.toStringAsFixed(1)} cm",
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
                color: colors.secondary,
                barWidth: 3.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) =>
                      FlDotCirclePainter(
                        radius: 3.5,
                        color: colors.surface,
                        strokeWidth: 2.5,
                        strokeColor: colors.secondary,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.secondary.withValues(alpha: 0.22),
                      colors.secondary.withValues(alpha: 0.0),
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
