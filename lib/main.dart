import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/auth_listenable.dart';
import 'app/preferences.dart';
import 'app/router.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Charge les noms de mois et de jours de toutes les langues, pour
  // DateFormat : l'interface suit la langue du téléphone.
  await initializeDateFormatting();

  final preferences = AppPreferences();
  await preferences.load();

  runApp(MyApp(preferences: preferences));
}

class MyApp extends StatefulWidget {
  final AppPreferences preferences;

  const MyApp({super.key, required this.preferences});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthListenable _auth = AuthListenable();
  late final GoRouter _router = buildRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferencesScope(
      preferences: widget.preferences,
      child: ListenableBuilder(
        listenable: widget.preferences,
        builder: (context, _) {
          final prefs = widget.preferences;
          return MaterialApp.router(
            title: 'AOI KOI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: prefs.themeMode,
            // La langue du téléphone, l'anglais s'il en parle une autre.
            supportedLocales: appLocales,
            localeListResolutionCallback: resolveAppLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _router,
            // Le préréglage « Animations réduites » se propage par le même
            // canal que le réglage système : tout widget qui consulte
            // disableAnimations respecte l'un comme l'autre.
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  disableAnimations:
                      media.disableAnimations || prefs.reducedMotion,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
