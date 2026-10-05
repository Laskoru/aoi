import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/plant.dart';
import '../../services/plant_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';

/// Formulaire d'une plante, en création comme en modification.
class PlantFormScreen extends StatefulWidget {
  final Plant? existing;

  const PlantFormScreen({super.key, this.existing});

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _species = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _notes = TextEditingController();

  PlantZone _zone = PlantZone.marecage;
  bool _isFloating = false;
  bool _isOxygenating = false;
  DateTime? _plantedAt;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p == null) return;
    _name.text = p.name;
    _species.text = p.species ?? '';
    _quantity.text = p.quantity.toString();
    _notes.text = p.notes ?? '';
    _zone = p.zone;
    _isFloating = p.isFloating;
    _isOxygenating = p.isOxygenating;
    _plantedAt = p.plantedAt;
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _quantity.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _trimmedOrNull(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Date de plantation',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null && mounted) setState(() => _plantedAt = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Session expirée, reconnectez-vous.');
      return;
    }

    setState(() => _saving = true);
    try {
      final plant = Plant(
        id: widget.existing?.id ?? '',
        userId: user.uid,
        pondId: widget.existing?.pondId,
        name: _name.text.trim(),
        species: _trimmedOrNull(_species),
        zone: _zone,
        isFloating: _isFloating,
        isOxygenating: _isOxygenating,
        quantity: int.tryParse(_quantity.text.trim()) ?? 1,
        plantedAt: _plantedAt,
        imageUrl: widget.existing?.imageUrl,
        notes: _trimmedOrNull(_notes),
      );

      final confirmed = await (_isEditing
              ? PlantService.update(plant)
              : PlantService.create(plant))
          .confirmedWithin();
      if (mounted) {
        _snack(
          !confirmed
              ? pendingWriteMessage
              : _isEditing
              ? 'Plante mise à jour.'
              : 'Plante ajoutée.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _snack('Erreur lors de la sauvegarde : $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final plant = widget.existing;
    if (plant == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${plant.name} ?'),
        content: const Text("La fiche et sa photo seront effacées."),
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

    setState(() => _saving = true);
    try {
      final confirmed = await PlantService.delete(plant).confirmedWithin();
      if (mounted) {
        _snack(confirmed ? '${plant.name} a été supprimée.' : pendingWriteMessage);
        // On quitte le formulaire, puis la fiche qui n'a plus rien à afficher.
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Suppression impossible : $e');
      }
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la plante' : 'Ajouter une plante',
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
              tooltip: 'Supprimer cette plante',
              onPressed: _saving ? null : _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const SectionLabel("Identité"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom (ex : Nénuphar rose)',
                prefixIcon: Icon(Icons.grass_rounded, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Veuillez entrer un nom'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _species,
              inputFormatters: [LengthLimitingTextInputFormatter(120)],
              decoration: const InputDecoration(
                labelText: 'Espèce ou variété (optionnel)',
                prefixIcon: Icon(Icons.science_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de pots ou de pieds',
                prefixIcon: Icon(Icons.numbers_rounded, size: 20),
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 1) return 'Au moins 1';
                if (n > 500) return 'Valeur irréaliste';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Zone de plantation"),
            const SizedBox(height: 12),
            _ZonePicker(
              selected: _zone,
              onChanged: (z) => setState(() => _zone = z),
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text("Flottante"),
              subtitle: Text(
                "Non enracinée : elle ombrage l'eau et abrite les alevins.",
                style: context.texts.bodyMedium,
              ),
              value: _isFloating,
              onChanged: (v) => setState(() => _isFloating = v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text("Oxygénante"),
              subtitle: Text(
                "Immergée : elle consomme les nitrates et produit l'oxygène.",
                style: context.texts.bodyMedium,
              ),
              value: _isOxygenating,
              onChanged: (v) => setState(() => _isOxygenating = v),
            ),

            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Plantation"),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.field),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date de plantation',
                  prefixIcon: const Icon(Icons.event_rounded, size: 20),
                  suffixIcon: _plantedAt != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          tooltip: 'Effacer la date',
                          onPressed: () => setState(() => _plantedAt = null),
                        )
                      : const Icon(Icons.calendar_month_rounded, size: 20),
                ),
                child: Text(
                  _plantedAt == null
                      ? 'Non renseignée'
                      : DateFormat('d MMMM yyyy', 'fr_FR').format(_plantedAt!),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _plantedAt == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                    color: _plantedAt == null
                        ? context.colors.onSurfaceVariant
                        : context.colors.onSurface,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Notes"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLength: 2000,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Division, engrais, hivernage…',
                prefixIcon: Icon(Icons.sticky_note_2_rounded, size: 20),
              ),
            ),

            const SizedBox(height: 40),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
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
                            : 'Ajouter la plante',
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Les quatre zones, présentées comme une coupe du bassin : de la berge au
/// fond, chaque marche indique la hauteur d'eau qu'elle tolère.
class _ZonePicker extends StatelessWidget {
  final PlantZone selected;
  final ValueChanged<PlantZone> onChanged;

  const _ZonePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        for (final zone in PlantZone.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Semantics(
              selected: zone == selected,
              button: true,
              child: InkWell(
                onTap: () => onChanged(zone),
                borderRadius: BorderRadius.circular(AppRadius.field),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: zone == selected
                        ? colors.primaryContainer
                        : colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.field),
                    border: Border.all(
                      color: zone == selected ? colors.primary : colors.outline,
                      width: zone == selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _DepthGauge(zone: zone, selected: zone == selected),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.maxDepthCm == 0
                                  ? zone.label
                                  : "${zone.label} · jusqu'à ${zone.maxDepthCm} cm",
                              style: context.texts.labelLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(zone.description, style: context.texts.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Une petite jauge d'eau, remplie à proportion de la profondeur de la zone.
class _DepthGauge extends StatelessWidget {
  final PlantZone zone;
  final bool selected;

  const _DepthGauge({required this.zone, required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = zone.maxDepthCm / PlantZone.profonde.maxDepthCm;

    return Container(
      width: 22,
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: fill == 0 ? 0.08 : fill,
          child: ColoredBox(
            color: selected ? colors.primary : colors.tertiary,
          ),
        ),
      ),
    );
  }
}
