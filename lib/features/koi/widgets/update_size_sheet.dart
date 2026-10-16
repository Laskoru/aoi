import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import '../../../services/koi_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../services/pending_write.dart';

/// Feuille de saisie d'une nouvelle mesure de taille.
///
/// C'est un widget à part entière pour que son [TextEditingController] soit
/// créé et libéré avec elle.
class UpdateSizeSheet extends StatefulWidget {
  final String koiId;
  final double currentSize;

  const UpdateSizeSheet({
    super.key,
    required this.koiId,
    required this.currentSize,
  });

  @override
  State<UpdateSizeSheet> createState() => _UpdateSizeSheetState();
}

class _UpdateSizeSheetState extends State<UpdateSizeSheet> {
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentSize > 0 ? widget.currentSize.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newSize = double.tryParse(_controller.text.trim().replaceAll(',', '.'));

    if (newSize == null || !newSize.isFinite || newSize <= 0 || newSize > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sizeInvalidCm)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final confirmed = await KoiService.recordSize(
        widget.koiId,
        newSize,
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
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saveImpossible(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.colors.outline,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          Text(context.l10n.koiUpdateSize, style: context.texts.headlineMedium),
          const SizedBox(height: 6),
          Text(
            context.l10n.koiUpdateSizeHint,
            style: context.texts.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            onSubmitted: (_) => _isSaving ? null : _save(),
            decoration: InputDecoration(
              labelText: context.l10n.koiNewSize,
              suffixText: "cm",
              prefixIcon: const Icon(Icons.straighten_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(context.l10n.koiConfirmMeasure),
            ),
          ),
        ],
      ),
    );
  }
}
