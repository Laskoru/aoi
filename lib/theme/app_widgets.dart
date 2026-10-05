import 'package:flutter/material.dart';
import 'app_palette.dart';
import 'app_theme.dart';
import 'koi_mark.dart';

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

/// Échec de chargement.
///
/// Distinct de [EmptyState] à dessein : afficher « votre collection est vide »
/// alors qu'une requête a échoué laisserait croire à une perte de données.
class ErrorState extends StatelessWidget {
  final Object? error;
  final String? title;

  const ErrorState({super.key, this.error, this.title});

  /// Un refus de permission n'appelle pas la même réaction qu'une coupure
  /// réseau : autant le dire franchement plutôt que d'afficher le code brut.
  String get _message {
    final text = error?.toString().toLowerCase() ?? '';
    if (text.contains('permission-denied') || text.contains('insufficient')) {
      return "Accès refusé par les règles de sécurité. Vérifiez que vous êtes "
          "bien connecté au bon compte.";
    }
    if (text.contains('unavailable') || text.contains('network')) {
      return "Connexion au serveur impossible. Vérifiez votre accès à Internet.";
    }
    if (text.contains('failed-precondition') || text.contains('index')) {
      return "Un index Firestore manque pour cette requête. Déployez les index "
          "du projet.";
    }
    return "Une erreur est survenue pendant le chargement.";
  }

  @override
  Widget build(BuildContext context) {
    final danger = context.pond.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.pond.dangerSurface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: danger.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cloud_off_rounded, color: danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "Chargement impossible",
                  style: context.texts.labelLarge?.copyWith(color: danger),
                ),
                const SizedBox(height: 2),
                Text(_message, style: context.texts.bodyMedium),
              ],
            ),
          ),
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

/// Emblème de l'application : le koï kohaku de l'icône, vu d'en haut.
///
/// Il sert de logo sur l'écran de connexion, d'icône à l'onglet Koï et de
/// vignette pour les koï sans photo. Material n'offre aucune icône de poisson
/// convaincante — la seule approchante représente un poisson servi dans une
/// assiette, ce qui tombe assez mal dans une application d'élevage.
///
/// Le corps prend [color] ; les plaques `hi` gardent leur rouge, avec la même
/// transparence que le corps.
class KoiEmblem extends StatelessWidget {
  final double size;
  final Color? color;

  const KoiEmblem({super.key, this.size = 48, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _KoiMarkPainter(
          body: color ?? context.colors.primary,
          hi: context.isDark ? AppPalette.hiBright : AppPalette.hi,
        ),
      ),
    );
  }
}

class _KoiMarkPainter extends CustomPainter {
  final Color body;
  final Color hi;

  const _KoiMarkPainter({required this.body, required this.hi});

  static Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);

  static final _bodyPath = _polygon(KoiMarkShape.body);
  static final _fins = [
    _polygon(KoiMarkShape.leftFin),
    _polygon(KoiMarkShape.rightFin),
    _polygon(KoiMarkShape.tail),
  ];
  static final _patches = KoiMarkShape.patches.fold(
    Path(),
    (path, rect) => path..addOval(rect),
  );

  /// Le poisson occupe 92 % de la hauteur, comme le dessin d'une icône
  /// Material dans sa boîte.
  static const _fill = 0.92;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * _fill;
    // Nageoires et corps se chevauchent : peints opaques dans un calque puis
    // fondus d'un bloc, sinon les recouvrements ressortiraient plus foncés.
    final translucent = body.a < 1;
    if (translucent) {
      canvas.saveLayer(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: body.a),
      );
    } else {
      canvas.save();
    }
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side);

    final paint = Paint()..color = body.withValues(alpha: 1);
    for (final fin in _fins) {
      canvas.drawPath(fin, paint);
    }
    canvas.drawPath(_bodyPath, paint);
    canvas.clipPath(_bodyPath);
    canvas.drawPath(_patches, Paint()..color = hi);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KoiMarkPainter old) => old.body != body || old.hi != hi;
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
