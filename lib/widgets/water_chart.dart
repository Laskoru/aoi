import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaterChart extends StatelessWidget {
  final String userId;
  final String field; // 'ph' ou 'temperature'
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
          .orderBy(
            'timestamp',
            descending: true,
          ) // On utilise le MÊME sens que le moniteur pour réutiliser ton index !
          .limit(10) // On prend les 10 dernières mesures
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Si Firestore renvoie une erreur, on l'affiche enfin à l'écran !
        if (snapshot.hasError) {
          debugPrint("Erreur Graphique ($field) : ${snapshot.error}");
          return Center(
            child: Text(
              "Erreur graphique : ${snapshot.error}",
              style: const TextStyle(color: Colors.red, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          );
        }

        // 2. Pendant le chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 3. S'il n'y a pas de données
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Pas assez de données pour tracer la courbe",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          );
        }

        // --- ASTUCE : On inverse l'ordre ici dans le code pour l'affichage chronologique ---
        final docs = snapshot.data!.docs.reversed.toList();

        List<FlSpot> spots = [];

        for (int i = 0; i < docs.length; i++) {
          final data = docs[i].data() as Map<String, dynamic>;
          // Sécurité au cas où la valeur ne serait pas un nombre
          double value = (data[field] as num).toDouble();
          spots.add(FlSpot(i.toDouble(), value));
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              show: true,
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ), // Cache les index purement numériques (0, 1, 2)
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved:
                    spots.length >
                    1, // Courbe uniquement s'il y a plusieurs points
                color: color,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(
                  show: true,
                ), // Affiche les points sur la ligne
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withOpacity(0.1), // Joli dégradé sous la courbe
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
