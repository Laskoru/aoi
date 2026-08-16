# AOI KOI

Application Flutter de suivi de bassin et de collection de carpes koï :
fiches individuelles avec date de naissance et généalogie, courbes de
croissance, et relevés des paramètres de l'eau.

Projet Firebase associé : `aoi-koi`.

## Prérequis

- Flutter (canal stable) et le SDK Dart correspondant
- Firebase CLI, pour déployer les règles : `npm install -g firebase-tools`
- Android SDK pour un build Android, Xcode pour iOS

## Démarrer

```bash
flutter pub get
flutter run
```

## Structure

```
lib/
  config.dart            Constantes de build (client ID Google)
  main.dart              Point d'entrée + AuthGate (login ou dashboard)
  firebase_options.dart  Généré par flutterfire configure
  models/                Koi, GrowthEntry, WaterMeasurement
  screens/               Login, dashboard, ajout de koï, ajout de mesure, fiche détail
  utils/water_logic.dart Seuils pH et température
  widgets/               MetricCard, WaterChart
```

## Données Firestore

```
kois/{id}          userId, name, variety, size, birthDate, sex, status,
                   breeder, origin, notes, imageUrl,
                   fatherId | fatherNameManual, motherId | motherNameManual,
                   createdAt
  └ growth/{id}    size, timestamp

measurements/{id}  userId, ph, temperature, timestamp,
                   kh, gh, nitrite, nitrate, ammonia (optionnels)
```

Les photos vivent dans Cloud Storage sous `kois_photos/{userId}/{koiId}.jpg`.

### Champ `age` (obsolète)

Les fiches créées avant l'ajout de `birthDate` portent un `age` entier, figé au
moment de la saisie. Il est toujours lu en repli et affiché comme une
approximation (« ~4 ans »). Pour convertir une fiche, ouvrir son détail et
appuyer sur la ligne de date de naissance : le calendrier s'ouvre pré-positionné
sur l'année déduite de l'ancien âge.

## Déployer les règles de sécurité

Les règles restreignent chaque document à son propriétaire. Sans elles, les
données du bassin sont lisibles par n'importe qui.

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Thème

Toutes les couleurs, tailles de texte, rayons et espacements vivent dans
`lib/theme/`. Aucun écran ne doit contenir de couleur littérale : on lit le
thème via `context.colors`, `context.texts` et `context.pond`.

- `app_palette.dart` — la palette nishikigoi (shiroji, hi, sumi, eau) et les
  échelles `AppRadius` / `AppSpacing`
- `app_theme.dart` — thèmes clair et sombre, plus l'extension `PondColors`
  pour les trois états de l'eau
- `app_widgets.dart` — briques partagées : `AppCard`, `SectionHeader`,
  `StatusPill`, `EmptyState`…
- `pond_status.dart` — couleur, libellé et conseil associés à chaque
  `WaterCondition`

L'application suit le réglage clair/sombre du téléphone.

## Tester sur iPhone via la PWA

Aucun Mac n'est nécessaire : on publie la version web et on l'ajoute à l'écran
d'accueil.

```bash
flutter build web --release
firebase deploy --only hosting
```

Sur l'iPhone, ouvrir l'URL affichée **dans Safari** (pas Chrome), puis
Partager → « Sur l'écran d'accueil ». L'application se lance ensuite en plein
écran, avec son icône.

Un vrai build iOS (`.ipa`, TestFlight, App Store) exige macOS et Xcode : Apple
ne permet pas de compiler ni de signer une application iOS depuis Windows.

## Tests

```bash
flutter test
```

Les tests couvrent les seuils de qualité d'eau et le calcul d'âge à partir de la
date de naissance (`test/water_logic_test.dart`, `test/koi_age_test.dart`).
