import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/auth_listenable.dart';
import 'app/preferences.dart';
import 'app/router.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Charge les noms de mois et de jours français utilisés par DateFormat.
  await initializeDateFormatting('fr_FR');

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
            locale: const Locale('fr'),
            supportedLocales: const [Locale('fr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
