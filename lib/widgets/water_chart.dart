import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';

/// Courbe d'un paramètre de l'eau sur les derniers relevés.
class WaterChart extends StatelessWidget {
  final String userId;

  /// Nom du champ Firestore à tracer : `ph` ou `temperature`.
  final String field;
  final Color color;

  const WaterChart({
    super.key,
    required this.userId,
    required this.field,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('measurements')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(7) // Sept points suffisent à lire une tendance.
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: ErrorState(error: snapshot.error));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Aucune donnée pour le moment",
              style: context.texts.bodyMedium,
            ),
          );
        }

        // Inversion pour lire chronologiquement, de gauche à droite.
        final docs = snapshot.data!.docs.reversed.toList();

        final spots = <FlSpot>[];
        final labels = <String>[];

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;
          spots.add(FlSpot(i.toDouble(), (data[field] as num? ?? 0).toDouble()));

          final timestamp = data['timestamp'] as Timestamp?;
          labels.add(
            timestamp == null ? "" : DateFormat('dd/MM').format(timestamp.toDate()),
          );
        }

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
                        "${spot.y.toStringAsFixed(1)}${field == 'temperature' ? ' °C' : ''}",
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

/// Conteneur commun aux graphiques : hauteur fixe, surface de carte, titre.
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
