import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/koi.dart';
import '../../services/koi_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';
import '../../widgets/form_body.dart';
import '../../l10n/l10n.dart';

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
      helpText: context.l10n.koiFormBirthDateHelp,
      cancelText: context.l10n.commonCancel,
      confirmText: context.l10n.commonConfirm,
      fieldLabelText: context.l10n.koiFormBirthDate,
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
    if (!_formKey.currentState!.validateAndReveal()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack(context.l10n.sessionExpiredSignIn);
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

      final confirmed = await (_isEditing
              ? KoiService.update(koi, previousSize: widget.existing!.size)
              : KoiService.create(koi))
          .confirmedWithin();

      if (mounted) {
        _showSnack(
          !confirmed
              ? context.l10n.pendingWrite
              : _isEditing
              ? context.l10n.koiUpdated
              : context.l10n.koiAdded,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack(context.l10n.saveError(e));
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
        title: Text(context.l10n.koiDeleteTitle(koi.name)),
        content: Text(context.l10n.koiDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.pond.danger),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await KoiService.delete(koi);
      if (mounted) {
        _showSnack(context.l10n.koiDeleted(koi.name));
        // Deux retours : on quitte le formulaire, puis la fiche détail qui
        // n'a plus de document à afficher.
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(context.l10n.deleteError(e));
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
          _isEditing ? context.l10n.koiFormTitleEdit : context.l10n.koiFormTitleAdd,
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
              tooltip: context.l10n.koiDeleteTooltip,
              onPressed: _isLoading ? null : _confirmDelete,
            ),
        ],
      ),
      body: user == null
          ? Center(child: Text(context.l10n.sessionExpired))
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: FormBody(
                  children: [
                    SectionLabel(context.l10n.koiFormSectionBasics),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      inputFormatters: [LengthLimitingTextInputFormatter(80)],
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        context.l10n.koiFormName,
                        Icons.badge_rounded,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? context.l10n.formNameRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _varietyController,
                      inputFormatters: [LengthLimitingTextInputFormatter(80)],
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        context.l10n.koiFormVariety,
                        Icons.color_lens_rounded,
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? context.l10n.koiFormVarietyRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sizeController,
                      decoration: _inputDecoration(
                        context.l10n.koiFormSize,
                        Icons.straighten_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.formRequired;
                        }
                        final parsed = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        );
                        if (parsed == null || !parsed.isFinite || parsed <= 0) {
                          return context.l10n.koiFormSizeInvalid;
                        }
                        if (parsed > 200) {
                          return context.l10n.koiFormSizeUnrealistic;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    SectionLabel(context.l10n.koiFormSectionIdentity),
                    const SizedBox(height: 12),
                    _buildBirthDateField(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<KoiSex>(
                      initialValue: _sex,
                      decoration: _inputDecoration(
                        context.l10n.koiFormSex,
                        Icons.wc_rounded,
                      ),
                      items: KoiSex.values
                          .map(
                            (s) =>
                                DropdownMenuItem(
                              value: s,
                              child: Text(s.label(context.l10n)),
                            ),
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
                        context.l10n.koiFormStatus,
                        Icons.favorite_rounded,
                      ),
                      items: KoiStatus.values
                          .map(
                            (s) =>
                                DropdownMenuItem(
                              value: s,
                              child: Text(s.label(context.l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breederController,
                      inputFormatters: [LengthLimitingTextInputFormatter(80)],
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        context.l10n.koiFormBreeder,
                        Icons.storefront_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _originController,
                      inputFormatters: [LengthLimitingTextInputFormatter(80)],
                      decoration: _inputDecoration(
                        context.l10n.koiFormOrigin,
                        Icons.place_rounded,
                      ),
                    ),

                    const SizedBox(height: 32),
                    SectionLabel(context.l10n.koiFormSectionLineage),
                    const SizedBox(height: 12),
                    _buildParentSelectors(user.uid),

                    const SizedBox(height: 32),
                    SectionLabel(context.l10n.koiFormSectionNotes),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLength: 2000,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        context.l10n.koiFormNotesHint,
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
                                    ? context.l10n.formSaveChanges
                                    : context.l10n.koiFormSave,
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
        ? DateFormat.yMMMMd(context.localeName).format(_birthDate!)
        : context.l10n.dateNotSet;

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
            _inputDecoration(
              context.l10n.koiFormBirthDate,
              Icons.cake_rounded,
            ).copyWith(
              suffixIcon: hasDate
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      tooltip: context.l10n.koiFormClearDate,
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
                '${preview.ageLabel(context.l10n)} · '
                '${preview.yearClass(context.l10n)}',
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
              label: context.l10n.koiFather,
              icon: Icons.male_rounded,
              candidates: candidates,
              mode: _fatherMode,
              selectedId: _selectedFatherId,
              manualController: _fatherManualController,
              manualLabel: context.l10n.koiFatherManual,
              onModeChanged: (mode, id) => setState(() {
                _fatherMode = mode;
                _selectedFatherId = id;
              }),
            ),
            const SizedBox(height: 16),
            _buildParentSelector(
              label: context.l10n.koiMother,
              icon: Icons.female_rounded,
              candidates: candidates,
              mode: _motherMode,
              selectedId: _selectedMotherId,
              manualController: _motherManualController,
              manualLabel: context.l10n.koiMotherManual,
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
      DropdownMenuItem(value: 'none', child: Text(context.l10n.parentNotSet)),
      DropdownMenuItem(
        value: 'manual',
        child: Row(
          children: [
            const Icon(Icons.edit_note_rounded, size: 18),
            const SizedBox(width: 8),
            Text(context.l10n.parentManual),
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
                      context.l10n.koiUnnamed,
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
            inputFormatters: [LengthLimitingTextInputFormatter(80)],
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
