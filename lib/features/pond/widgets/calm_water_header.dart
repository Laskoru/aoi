import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import '../scene/water_layer.dart';

/// Fond d'en-tête : une eau presque immobile.
///
/// Le même shader que la scène du bassin, mais ramené à un léger jeu de
/// lumière — ondulations à peine perceptibles, caustiques discrètes, temps
/// ralenti. L'eau vit sans attirer l'œil : c'est le contenu par-dessus qui
/// compte. Sous réduction des animations, ou en arrière-plan, elle se fige.
class CalmWaterHeader extends StatefulWidget {
  final double height;
  final Widget child;

  /// Photo du bassin de l'utilisateur. Quand elle est là, c'est elle le fond,
  /// et l'eau de synthèse s'efface : rien ne vaut le vrai bassin.
  final String? imageUrl;

  const CalmWaterHeader({
    super.key,
    required this.height,
    required this.child,
    this.imageUrl,
  });

  @override
  State<CalmWaterHeader> createState() => _CalmWaterHeaderState();
}

class _CalmWaterHeaderState extends State<CalmWaterHeader>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// Le temps du shader avance quatre fois moins vite que dans la scène.
  static const double _timeScale = 0.25;

  late final Ticker _ticker;
  double _time = 0;
  bool _inForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker((elapsed) {
      setState(() => _time = elapsed.inMicroseconds / 1e6 * _timeScale);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(CalmWaterHeader old) {
    super.didUpdateWidget(old);
    if (old.imageUrl != widget.imageUrl) _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  /// Sous une photo, inutile de faire vivre l'eau qu'on ne voit pas.
  bool get _animated =>
      widget.imageUrl == null &&
      _inForeground &&
      !MediaQuery.of(context).disableAnimations;

  void _syncTicker() {
    if (_animated) {
      if (!_ticker.isActive) _ticker.start();
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final shallow = isDark ? const Color(0xFF1B3B4A) : AppPalette.mizuMid;
    final deep = isDark ? const Color(0xFF0C1A22) : AppPalette.mizuDeep;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: WaterLayer(
                time: _time,
                animated: _animated,
                shallow: shallow,
                deep: deep,
                causticIntensity: 0.07,
                waveAmplitude: 0.12,
              ),
            ),
            if (widget.imageUrl != null) ...[
              Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                // Si la photo ne charge pas, l'eau reste dessous.
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              // Sur une photo, un voile en bas aussi : le nom et la pastille
              // doivent rester lisibles sur n'importe quel cliché.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ),
            ],
            // Voile en haut : la marque et le nom restent lisibles quelle que
            // soit la lumière derrière.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}
