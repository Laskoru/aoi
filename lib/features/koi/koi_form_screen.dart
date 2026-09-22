import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/koi.dart';
import '../../services/koi_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';

/// Formulaire d'un koï, en création comme en modification.
///
/// Les deux usages partagent les mêmes champs et les mêmes contrôles : les
/// séparer en deux écrans aurait dupliqué cinq cents lignes pour une poignée
/// de différences.
class KoiFormScreen extends StatefulWidget {
  /// Fiche à modifier. `null` pour une création.
  final Koi? existing;

  const KoiFormScreen({super.key, this.existing});

  @override
  State<KoiFormScreen> createState() => _KoiFormScreenState();
}

/// Origine d'un parent : non renseigné, un autre koï du bassin, ou une saisie
/// libre pour un géniteur qui n'est pas dans la collection.
enum _ParentMode { none, linked, manual }

class _KoiFormScreenState extends State<KoiFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _sizeController = TextEditingController();
  final _breederController = TextEditingController();
  final _originController = TextEditingController();
  final _notesController = TextEditingController();
  final _fatherManualController = TextEditingController();
  final _motherManualController = TextEditingController();

  DateTime? _birthDate;
  KoiSex _sex = KoiSex.unknown;
  KoiStatus _status = KoiStatus.alive;

  _ParentMode _fatherMode = _ParentMode.none;
  _ParentMode _motherMode = _ParentMode.none;
  String? _selectedFatherId;
  String? _selectedMotherId;

  bool _isLoading = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();

    final koi = widget.existing;
    if (koi == null) return;

    _nameController.text = koi.name;
    _varietyController.text = koi.variety;
    _sizeController.text = koi.size > 0 ? koi.size.toString() : '';
    _breederController.text = koi.breeder ?? '';
    _originController.text = koi.origin ?? '';
    _notesController.text = koi.notes ?? '';
    _fatherManualController.text = koi.fatherNameManual ?? '';
    _motherManualController.text = koi.motherNameManual ?? '';

    _birthDate = koi.birthDate;
    _sex = koi.sex;
    _status = koi.status;

    _fatherMode = _modeFor(koi.fatherId, koi.fatherNameManual);
    _selectedFatherId = koi.fatherId;
    _motherMode = _modeFor(koi.motherId, koi.motherNameManual);
    _selectedMotherId = koi.motherId;
  }

  _ParentMode _modeFor(String? id, String? manualName) {
    if (id != null) return _ParentMode.linked;
    if (manualName != null && manualName.trim().isNotEmpty) {
      return _ParentMode.manual;
    }
    return _ParentMode.none;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _sizeController.dispose();
    _breederController.dispose();
    _originController.dispose();
    _notesController.dispose();
    _fatherManualController.dispose();
    _motherManualController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 1, now.month, now.day),
      // Les koï dépassent couramment les trente ans, et bien davantage.
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Date de naissance du koï',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      fieldLabelText: 'Date de naissance',
    );

    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
    }
  }

  String? _trimmedOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Session expirée, reconnectez-vous.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final koi = Koi(
        id: widget.existing?.id ?? '',
        userId: user.uid,
        name: _nameController.text.trim(),
        variety: _varietyController.text.trim(),
        size:
            double.tryParse(_sizeController.text.trim().replaceAll(',', '.')) ??
            0.0,
        birthDate: _birthDate,
        sex: _sex,
        status: _status,
        breeder: _trimmedOrNull(_breederController),
        origin: _trimmedOrNull(_originController),
        notes: _trimmedOrNull(_notesController),
        // La photo n'est pas gérée ici : la reprendre telle quelle évite que
        // l'enregistrement du formulaire ne l'efface.
        imageUrl: widget.existing?.imageUrl,
        pondId: widget.existing?.pondId,
        fatherId: _fatherMode == _ParentMode.linked ? _selectedFatherId : null,
        fatherNameManual: _fatherMode == _ParentMode.manual
            ? _trimmedOrNull(_fatherManualController)
            : null,
        motherId: _motherMode == _ParentMode.linked ? _selectedMotherId : null,
        motherNameManual: _motherMode == _ParentMode.manual
            ? _trimmedOrNull(_motherManualController)
            : null,
      );

      if (_isEditing) {
        await KoiService.update(koi);
      } else {
        await KoiService.create(koi);
      }

      if (mounted) {
        _showSnack(_isEditing ? 'Fiche mise à jour.' : 'Carpe koï ajoutée ! 🎉');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Erreur lors de la sauvegarde : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete() async {
    final koi = widget.existing;
    if (koi == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${koi.name} ?'),
        content: const Text(
          "La fiche, son historique de croissance et sa photo seront effacés "
          "définitivement.\n\nLes koï qui la désignent comme parent garderont "
          "la trace d'une filiation, marquée comme introuvable.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.pond.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await KoiService.delete(koi);
      if (mounted) {
        _showSnack('${koi.name} a été supprimé.');
        // Deux retours : on quitte le formulaire, puis la fiche détail qui
        // n'a plus de document à afficher.
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack('Suppression impossible : $e');
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la fiche' : 'Ajouter un koï',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: context.pond.danger,
              tooltip: 'Supprimer ce koï',
              onPressed: _isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Session expirée"))
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SectionLabel("Informations de base"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Nom du koï',
                        Icons.badge_rounded,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Veuillez entrer un nom'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _varietyController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Variété (ex : Kohaku)',
                        Icons.color_lens_rounded,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Veuillez entrer une variété'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sizeController,
                      decoration: _inputDecoration(
                        'Taille (cm)',
                        Icons.straighten_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Obligatoire';
                        }
                        final parsed = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || parsed <= 0) {
                          return 'Taille invalide';
                        }
                        if (parsed > 200) return 'Taille irréaliste';
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    const SectionLabel("Naissance & identité"),
                    const SizedBox(height: 12),
                    _buildBirthDateField(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<KoiSex>(
                      initialValue: _sex,
                      decoration: _inputDecoration('Sexe', Icons.wc_rounded),
                      items: KoiSex.values
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.label)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _sex = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<KoiStatus>(
                      initialValue: _status,
                      decoration: _inputDecoration(
                        'Statut',
                        Icons.favorite_rounded,
                      ),
                      items: KoiStatus.values
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.label)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breederController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Éleveur (optionnel)',
                        Icons.storefront_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _originController,
                      decoration: _inputDecoration(
                        'Provenance (optionnel)',
                        Icons.place_rounded,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const SectionLabel("Généalogie & origines"),
                    const SizedBox(height: 12),
                    _buildParentSelectors(user.uid),

                    const SizedBox(height: 32),
                    const SectionLabel("Notes"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        'Observations, particularités…',
                        Icons.sticky_note_2_rounded,
                      ),
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.colors.onPrimary,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? 'Enregistrer les modifications'
                                    : 'Sauvegarder la carpe',
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
    );
  }

  // --- Date de naissance ---

  Widget _buildBirthDateField() {
    final hasDate = _birthDate != null;
    final dateLabel = hasDate
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(_birthDate!)
        : 'Non renseignée';

    // Aperçu de l'âge tel qu'il sera affiché sur la fiche.
    final preview = hasDate
        ? Koi(
            id: '',
            userId: '',
            name: '',
            variety: '',
            size: 0,
            birthDate: _birthDate,
          )
        : null;

    return InkWell(
      onTap: _pickBirthDate,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: InputDecorator(
        decoration:
            _inputDecoration('Date de naissance', Icons.cake_rounded).copyWith(
              suffixIcon: hasDate
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: 'Effacer la date',
                      onPressed: () => setState(() => _birthDate = null),
                    )
                  : const Icon(Icons.calendar_month_rounded, size: 20),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                color: hasDate
                    ? context.colors.onSurface
                    : context.colors.onSurfaceVariant,
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: 2),
              Text(
                '${preview.ageLabel()} · ${preview.yearClass()}',
                style: context.texts.labelMedium?.copyWith(
                  color: context.colors.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Généalogie ---

  /// Un seul flux Firestore alimente les deux sélecteurs : la liste des koï du
  /// bassin est la même pour le père et pour la mère.
  Widget _buildParentSelectors(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kois')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Un koï ne peut pas être son propre parent.
        final candidates = (snapshot.data?.docs ?? const <QueryDocumentSnapshot>[])
            .where((doc) => doc.id != widget.existing?.id)
            .toList();

        return Column(
          children: [
            _buildParentSelector(
              label: 'Père',
              icon: Icons.male_rounded,
              candidates: candidates,
              mode: _fatherMode,
              selectedId: _selectedFatherId,
              manualController: _fatherManualController,
              manualLabel: 'Nom / variété du père',
              onModeChanged: (mode, id) => setState(() {
                _fatherMode = mode;
                _selectedFatherId = id;
              }),
            ),
            const SizedBox(height: 16),
            _buildParentSelector(
              label: 'Mère',
              icon: Icons.female_rounded,
              candidates: candidates,
              mode: _motherMode,
              selectedId: _selectedMotherId,
              manualController: _motherManualController,
              manualLabel: 'Nom / variété de la mère',
              onModeChanged: (mode, id) => setState(() {
                _motherMode = mode;
                _selectedMotherId = id;
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildParentSelector({
    required String label,
    required IconData icon,
    required List<QueryDocumentSnapshot> candidates,
    required _ParentMode mode,
    required String? selectedId,
    required TextEditingController manualController,
    required String manualLabel,
    required void Function(_ParentMode mode, String? id) onModeChanged,
  }) {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'none', child: Text('Non renseigné')),
      const DropdownMenuItem(
        value: 'manual',
        child: Row(
          children: [
            Icon(Icons.edit_note_rounded, size: 18),
            SizedBox(width: 8),
            Text('Saisie manuelle / autre origine'),
          ],
        ),
      ),
      for (final doc in candidates)
        DropdownMenuItem(
          value: doc.id,
          child: Row(
            children: [
              const KoiEmblem(size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (doc.data() as Map<String, dynamic>)['name'] as String? ??
                      'Sans nom',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
    ];

    // Le parent choisi doit figurer parmi les propositions, sans quoi le menu
    // déroulant lève une assertion. Le cas se produit tant que la liste
    // charge, et pour un parent supprimé depuis.
    final availableIds = candidates.map((doc) => doc.id).toSet();
    final currentValue = switch (mode) {
      _ParentMode.manual => 'manual',
      _ParentMode.linked when availableIds.contains(selectedId) => selectedId!,
      _ => 'none',
    };

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: currentValue,
          isExpanded: true,
          decoration: _inputDecoration(label, icon),
          items: items,
          onChanged: (value) {
            if (value == 'manual') {
              onModeChanged(_ParentMode.manual, null);
            } else if (value == 'none' || value == null) {
              onModeChanged(_ParentMode.none, null);
            } else {
              onModeChanged(_ParentMode.linked, value);
            }
          },
        ),
        if (mode == _ParentMode.manual) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: manualController,
            decoration: _inputDecoration(manualLabel, Icons.edit_note_rounded),
          ),
        ],
      ],
    );
  }

  // --- Style ---

  /// Le style des champs vient du thème : il ne reste ici que ce qui change
  /// d'un champ à l'autre.
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20));
  }
}
