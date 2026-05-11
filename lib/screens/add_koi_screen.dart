import 'package:flutter/material.dart';
import '../models/koi.dart';

class AddKoiScreen extends StatefulWidget {
  const AddKoiScreen({super.key});

  @override
  State<AddKoiScreen> createState() => _AddKoiScreenState();
}

class _AddKoiScreenState extends State<AddKoiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une Carpe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom du Koi'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _varietyController,
                decoration: const InputDecoration(
                  labelText: 'Variété (ex: Kohaku)',
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _sizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Taille (cm)'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final koi = Koi(
                      id: DateTime.now().toString(),
                      name: _nameController.text,
                      variety: _varietyController.text,
                      size: double.tryParse(_sizeController.text) ?? 0,
                      age: 0,
                    );
                    Navigator.pop(context, koi);
                  }
                },
                child: const Text('Ajouter au bassin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
