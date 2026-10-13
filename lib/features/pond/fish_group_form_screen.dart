import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/fish_group.dart';
import '../../services/fish_group_service.dart';
import '../../services/photo_store.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';
import '../../widgets/photo_image.dart';
import '../../widgets/form_body.dart';

/// Formulaire d'un groupe de poissons, en création comme en modification.
class FishGroupFormScreen extends StatefulWidget {
  final FishGroup? existing;

  const FishGroupFormScreen({super.key, this.existing});

  @override
  State<FishGroupFormScreen> createState() => _FishGroupFormScreenState();
}

class _FishGroupFormScreenState extends State<FishGroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _species = TextEditingController();
  final _count = TextEditingController(text: '1');
  final _notes = TextEditingController();
  DateTime? _introducedAt;
  bool _saving = false;

  /// Photo choisie dans ce formulaire, envoyée à l'enregistrement.
  Uint8List? _photo;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    if (g == null) return;
    _species.text = g.species;
    _count.text = g.count.toString();
    _notes.text = g.notes ?? '';
    _introducedAt = g.introducedAt;
  }

  @override
  void dispose() {
    _species.dispose();
    _count.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _introducedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: "Date d'introduction",
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked != null && mounted) setState(() => _introducedAt = picked);
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Sans les métadonnées, dont l'appli n'a pas l'usage : iOS n'a alors pas
      // à demander l'accès à toute la photothèque.
      requestFullMetadata: false,
      maxWidth: PhotoStore.maxSide.toDouble(),
      maxHeight: PhotoStore.maxSide.toDouble(),
      imageQuality: PhotoStore.pickQuality,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (mounted) setState(() => _photo = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validateAndReveal()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('Session expirée, reconnectez-vous.');
      return;
    }

    setState(() => _saving = true);
    try {
      final notes = _notes.text.trim();
      final group = FishGroup(
        id: widget.existing?.id ?? '',
        userId: user.uid,
        pondId: widget.existing?.pondId,
        species: _species.text.trim(),
        count: int.tryParse(_count.text.trim()) ?? 1,
        introducedAt: _introducedAt,
        imageUrl: widget.existing?.imageUrl,
        notes: notes.isEmpty ? null : notes,
      );

      final photo = _photo;
      final existing = widget.existing;
      final Future<Object?> write = existing == null
          ? FishGroupService.create(group, photo: photo)
          : Future.wait([
              FishGroupService.update(group),
              if (photo != null) FishGroupService.setPhoto(existing, photo),
            ]);
      // Une photo pèse plusieurs centaines de kilo-octets : plus de patience.
      final confirmed = await write.confirmedWithin(
        Duration(seconds: photo == null ? 5 : 20),
      );
      if (mounted) {
        _snack(
          !confirmed
              ? pendingWriteMessage
              : _isEditing
              ? 'Groupe mis à jour.'
              : 'Groupe ajouté.',
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
    final group = widget.existing;
    if (group == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${group.species} ?'),
        content: const Text("Le groupe et sa photo seront effacés."),
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
      final confirmed = await FishGroupService.delete(group).confirmedWithin();
      if (mounted) {
        _snack(confirmed ? 'Groupe supprimé.' : pendingWriteMessage);
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
          _isEditing ? 'Modifier le groupe' : 'Ajouter des poissons',
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
              tooltip: 'Supprimer ce groupe',
              onPressed: _saving ? null : _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: FormBody(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Center(
              child: _GroupPhotoPicker(
                picked: _photo,
                imageUrl: widget.existing?.imageUrl,
                onTap: _saving ? null : _pickPhoto,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionLabel("Espèce"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _species,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Espèce (ex : Ide mélanote, Esturgeon)',
                prefixIcon: Icon(Icons.groups_rounded, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Veuillez entrer l'espèce"
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _count,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Effectif',
                prefixIcon: Icon(Icons.numbers_rounded, size: 20),
              ),
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n < 1) return 'Au moins 1';
                if (n > 10000) return 'Valeur irréaliste';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Introduction"),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.field),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: "Date d'introduction",
                  prefixIcon: const Icon(Icons.event_rounded, size: 20),
                  suffixIcon: _introducedAt != null
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          tooltip: 'Effacer la date',
                          onPressed: () => setState(() => _introducedAt = null),
                        )
                      : const Icon(Icons.calendar_month_rounded, size: 20),
                ),
                child: Text(
                  _introducedAt == null
                      ? 'Non renseignée'
                      : DateFormat('d MMMM yyyy', 'fr_FR').format(_introducedAt!),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _introducedAt == null
                        ? FontWeight.normal
                        : FontWeight.w600,
                    color: _introducedAt == null
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
                labelText: 'Origine, comportement, pertes…',
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
                            : 'Ajouter le groupe',
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

/// Photo du groupe, à toucher pour en choisir une : la nouvelle si elle
/// vient d'être choisie, sinon celle du groupe, sinon l'icône des poissons.
class _GroupPhotoPicker extends StatelessWidget {
  final Uint8List? picked;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _GroupPhotoPicker({
    required this.picked,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ImageProvider? image = picked != null
        ? MemoryImage(picked!)
        : imageUrl != null
        ? photoImage(imageUrl!, width: 360)
        : null;
    final hasPhoto = image != null;

    return Semantics(
      button: true,
      label: hasPhoto ? "Changer la photo du groupe" : "Ajouter une photo du groupe",
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: image,
                  child: hasPhoto
                      ? null
                      : Icon(
                          Icons.groups_rounded,
                          size: 40,
                          color: colors.onPrimaryContainer,
                        ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppPalette.hi,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasPhoto ? "Changer la photo" : "Ajouter une photo",
              style: context.texts.labelLarge?.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
