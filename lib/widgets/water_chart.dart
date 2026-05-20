import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Pour formater les dates proprement

class WaterChart extends StatelessWidget {
  final String userId;
  final String field; // "ph" ou "temperature"
  final Color color;

  const WaterChart({
    super.key,
    required this.userId,
    required this.field,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('measurements')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(7) // On limite à 7 points pour la lisibilité
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Aucune donnée pour le moment",
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ), // Correction Colors.slate
            ),
          );
        }

        // Inversion pour afficher chronologiquement de gauche à droite
        final docs = snapshot.data!.docs.reversed.toList();

        List<FlSpot> spots = [];
        List<String> formattedDates = [];

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;

          final double value = (data[field] as num? ?? 0.0).toDouble();
          spots.add(FlSpot(i.toDouble(), value));

          if (data['timestamp'] != null) {
            final DateTime dateTime = (data['timestamp'] as Timestamp).toDate();
            formattedDates.add(DateFormat('dd/MM').format(dateTime));
          } else {
            formattedDates.add("");
          }
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false), // Design épuré sans grille
            borderData: FlBorderData(show: false),

            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),

              // AXE DE GAUCHE : Valeurs numériques
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),

              // AXE DU BAS : Affichage et ajustement des vraies dates
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize:
                      35, // Espace suffisant pour ne pas masquer le texte
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final int index = value.toInt();
                    if (index >= 0 && index < formattedDates.length) {
                      return SideTitleWidget(
                        meta: meta,
                        space: 10,
                        child: Text(
                          formattedDates[index],
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),

            // Boîte d'infos au clic sur un point
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => const Color(
                  0xFF0F172A,
                ), // Nouvelle syntaxe getTooltipColor requise
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      "${spot.y.toStringAsFixed(1)} ${field == 'temperature' ? '°C' : ''}",
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),

            // Ligne et courbe du graphique
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true, // Courbe lissée active
                color: color,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(
                  show: true,
                ), // Points activés simplement sans paramètres obsolètes
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.2),
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
