import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/fish_group.dart';
import '../../../services/fish_group_service.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/app_widgets.dart';
import '../../../widgets/photo_image.dart';

/// Les autres habitants du bassin, par espèce et effectif.
class FishGroupsSection extends StatelessWidget {
  final String uid;

  const FishGroupsSection({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FishGroup>>(
      stream: FishGroupService.watchAll(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorState(error: snapshot.error);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final groups = snapshot.data ?? const <FishGroup>[];
        if (groups.isEmpty) {
          return EmptyState(
            icon: Icons.groups_rounded,
            title: "Aucun autre habitant",
            message:
                "Esturgeons, ides, carassins… Notez les espèces qui partagent le bassin avec vos koï.",
            actionLabel: "Ajouter des poissons",
            onAction: () => context.push('/bassin/poissons/new'),
          );
        }

        final total = groups.fold<int>(0, (sum, g) => sum + g.count);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final group in groups) ...[
              _GroupTile(group: group),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Text(
                  "$total poisson${total > 1 ? 's' : ''} en ${groups.length} groupe${groups.length > 1 ? 's' : ''}",
                  style: context.texts.labelMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text("Ajouter"),
                  onPressed: () => context.push('/bassin/poissons/new'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  final FishGroup group;

  const _GroupTile({required this.group});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final since = group.introducedAt;

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () =>
          context.push('/bassin/poissons/${group.id}/edit', extra: group),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: group.imageUrl != null
                ? Image(
                    image: photoImage(group.imageUrl!, width: 200),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.groups_rounded, color: colors.onPrimaryContainer),
                  )
                : Icon(Icons.groups_rounded, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.species,
                  style: context.texts.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  since == null
                      ? "Date d'introduction inconnue"
                      : "Depuis ${DateFormat('MMMM yyyy', 'fr_FR').format(since)}",
                  style: context.texts.bodyMedium,
                ),
              ],
            ),
          ),
          StatusPill(
            label: "× ${group.count}",
            color: colors.primary,
            background: colors.primaryContainer,
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
