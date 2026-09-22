import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages locaux de l'utilisateur, persistés sur l'appareil.
///
/// Le thème et la réduction des animations sont des préférences d'affichage :
/// elles n'ont rien à faire dans Firestore, et doivent être disponibles avant
/// même la connexion.
class AppPreferences extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  static const _reducedMotionKey = 'reduced_motion';

  ThemeMode _themeMode = ThemeMode.system;
  bool _reducedMotion = false;
  SharedPreferences? _store;

  ThemeMode get themeMode => _themeMode;

  /// Préréglage manuel, en plus du réglage système : utile sur un appareil
  /// modeste où la scène animée du bassin coûterait trop cher.
  bool get reducedMotion => _reducedMotion;

  Future<void> load() async {
    _store = await SharedPreferences.getInstance();
    _themeMode = switch (_store!.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _reducedMotion = _store!.getBool(_reducedMotionKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _store?.setString(_themeKey, mode.name);
  }

  Future<void> setReducedMotion(bool value) async {
    if (value == _reducedMotion) return;
    _reducedMotion = value;
    notifyListeners();
    await _store?.setBool(_reducedMotionKey, value);
  }
}

/// Rend [AppPreferences] accessible dans l'arbre, sans dépendance externe.
class PreferencesScope extends InheritedNotifier<AppPreferences> {
  const PreferencesScope({
    super.key,
    required AppPreferences preferences,
    required super.child,
  }) : super(notifier: preferences);

  static AppPreferences of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<PreferencesScope>();
    assert(scope != null, 'PreferencesScope absent de l\'arbre');
    return scope!.notifier!;
  }
}
