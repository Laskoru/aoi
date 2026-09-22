import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../models/plant.dart';
import '../../services/plant_service.dart';
import '../../theme/app_palette.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_widgets.dart';

/// Les plantes du bassin, regroupées par zone de plantation, de la berge
/// vers le fond : c'est ainsi qu'on parcourt un bassin du regard.
class PlantListScreen extends StatelessWidget {
  const PlantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Session expirée")));
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text("Plantes", style: context.texts.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, size: 28),
                color: context.colors.secondary,
                tooltip: "Ajouter une plante",
                onPressed: () => context.push('/plantes/new'),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          StreamBuilder<List<Plant>>(
            stream: PlantService.watchAll(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: ErrorState(error: snapshot.error),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final plants = snapshot.data ?? const <Plant>[];
              if (plants.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.grass_rounded,
                      title: "Aucune plante",
                      message:
                          "Nénuphars, iris, oxygénantes… Notez ce que vous plantez, où, et quand.",
                      actionLabel: "Ajouter une plante",
                      onAction: () => context.push('/plantes/new'),
                    ),
                  ),
                );
              }

              final byZone = <PlantZone, List<Plant>>{};
              for (final plant in plants) {
                byZone.putIfAbsent(plant.zone, () => []).add(plant);
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  100,
                ),
                sliver: SliverList.list(
                  children: [
                    for (final zone in PlantZone.values)
                      if (byZone[zone]?.isNotEmpty ?? false) ...[
                        _ZoneHeader(zone: zone, count: byZone[zone]!.length),
                        const SizedBox(height: AppSpacing.md),
                        for (final plant in byZone[zone]!) ...[
                          _PlantTile(plant: plant),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ZoneHeader extends StatelessWidget {
  final PlantZone zone;
  final int count;

  const _ZoneHeader({required this.zone, required this.count});

  @override
  Widget build(BuildContext context) {
    return SectionHeader(
      title: zone.label,
      icon: _zoneIcon(zone),
      trailing: StatusPill(
        label: "$count",
        color: context.colors.primary,
        background: context.colors.primaryContainer,
      ),
    );
  }
}

IconData _zoneIcon(PlantZone zone) => switch (zone) {
  PlantZone.berge => Icons.landscape_rounded,
  PlantZone.marecage => Icons.grass_rounded,
  PlantZone.immergee => Icons.water_rounded,
  PlantZone.profonde => Icons.spa_rounded,
};

class _PlantTile extends StatelessWidget {
  final Plant plant;

  const _PlantTile({required this.plant});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/plantes/${plant.id}', extra: plant),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: plant.imageUrl != null
                ? Image.network(
                    plant.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.grass_rounded,
                      color: colors.onPrimaryContainer,
                    ),
                  )
                : Icon(Icons.grass_rounded, color: colors.onPrimaryContainer),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.name,
                  style: context.texts.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (plant.species != null)
                  Text(
                    plant.species!,
                    style: context.texts.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    StatusPill(
                      label: "× ${plant.quantity}",
                      color: colors.onSurfaceVariant,
                      background: colors.surfaceContainerHigh,
                    ),
                    if (plant.isFloating)
                      StatusPill(
                        label: "FLOTTANTE",
                        color: colors.tertiary,
                        background: colors.primaryContainer,
                      ),
                    if (plant.isOxygenating)
                      StatusPill(
                        label: "OXYGÉNANTE",
                        color: context.pond.ideal,
                        background: context.pond.idealSurface,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
