import 'package:flutter/material.dart';

void main() => runApp(Aoi());

class Aoi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: DashboardBassin(),
    );
  }
}

class DashboardBassin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Sanctuaire Koï")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte État de Santé
            _buildStatusCard("État Global", "Optimal", Colors.green),
            SizedBox(height: 20),
            // Ligne avec Température et pH
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    "Température",
                    "22°C",
                    Icons.thermostat,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildMetricCard("pH", "7.5", Icons.water_drop),
                ),
              ],
            ),
            SizedBox(height: 30),
            // Bouton Action (Futur revenu : Acheter des tests ou nourriture)
            ElevatedButton(
              onPressed: () {},
              child: Text("Ajouter un relevé d'eau"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget réutilisable pour les cartes
  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title),
          Text(
            status,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

void _afficherFormulaireAjout(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ajouter un nouveau Koï",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(labelText: "Surnom du poisson"),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "Variété (Kohaku, Showa...)",
            ),
          ),
          TextField(
            decoration: InputDecoration(labelText: "Taille actuelle (cm)"),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Enregistrer dans le bassin"),
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}
