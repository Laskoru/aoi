import 'package:flutter/material.dart';
import '../widgets/metric_card.dart';
import 'add_koi_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          "AOI • Gestion Bassin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Paramètres de l'eau",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: "Temp.",
                  value: "21.5°C",
                  icon: Icons.thermostat,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: MetricCard(
                  title: "pH",
                  value: "7.4",
                  icon: Icons.water_drop,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: MetricCard(
                  title: "NO2",
                  value: "0.01",
                  icon: Icons.science,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ma Collection",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddKoiScreen()),
                ),
              ),
            ],
          ),
          // Liste vide pour l'instant
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                "Aucun poisson enregistré",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
