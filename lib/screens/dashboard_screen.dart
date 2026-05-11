import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/koi.dart';
import '../utils/water_logic.dart';
import 'add_koi_screen.dart';
import 'add_measurement_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _koisRef = FirebaseFirestore.instance.collection('kois');
  final _waterRef = FirebaseFirestore.instance.collection('measurements');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AOI - Cloud Bassin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Mes Koi"),
              Tab(text: "Analyses"),
            ],
          ),
        ),
        body: TabBarView(children: [_buildKoiTab(), _buildAnalysisTab()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddOptions(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildKoiTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _koisRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Center(child: Text("Erreur: ${snapshot.error}"));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final kois = snapshot.data!.docs
            .map((doc) => Koi.fromFirestore(doc))
            .toList();
        if (kois.isEmpty)
          return const Center(child: Text("Aucun Koi dans le bassin"));

        return ListView.builder(
          itemCount: kois.length,
          itemBuilder: (context, i) => ListTile(
            leading: const Icon(Icons.set_meal, color: Colors.blue),
            title: Text(kois[i].name),
            subtitle: Text("${kois[i].variety} - ${kois[i].size}cm"),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _koisRef.doc(kois[i].id).delete(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalysisTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _waterRef.orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final measurements = snapshot.data!.docs
            .map((doc) => WaterMeasurement.fromFirestore(doc))
            .toList();
        if (measurements.isEmpty)
          return const Center(child: Text("Aucun relevé cloud"));

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: measurements.length,
          itemBuilder: (context, i) => _buildMeasurementTile(measurements[i]),
        );
      },
    );
  }

  Widget _buildMeasurementTile(WaterMeasurement m) {
    final statusColor = WaterLogic.getColor('ph', m.ph);
    return Card(
      child: ExpansionTile(
        leading: Icon(Icons.water_drop, color: statusColor),
        title: Text(DateFormat('dd/MM/yyyy').format(m.date)),
        subtitle: Text("pH: ${m.ph} | NO2: ${m.nitrite}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => _waterRef.doc(m.id).delete(),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _rowParam(
                  "Température",
                  "${m.temperature}°C",
                  WaterLogic.getColor('temp', m.temperature),
                ),
                _rowParam("pH", "${m.ph}", WaterLogic.getColor('ph', m.ph)),
                _rowParam(
                  "Carbonate",
                  "${m.carbonate} ppm",
                  WaterLogic.getColor('carbonate', m.carbonate),
                ),
                _rowParam(
                  "Nitrite (NO2)",
                  "${m.nitrite} ppm",
                  WaterLogic.getColor('nitrite', m.nitrite),
                ),
                _rowParam(
                  "Nitrate (NO3)",
                  "${m.nitrate} ppm",
                  WaterLogic.getColor('nitrate', m.nitrate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowParam(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Ajouter un Koi'),
            onTap: () async {
              Navigator.pop(context);
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddKoiScreen()),
              );
              if (res != null && res is Koi) {
                await _koisRef.add(res.toMap());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.science),
            title: const Text('Nouveau relevé d\'eau'),
            onTap: () async {
              Navigator.pop(context);
              final res = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const AddMeasurementScreen()),
              );
              if (res != null && res is WaterMeasurement) {
                await _waterRef.add(res.toMap());
              }
            },
          ),
        ],
      ),
    );
  }
}
