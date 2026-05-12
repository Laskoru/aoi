import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddKoiScreen extends StatefulWidget {
  const AddKoiScreen({super.key});

  @override
  State<AddKoiScreen> createState() => _AddKoiScreenState();
}

class _AddKoiScreenState extends State<AddKoiScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveKoi() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Récupération de l'utilisateur actif
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Aucun utilisateur connecté')),
        );
        return;
      }

      // 2. Sauvegarde des données avec le userId
      await FirebaseFirestore.instance.collection('kois').add({
        'name': _nameController.text.trim(),
        'variety': _varietyController.text.trim(),
        'size': double.tryParse(_sizeController.text.trim()) ?? 0.0,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'userId': user.uid, // <-- Le lien magique avec l'utilisateur
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carpe Koï ajoutée avec succès !')),
        );
        Navigator.pop(context); // Retour à l'écran précédent
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde : $e')),
        );
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
    _nameController.dispose();
    _varietyController.dispose();
    _sizeController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Koï')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du Koï'),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer un nom' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _varietyController,
                decoration: const InputDecoration(
                  labelText: 'Variété (ex: Kohaku)',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une variété' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Taille (en cm)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une taille' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Âge (en années)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveKoi,
                      child: const Text('Sauvegarder'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
