import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/water_measurement.dart';
import '../../services/measurement_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../services/pending_write.dart';
import '../../widgets/form_body.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phController = TextEditingController();
  final _tempController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _nitriteController = TextEditingController();
  final _nitrateController = TextEditingController();
  final _khController = TextEditingController();
  final _ghController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phController.dispose();
    _tempController.dispose();
    _ammoniaController.dispose();
    _nitriteController.dispose();
    _nitrateController.dispose();
    _khController.dispose();
    _ghController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    return text.isEmpty ? null : double.tryParse(text);
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validateAndReveal()) return;

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack(context.l10n.sessionExpiredSignIn);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final confirmed = await MeasurementService.create(
        WaterMeasurement(
          id: '',
          userId: user.uid,
          ph: _parse(_phController) ?? 7.0,
          temperature: _parse(_tempController) ?? 0.0,
          ammonia: _parse(_ammoniaController),
          nitrite: _parse(_nitriteController),
          nitrate: _parse(_nitrateController),
          kh: _parse(_khController),
          gh: _parse(_ghController),
        ),
      ).confirmedWithin();

      if (mounted) {
        _showSnack(
          confirmed ? context.l10n.readingSaved : context.l10n.pendingWrite,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack(context.l10n.errorDetail(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Validateur des champs obligatoires, borné pour attraper les fautes de
  /// frappe (un pH de 72, une eau à 300 °C).
  String? _requiredRange(String? value, double min, double max) {
    if (value == null || value.trim().isEmpty) return context.l10n.formRequired;
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    // « NaN » collé dans le champ se lit comme un nombre, que les règles
    // refuseraient : l'erreur doit venir d'ici.
    if (parsed == null || !parsed.isFinite) return context.l10n.formInvalidValue;
    if (parsed < min || parsed > max) return context.l10n.formBetween(min, max);
    return null;
  }

  /// Même chose, mais le champ peut rester vide.
  String? _optionalRange(String? value, double min, double max) {
    if (value == null || value.trim().isEmpty) return null;
    return _requiredRange(value, min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.pondNewReading,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // Les écrans de saisie gardent le fond de l'application : seule la
        // fiche détail porte une barre colorée, parce qu'elle se pose sur son
        // en-tête en dégradé.
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: FormBody(
            children: [
              SectionLabel(context.l10n.readingSectionMain),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phController,
                decoration: _inputDecoration(
                  context.l10n.readingPhLabel,
                  Icons.science_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _requiredRange(v, 0, 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempController,
                decoration: _inputDecoration(
                  context.l10n.readingTempLabel,
                  Icons.device_thermostat_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (v) => _requiredRange(v, -10, 60),
              ),

              const SizedBox(height: 32),
              SectionLabel(context.l10n.readingSectionNitrogen),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ammoniaController,
                decoration: _inputDecoration(
                  context.l10n.readingAmmoniaLabel,
                  Icons.dangerous_rounded,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _optionalRange(v, 0, 20),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nitriteController,
                      decoration: _inputDecoration(
                        'NO₂ (mg/L)',
                        Icons.warning_amber_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _optionalRange(v, 0, 100),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _nitrateController,
                      decoration: _inputDecoration(
                        'NO₃ (mg/L)',
                        Icons.grass_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _optionalRange(v, 0, 500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SectionLabel(context.l10n.readingSectionHardness),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _khController,
                      decoration: _inputDecoration(
                        'KH (°d)',
                        Icons.shield_moon_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _optionalRange(v, 0, 30),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ghController,
                      decoration: _inputDecoration(
                        'GH (°d)',
                        Icons.opacity_rounded,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => _optionalRange(v, 0, 30),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMeasurement,
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.colors.onPrimary,
                          ),
                        )
                      : Text(context.l10n.readingSave),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Le style des champs vient du thème : il ne reste ici que ce qui change
  /// d'un champ à l'autre.
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20));
  }
}
