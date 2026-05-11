import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/koi.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});
  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();

  final Map<String, TextEditingController> _ctrl = {
    'temp': TextEditingController(),
    'ph': TextEditingController(),
    'kh': TextEditingController(),
    'gh': TextEditingController(),
    't_cl': TextEditingController(),
    'f_cl': TextEditingController(),
    'no2': TextEditingController(),
    'no3': TextEditingController(),
  };

  Widget _buildField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _ctrl[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? 'Requis' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Relevé')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(
                "Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
            const SizedBox(height: 10),
            _buildField("Température (°C)", "temp"),
            _buildField("pH", "ph"),
            _buildField("Carbonate (ppm)", "kh"),
            _buildField("Hardness (ppm)", "gh"),
            _buildField("Total Chlorine (ppm)", "t_cl"),
            _buildField("Free Chlorine (ppm)", "f_cl"),
            _buildField("Nitrite (ppm)", "no2"),
            _buildField("Nitrate (ppm)", "no3"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final m = WaterMeasurement(
                    id: DateTime.now().toString(),
                    date: _selectedDate,
                    temperature: double.parse(_ctrl['temp']!.text),
                    ph: double.parse(_ctrl['ph']!.text),
                    carbonate: double.parse(_ctrl['kh']!.text),
                    hardness: double.parse(_ctrl['gh']!.text),
                    totalChlorine: double.parse(_ctrl['t_cl']!.text),
                    freeChlorine: double.parse(_ctrl['f_cl']!.text),
                    nitrite: double.parse(_ctrl['no2']!.text),
                    nitrate: double.parse(_ctrl['no3']!.text),
                  );
                  Navigator.pop(context, m);
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
