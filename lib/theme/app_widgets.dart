import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_theme.dart';

/// Surface surélevée standard : c'est la brique de base de toute l'interface.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: context.isDark ? 0.30 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: card,
    );
  }
}

/// Titre de rubrique avec sa pastille d'icône, et une action facultative
/// alignée à droite.
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Icon(icon, size: 18, color: colors.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  style: context.texts.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Intitulé discret pour les sous-parties d'un formulaire ou d'une fiche.
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: context.texts.labelSmall?.copyWith(
          color: context.colors.secondary,
        ),
      ),
    );
  }
}

/// Pastille colorée : statut de l'eau, devenir du poisson, mesure clé.
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Écran vide : une icône, un titre, une explication, et de quoi agir.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: context.texts.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: context.texts.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Petite colonne icône / libellé / valeur, pour les caractéristiques d'une
/// fiche affichées côte à côte.
class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(height: 6),
          Text(label, style: context.texts.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: context.texts.labelLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Ligne icône + libellé + valeur, alignée à gauche.
class LabelledRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const LabelledRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.colors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.texts.labelMedium),
              const SizedBox(height: 2),
              Text(value, style: context.texts.labelLarge),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dégradé d'eau utilisé par les en-têtes : on plonge du bord vers le fond.
BoxDecoration pondGradient(BuildContext context, {BorderRadiusGeometry? radius}) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: context.isDark
          ? const [Color(0xFF15242E), Color(0xFF1B3B4A)]
          : const [AppPalette.mizuDeep, AppPalette.mizuMid],
    ),
    borderRadius: radius,
  );
}

/// Séparateur vertical entre deux [InfoTile].
class VerticalRule extends StatelessWidget {
  const VerticalRule({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: context.colors.outlineVariant,
    );
  }
}
