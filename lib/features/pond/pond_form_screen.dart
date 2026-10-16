import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:flutter/services.dart';
import '../../models/pond.dart';
import '../../services/pond_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';
import '../../widgets/form_body.dart';

/// Nom, volume et profondeur du bassin.
class PondFormScreen extends StatefulWidget {
  final Pond pond;

  const PondFormScreen({super.key, required this.pond});

  @override
  State<PondFormScreen> createState() => _PondFormScreenState();
}

class _PondFormScreenState extends State<PondFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _volume;
  late final TextEditingController _depth;
  late final TextEditingController _notes;
  bool _saving = false;
  bool _nameReady = false;

  @override
  void initState() {
    super.initState();
    final p = widget.pond;
    _name = TextEditingController();
    _volume = TextEditingController(
      text: p.volumeLiters?.toStringAsFixed(0) ?? '',
    );
    _depth = TextEditingController(text: p.depthCm?.toStringAsFixed(0) ?? '');
    _notes = TextEditingController(text: p.notes ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Le nom par défaut s'écrit dans la langue de l'interface, connue
    // seulement une fois l'écran inséré : on le pose une seule fois.
    if (!_nameReady) {
      _name.text = widget.pond.displayName(context.l10n);
      _nameReady = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _volume.dispose();
    _depth.dispose();
    _notes.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    final t = text.trim().replaceAll(',', '.');
    return t.isEmpty ? null : double.tryParse(t);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validateAndReveal()) return;
    setState(() => _saving = true);
    try {
      final confirmed = await PondService.update(
        Pond(
          id: widget.pond.id,
          userId: widget.pond.userId,
          name: _name.text.trim(),
          volumeLiters: _parse(_volume.text),
          depthCm: _parse(_depth.text),
          imageUrl: widget.pond.imageUrl,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          createdAt: widget.pond.createdAt,
        ),
      ).confirmedWithin();
      if (mounted) {
        if (!confirmed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.pendingWrite)),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveImpossible(e))));
      }
    }
  }

  String? _optionalRange(String? v, double max) {
    if (v == null || v.trim().isEmpty) return null;
    final parsed = _parse(v);
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return context.l10n.formInvalidValue;
    }
    if (parsed > max) return context.l10n.formUnrealistic;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.pondDefaultName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: FormBody(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SectionLabel(context.l10n.koiSectionIdentity),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              inputFormatters: [LengthLimitingTextInputFormatter(80)],
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: context.l10n.pondFormName,
                prefixIcon: Icon(Icons.water_rounded, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.l10n.formNameRequired
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionLabel(context.l10n.pondSectionDimensions),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _volume,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.pondFormVolume,
                      prefixIcon: Icon(Icons.local_drink_rounded, size: 20),
                    ),
                    validator: (v) => _optionalRange(v, 1000000),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _depth,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.pondFormDepth,
                      prefixIcon: Icon(Icons.height_rounded, size: 20),
                    ),
                    validator: (v) => _optionalRange(v, 1000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionLabel(context.l10n.koiFormSectionNotes),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLength: 2000,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.l10n.pondFormNotesHint,
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
                    : Text(context.l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
