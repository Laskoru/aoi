import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/water_measurement.dart';
import '../../services/measurement_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';
import '../../theme/pond_status.dart';
import '../../utils/water_logic.dart';
import '../../services/pending_write.dart';

/// Historique complet des relevés d'eau.
///
/// Les graphiques du tableau de bord n'affichent que les sept derniers points,
/// choisis pour la lisibilité. Cet écran donne accès au reste, et permet
/// surtout de supprimer une mesure fautive : sans cela, une saisie erronée
/// déforme les courbes pour toujours.
class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.historyTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text(context.l10n.sessionExpired))
          : StreamBuilder<List<WaterMeasurement>>(
              stream: MeasurementService.history(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: ErrorState(error: snapshot.error),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? const <WaterMeasurement>[];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EmptyState(
                      icon: Icons.science_rounded,
                      title: context.l10n.historyEmptyTitle,
                      message: context.l10n.historyEmptyMessage,
                      actionLabel: context.l10n.readingAdd,
                      onAction: () => context.push('/eau/nouvelle'),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) =>
                      _MeasurementTile(measurement: items[index]),
                );
              },
            ),
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  final WaterMeasurement measurement;

  const _MeasurementTile({required this.measurement});

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.readingDeleteTitle),
        content: Text(context.l10n.readingDeleteBody),
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

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final confirmed = await MeasurementService.delete(
        measurement.id,
      ).confirmedWithin();
      messenger.showSnackBar(
        SnackBar(
          content: Text(confirmed ? l10n.readingDeleted : l10n.pendingWrite),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deleteError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final readings = measurement.readings;
    final condition = worstCondition(readings.map((r) => r.condition));
    final date = measurement.measuredAt;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(condition.icon, size: 18, color: condition.color(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date == null
                      ? context.l10n.dateUnknown
                      : DateFormat.yMMMMEEEEd(context.localeName).format(date),
                  style: context.texts.labelLarge,
                ),
              ),
              StatusPill(
                label: condition.label(context.l10n),
                color: condition.color(context),
                background: condition.surface(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: context.colors.onSurfaceVariant,
                tooltip: context.l10n.readingDeleteTooltip,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          if (date != null)
            Padding(
              padding: const EdgeInsets.only(left: 26, bottom: AppSpacing.sm),
              child: Text(
                DateFormat.jm(context.localeName).format(date),
                style: context.texts.labelMedium,
              ),
            ),
          const Divider(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final reading in readings) _ReadingChip(reading: reading),
            ],
          ),
        ],
      ),
    );
  }
}

/// Une valeur du relevé, teintée de l'état qu'elle traduit.
class _ReadingChip extends StatelessWidget {
  final WaterReading reading;

  const _ReadingChip({required this.reading});

  @override
  Widget build(BuildContext context) {
    final condition = reading.condition;
    final unit = reading.parameter.unit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: condition.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "${reading.parameter.label(context.l10n)} ",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.colors.onSurfaceVariant,
              ),
            ),
            TextSpan(
              text: "${reading.formattedValue}${unit.isEmpty ? '' : ' $unit'}",
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: condition.color(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
