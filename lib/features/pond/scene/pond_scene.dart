import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../models/koi.dart';
import '../../../theme/app_palette.dart';
import '../../../theme/app_theme.dart';
import 'koi_painter.dart';
import 'koi_simulation.dart';
import 'water_layer.dart';

/// Le bassin vu d'en haut, avec les vrais koï de la collection qui y nagent.
///
/// Trois couches, chacune isolée dans son `RepaintBoundary` : l'eau, les
/// koï, et par-dessus, ce que l'écran parent superpose. Un seul `Ticker`
/// fait avancer le temps de l'eau et la simulation ; il s'arrête quand
/// l'application passe en arrière-plan, quand la scène quitte l'écran, ou
/// quand l'utilisateur a demandé moins de mouvement.
class PondScene extends StatefulWidget {
  final List<Koi> kois;
  final void Function(Koi koi) onKoiTap;

  /// Faux quand la scène n'est pas l'onglet visible : inutile d'animer ce
  /// qu'on ne voit pas.
  final bool visible;

  const PondScene({
    super.key,
    required this.kois,
    required this.onKoiTap,
    this.visible = true,
  });

  @override
  State<PondScene> createState() => _PondSceneState();
}

class _PondSceneState extends State<PondScene>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final Ticker _ticker;
  final KoiSimulation _simulation = KoiSimulation(bounds: Size.zero);

  Duration _lastTick = Duration.zero;
  double _time = 0;
  int _frame = 0;
  bool _inForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _simulation.setKois(widget.kois);
    _ticker = createTicker(_onTick);
    _syncTicker();
  }

  @override
  void didUpdateWidget(PondScene old) {
    super.didUpdateWidget(old);
    if (old.kois != widget.kois) _simulation.setKois(widget.kois);
    _syncTicker();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
    _syncTicker();
  }

  bool get _reducedMotion => MediaQuery.of(context).disableAnimations;

  bool get _shouldAnimate => widget.visible && _inForeground && !_reducedMotion;

  void _syncTicker() {
    if (_shouldAnimate) {
      if (!_ticker.isActive) {
        _lastTick = Duration.zero;
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    _time += dt;
    _simulation.step(dt);
    setState(() => _frame++);
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != _simulation.bounds) _simulation.resize(size);

        return Semantics(
          label: _semanticsLabel(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final hit = _simulation.hitTest(details.localPosition);
              if (hit != null) widget.onKoiTap(hit.koi);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: WaterLayer(
                    time: _time,
                    animated: _shouldAnimate,
                    shallow: shallow,
                    deep: deep,
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: KoiSwarmPainter(
                      agents: _simulation.agents,
                      frame: _frame,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _semanticsLabel() {
    final n = _simulation.agents.length;
    if (n == 0) return "Bassin vide";
    final names = _simulation.agents.map((a) => a.koi.name).join(', ');
    return "Bassin avec $n koï : $names";
  }

  /// Combien de koï vivants ne sont pas dessinés, faute de place.
  int get hiddenCount => _simulation.hiddenCount;
}
