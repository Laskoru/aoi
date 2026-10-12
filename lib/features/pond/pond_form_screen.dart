import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pond.dart';
import '../../services/pond_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';

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

  @override
  void initState() {
    super.initState();
    final p = widget.pond;
    _name = TextEditingController(text: p.name);
    _volume = TextEditingController(
      text: p.volumeLiters?.toStringAsFixed(0) ?? '',
    );
    _depth = TextEditingController(text: p.depthCm?.toStringAsFixed(0) ?? '');
    _notes = TextEditingController(text: p.notes ?? '');
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
    if (!_formKey.currentState!.validate()) return;
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
            const SnackBar(content: Text(pendingWriteMessage)),
          );
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Enregistrement impossible : $e")));
      }
    }
  }

  String? _optionalRange(String? v, double max) {
    if (v == null || v.trim().isEmpty) return null;
    final parsed = _parse(v);
    if (parsed == null || !parsed.isFinite || parsed < 0) return 'Valeur invalide';
    if (parsed > max) return 'Valeur irréaliste';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mon bassin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                labelText: 'Nom du bassin',
                prefixIcon: Icon(Icons.water_rounded, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Veuillez entrer un nom'
                  : null,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Dimensions"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _volume,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Volume (L)',
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
                    decoration: const InputDecoration(
                      labelText: 'Profondeur (cm)',
                      prefixIcon: Icon(Icons.height_rounded, size: 20),
                    ),
                    validator: (v) => _optionalRange(v, 1000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionLabel("Notes"),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLength: 2000,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Filtration, exposition, historique…',
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
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
