import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Aucun utilisateur connecté')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('measurements').add({
        'ph': double.tryParse(_phController.text.trim()) ?? 7.0,
        'temperature': double.tryParse(_tempController.text.trim()) ?? 0.0,
        'userId': user.uid, // <-- On l'ajoute aussi ici
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesure ajoutée avec succès !')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une mesure')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _phController,
                decoration: const InputDecoration(
                  labelText: 'Niveau de pH (ex: 7.2)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer le pH' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                decoration: const InputDecoration(
                  labelText: 'Température (°C)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer la température' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveMeasurement,
                      child: const Text('Enregistrer la mesure'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
