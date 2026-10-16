import 'package:flutter/material.dart';
import '../../../l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../models/koi.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';

/// Père et mère, liés à une fiche ou saisis à la main.
class KoiGenealogyCard extends StatelessWidget {
  final Koi koi;

  const KoiGenealogyCard({super.key, required this.koi});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _ParentBox(
              label: context.l10n.koiFather.toUpperCase(),
              parentId: koi.fatherId,
              manualName: koi.fatherNameManual,
              icon: Icons.male_rounded,
              accent: context.colors.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ParentBox(
              label: context.l10n.koiMother.toUpperCase(),
              parentId: koi.motherId,
              manualName: koi.motherNameManual,
              icon: Icons.female_rounded,
              accent: context.colors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentBox extends StatelessWidget {
  final String label;
  final String? parentId;
  final String? manualName;
  final IconData icon;
  final Color accent;

  const _ParentBox({
    required this.label,
    required this.parentId,
    required this.manualName,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final id = parentId;
    if (id == null) {
      final manual = manualName;
      if (manual != null && manual.trim().isNotEmpty) {
        return _ParentCard(
          role: label,
          name: manual,
          sub: context.l10n.parentManualShort,
          icon: icon,
          accent: accent,
        );
      }
      return _ParentCard(
        role: label,
        name: context.l10n.parentNotSet,
        sub: context.l10n.parentUnknown,
        icon: icon,
        accent: accent,
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('kois').doc(id).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ParentCard(
            role: label,
            name: "…",
            sub: context.l10n.loading,
            icon: icon,
            accent: accent,
          );
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          final parent = Koi.fromFirestore(snapshot.data!);
          return _ParentCard(
            role: label,
            name: parent.name,
            sub: parent.variety.isEmpty
                ? context.l10n.varietyUnknown
                : parent.variety,
            icon: icon,
            accent: accent,
            onTap: () => context.push('/koi/${parent.id}', extra: parent),
          );
        }
        // Un parent supprimé depuis : on garde la trace qu'il a existé.
        return _ParentCard(
          role: label,
          name: context.l10n.parentUnknown,
          sub: context.l10n.parentNotFound,
          icon: icon,
          accent: accent,
        );
      },
    );
  }
}

class _ParentCard extends StatelessWidget {
  final String role;
  final String name;
  final String sub;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const _ParentCard({
    required this.role,
    required this.name,
    required this.sub,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.field),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role, style: context.texts.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: context.texts.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sub,
                    style: context.texts.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
