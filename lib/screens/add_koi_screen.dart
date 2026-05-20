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

  // Nouveaux contrôleurs pour la généalogie manuelle
  final TextEditingController _fatherManualController = TextEditingController();
  final TextEditingController _motherManualController = TextEditingController();

  // Variables d'état pour lier les IDs ou l'état manuel
  String? _selectedFatherId;
  String? _selectedMotherId;
  bool _isFatherManual = false;
  bool _isMotherManual = false;

  bool _isLoading = false;

  Future<void> _saveKoi() async {
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

      // Préparation de la structure avec les liens généalogiques
      await FirebaseFirestore.instance.collection('kois').add({
        'name': _nameController.text.trim(),
        'variety': _varietyController.text.trim(),
        'size': double.tryParse(_sizeController.text.trim()) ?? 0.0,
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),

        // Généalogie du père
        'fatherId': _selectedFatherId,
        'fatherNameManual': _isFatherManual
            ? _fatherManualController.text.trim()
            : null,

        // Généalogie de la mère
        'motherId': _selectedMotherId,
        'motherNameManual': _isMotherManual
            ? _motherManualController.text.trim()
            : null,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carpe Koï ajoutée avec succès ! 🎉')),
        );
        Navigator.pop(context);
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
    _fatherManualController.dispose();
    _motherManualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Ajouter un Koï',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Session expirée"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionTitle("Informations de base"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(
                        'Nom du Koï',
                        Icons.badge_rounded,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _varietyController,
                      decoration: _inputDecoration(
                        'Variété (ex: Kohaku)',
                        Icons.color_lens_rounded,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer une variété' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _sizeController,
                            decoration: _inputDecoration(
                              'Taille (cm)',
                              Icons.straighten_rounded,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Obligatoire' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: _inputDecoration(
                              'Âge (années)',
                              Icons.cake_rounded,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle("Généalogie & Origines"),
                    const SizedBox(height: 12),

                    // --- SÉLECTEUR DU PÈRE ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('kois')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem<String>> fatherItems = [
                          const DropdownMenuItem(
                            value: "none",
                            child: Text("Non renseigné"),
                          ),
                          const DropdownMenuItem(
                            value: "manual",
                            child: Text("✍️ Saisie manuelle / Autre espèce"),
                          ),
                        ];

                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final d = doc.data() as Map<String, dynamic>;
                            fatherItems.add(
                              DropdownMenuItem(
                                value: doc.id,
                                child: Text(
                                  "🐟 ${d['name']} (${d['variety']})",
                                ),
                              ),
                            );
                          }
                        }

                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _isFatherManual
                                  ? "manual"
                                  : (_selectedFatherId ?? "none"),
                              decoration: _inputDecoration(
                                'Père',
                                Icons.male_rounded,
                              ),
                              items: fatherItems,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "manual") {
                                    _isFatherManual = true;
                                    _selectedFatherId = null;
                                  } else if (value == "none") {
                                    _isFatherManual = false;
                                    _selectedFatherId = null;
                                  } else {
                                    _isFatherManual = false;
                                    _selectedFatherId = value;
                                  }
                                });
                              },
                            ),
                            if (_isFatherManual) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _fatherManualController,
                                decoration: _inputDecoration(
                                  'Nom/Variété du père sauvage',
                                  Icons.edit_note_rounded,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // --- SÉLECTEUR DE LA MÈRE ---
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('kois')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem<String>> motherItems = [
                          const DropdownMenuItem(
                            value: "none",
                            child: Text("Non renseigné"),
                          ),
                          const DropdownMenuItem(
                            value: "manual",
                            child: Text("✍️ Saisie manuelle / Autre espèce"),
                          ),
                        ];

                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final d = doc.data() as Map<String, dynamic>;
                            motherItems.add(
                              DropdownMenuItem(
                                value: doc.id,
                                child: Text(
                                  "🐟 ${d['name']} (${d['variety']})",
                                ),
                              ),
                            );
                          }
                        }

                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _isMotherManual
                                  ? "manual"
                                  : (_selectedMotherId ?? "none"),
                              decoration: _inputDecoration(
                                'Mère',
                                Icons.female_rounded,
                              ),
                              items: motherItems,
                              onChanged: (value) {
                                setState(() {
                                  if (value == "manual") {
                                    _isMotherManual = true;
                                    _selectedMotherId = null;
                                  } else if (value == "none") {
                                    _isMotherManual = false;
                                    _selectedMotherId = null;
                                  } else {
                                    _isMotherManual = false;
                                    _selectedMotherId = value;
                                  }
                                });
                              },
                            ),
                            if (_isMotherManual) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _motherManualController,
                                decoration: _inputDecoration(
                                  'Nom/Variété de la mère sauvage',
                                  Icons.edit_note_rounded,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveKoi,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sauvegarder la carpe',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue[900], size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue[900]!, width: 2),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
        letterSpacing: 0.5,
      ),
    );
  }
}
