import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/water_measurement.dart';
import '../theme/app_palette.dart';
import '../theme/app_theme.dart';
import '../theme/app_widgets.dart';
import '../theme/pond_status.dart';
import '../utils/water_logic.dart';

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
        title: const Text(
          'Historique des mesures',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: context.colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Session expirée"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('measurements')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('timestamp', descending: true)
                  .limit(200)
                  .snapshots(),
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

                final docs = snapshot.data?.docs ?? const [];
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: EmptyState(
                      icon: Icons.science_rounded,
                      title: "Aucun relevé",
                      message:
                          "Les mesures que vous enregistrez apparaîtront ici.",
                      actionLabel: "Ajouter une mesure",
                      onAction: () => context.push('/eau/nouvelle'),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) => _MeasurementTile(
                    measurement: WaterMeasurement.fromFirestore(docs[index]),
                  ),
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
        title: const Text('Supprimer ce relevé ?'),
        content: const Text(
          "Il disparaîtra de l'historique et des courbes. Cette action est "
          "définitive.",
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

    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection('measurements')
          .doc(measurement.id)
          .delete();
      messenger.showSnackBar(const SnackBar(content: Text('Relevé supprimé.')));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Suppression impossible : $e')),
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
                      ? "Date inconnue"
                      : DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date),
                  style: context.texts.labelLarge,
                ),
              ),
              StatusPill(
                label: condition.label,
                color: condition.color(context),
                background: condition.surface(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: context.colors.onSurfaceVariant,
                tooltip: 'Supprimer ce relevé',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          if (date != null)
            Padding(
              padding: const EdgeInsets.only(left: 26, bottom: AppSpacing.sm),
              child: Text(
                DateFormat('HH:mm', 'fr_FR').format(date),
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
              text: "${reading.parameter.label} ",
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
