import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
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
                label: context.l10n.koiVariety,
                value: koi.variety.isEmpty ? "—" : koi.variety,
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.cake_rounded,
                label: context.l10n.koiAge,
                value: koi.ageLabel(context.l10n),
              ),
              const VerticalRule(),
              InfoTile(
                icon: Icons.wc_rounded,
                label: context.l10n.koiFormSex,
                value: koi.sex.label(context.l10n),
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
                              ? context.l10n.koiBirthDateMissing
                              : context.l10n.koiBornOn(
                                  DateFormat.yMMMMd(
                                    context.localeName,
                                  ).format(birthDate),
                                ),
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
                                    ? context.l10n.koiAgeApprox
                                    : context.l10n.tapToAdd)
                              : context.l10n.koiYearClass(
                                  koi.yearClass(context.l10n) ?? '',
                                ),
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
      helpText: context.l10n.koiBirthDateOf(koi.name),
      cancelText: context.l10n.commonCancel,
      confirmText: context.l10n.commonSave,
    );

    if (picked == null) return;

    try {
      await KoiService.setBirthDate(koi.id, picked);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.koiBirthDateError(e))),
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
              label: context.l10n.koiBreeder,
              value: koi.breeder!,
            ),
          if (koi.breeder != null && koi.origin != null)
            const SizedBox(height: AppSpacing.md),
          if (koi.origin != null)
            LabelledRow(
              icon: Icons.place_rounded,
              label: context.l10n.koiSectionOrigin,
              value: koi.origin!,
            ),
        ],
      ),
    );
  }
}
