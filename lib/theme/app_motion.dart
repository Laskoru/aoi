import 'package:flutter/material.dart';

/// Rythme commun à toutes les animations de l'interface.
///
/// Une seule échelle pour toute l'appli : les entrées décélèrent, les sorties
/// sont plus courtes que les entrées, et une liste se révèle par vagues de
/// quelques dizaines de millisecondes. Tout s'efface si l'utilisateur a
/// demandé moins de mouvement.
class AppMotion {
  const AppMotion._();

  static const Duration enter = Duration(milliseconds: 280);

  /// ~65 % de l'entrée : une sortie qui traîne donne l'impression de lenteur.
  static const Duration exit = Duration(milliseconds: 180);
  static const Duration stagger = Duration(milliseconds: 40);

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;

  static bool reduced(BuildContext context) =>
      MediaQuery.of(context).disableAnimations;
}

/// Fait apparaître un élément de liste par un fondu et une légère montée,
/// décalé selon son rang. Sous réduction des animations, l'élément est rendu
/// directement dans son état final.
class StaggerIn extends StatefulWidget {
  final int index;
  final Widget child;

  /// Au-delà, on n'attend plus : les éléments hors écran apparaîtraient de
  /// toute façon pendant le défilement.
  static const int maxDelayedIndex = 12;

  const StaggerIn({super.key, required this.index, required this.child});

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.enter,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.enterCurve,
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_opacity);

  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (AppMotion.reduced(context)) {
      _controller.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, StaggerIn.maxDelayedIndex);
    Future<void>.delayed(AppMotion.stagger * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
