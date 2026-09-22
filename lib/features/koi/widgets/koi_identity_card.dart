import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/koi.dart';
import '../../../services/koi_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';

/// Variété, âge, sexe, et la ligne de naissance.
class KoiIdentityCard extends StatelessWidget {
  final Koi koi;

  const KoiIdentityCard({super.key, required this.koi});

  @override
  Widget build(BuildContext context) {
    final birthDate = koi.birthDate;
    final colors = context.colors;

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoTile(
                icon: Icons.color_lens_rounded,
                label: "Variété",
                value: koi.variety.isEmpty ? "—" : koi.variety,
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.cake_rounded,
                label: "Âge",
                value: koi.ageLabel(),
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.wc_rounded,
                label: "Sexe",
                value: koi.sex.label,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),

          // Ligne de naissance : c'est aussi le point d'entrée pour compléter
          // une fiche ancienne, qui n'a qu'un âge figé.
          InkWell(
            onTap: () => _pickBirthDate(context),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 18,
                    color: birthDate == null
                        ? context.pond.warning
                        : colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          birthDate == null
                              ? "Date de naissance à renseigner"
                              : "Né le ${DateFormat('d MMMM yyyy', 'fr_FR').format(birthDate)}",
                          style: context.texts.labelLarge?.copyWith(
                            color: birthDate == null
                                ? context.pond.warning
                                : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          birthDate == null
                              ? (koi.legacyAge != null
                                    ? "Âge approximatif repris de l'ancienne fiche"
                                    : "Appuyez pour l'ajouter")
                              : "Classe d'âge : ${koi.yearClass()}",
                          style: context.texts.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ouvre le calendrier pour renseigner ou corriger la naissance. Pour une
  /// fiche ancienne, on le pré-positionne sur l'année déduite de l'âge saisi
  /// à l'époque, ce qui évite de faire défiler trente ans.
  Future<void> _pickBirthDate(BuildContext context) async {
    final now = DateTime.now();

    final DateTime initial;
    if (koi.birthDate != null) {
      initial = koi.birthDate!;
    } else if (koi.legacyAge != null && koi.legacyAge! > 0) {
      initial = DateTime(now.year - koi.legacyAge!, 1, 1);
    } else {
      initial = DateTime(now.year - 1, now.month, now.day);
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Date de naissance de ${koi.name}',
      cancelText: 'Annuler',
      confirmText: 'Enregistrer',
    );

    if (picked == null) return;

    try {
      await KoiService.setBirthDate(koi.id, picked);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Impossible d'enregistrer la date : $e")),
        );
      }
    }
  }
}

/// Éleveur et provenance, quand ils sont renseignés.
class KoiOriginCard extends StatelessWidget {
  final Koi koi;

  const KoiOriginCard({super.key, required this.koi});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (koi.breeder != null)
            LabelledRow(
              icon: Icons.storefront_rounded,
              label: "Éleveur",
              value: koi.breeder!,
            ),
          if (koi.breeder != null && koi.origin != null)
            const SizedBox(height: AppSpacing.md),
          if (koi.origin != null)
            LabelledRow(
              icon: Icons.place_rounded,
              label: "Provenance",
              value: koi.origin!,
            ),
        ],
      ),
    );
  }
}
