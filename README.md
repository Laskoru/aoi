# AOI KOI

Application Flutter de gestion de bassin : koï suivis individuellement
(date de naissance, généalogie, croissance, galerie), autres poissons par
groupe, plantes aquatiques par zone de plantation, qualité de l'eau — et une
scène du bassin où les vrais koï de la collection nagent.

Projet Firebase associé : `aoi-koi`.

## Prérequis

- Flutter 3.47 (canal stable) ou plus récent
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
  main.dart                Point d'entrée, thème, préférences
  config.dart              Constantes de build (client ID Google, mobile natif)
  app/
    router.dart            Toutes les routes (go_router) et la redirection auth
    app_shell.dart         Les cinq onglets
    auth_listenable.dart   État de session exposé au routeur
    preferences.dart       Thème et animations réduites, persistés
  features/
    pond/                  Onglet Bassin : scène, en-tête, autres habitants
      scene/               Shader d'eau, simulation et dessin des koï
    koi/                   Grille, fiche (découpée en widgets), formulaire
    plants/                Liste par zone, fiche, formulaire
    water/                 Moniteur, historique, saisie
    profile/               Compte, affichage, bassin, déconnexion
    auth/                  Écran de connexion
  models/                  Koi, KoiPhoto, GrowthEntry, WaterMeasurement,
                           Pond, Plant, FishGroup
  services/                Seul point d'accès à Firestore et Storage,
                           un service par domaine
  theme/                   Palette, thèmes clair/sombre, widgets partagés,
                           rythme des animations
  utils/water_logic.dart   Seuils de qualité d'eau
shaders/pond_water.frag    Eau du bassin, compilé au build
```

## Navigation

Cinq onglets, chacun avec sa pile et son défilement préservés. Chaque écran
a une URL, ce qui rend les fiches partageables et le bouton retour du
navigateur fiable :

```
/bassin  /bassin/edit  /bassin/poissons/new  /bassin/poissons/:id/edit
/koi     /koi/new      /koi/:id              /koi/:id/edit
/plantes /plantes/new  /plantes/:id          /plantes/:id/edit
/eau     /eau/nouvelle /eau/historique
/profil  /login
```

## Données Firestore

```
ponds/default_{uid}   userId, name, volumeLiters, depthCm, imageUrl, notes
kois/{id}             userId, pondId?, name, variety, size, birthDate, sex,
                      status, breeder, origin, notes, imageUrl, généalogie
  └ growth/{id}       size, timestamp
  └ photos/{id}       url (référence photo:{id}), takenAt
photos/{id}           userId, data (JPEG ≤ 900 Ko), createdAt
plants/{id}           userId, pondId?, name, species, zone, isFloating,
                      isOxygenating, quantity, plantedAt, imageUrl, notes
fish_groups/{id}      userId, pondId?, species, count, introducedAt,
                      imageUrl, notes
measurements/{id}     userId, pondId?, ph, temperature, timestamp,
                      ammonia, nitrite, nitrate, kh, gh (optionnels)
```

Le bassin par défaut a un identifiant déterministe et se crée tout seul à la
première connexion. `pondId` absent signifie « le bassin par défaut » : les
documents antérieurs n'ont pas eu à être réécrits.

Les photos sont des documents `photos/{id}` : Cloud Storage exige la formule
Blaze (payante à l'usage) depuis février 2026, Firestore reste gratuit
jusqu'à 1 Gio. Chaque photo est compressée en JPEG sous 900 Ko (1 600 px de
côté au plus) et les fiches y renvoient par `imageUrl: "photo:{id}"`.
`StoredPhotoImage` les affiche comme n'importe quelle image, cache compris.
Passer un jour à Blaze ne demande aucun changement ; seules les anciennes
photos restées dans Storage (`kois_photos/…`, `user_media/…`) redeviendraient
lisibles.

### Champ `age` (obsolète)

Les fiches créées avant l'ajout de `birthDate` portent un `age` entier, figé
au moment de la saisie. Il est lu en repli et affiché comme une approximation
(« ~4 ans »). Renseigner la date de naissance depuis la fiche le supprime.

## L'en-tête du bassin

L'accueil s'ouvre sur une eau presque immobile : le shader
`shaders/pond_water.frag` (dégradé de profondeur, ondulations, caustiques),
réglé à un léger jeu de lumière et à un temps ralenti, aux couleurs du
thème. Par-dessus : le nom du bassin, ses dimensions, l'état de l'eau. Sous
réduction des animations — réglage système ou préréglage du profil — un
dégradé peint à la main le remplace, et rien ne bouge.

Une scène complète, où les koï de la collection nagent (dessinés par code,
motif déduit de la variété, simulation d'errance), reste disponible dans
`lib/features/pond/scene/` : `PondScene` s'utilise comme un widget, avec ses
tests. L'accueil ne l'affiche plus, elle a été jugée trop présente.

## Déployer les règles de sécurité

Les règles restreignent chaque document à son propriétaire. Sans elles, les
données du bassin sont lisibles par n'importe qui.

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

Avant chaque déploiement de `firestore.rules`, les éprouver dans l'émulateur
(`tool/firestore-rules-test/`, 94 cas : isolement entre comptes, transfert de
propriété, requêtes sans filtre, valeurs validées). Il faut Node et Java 21
ou plus ; celui d'Android Studio convient
(`C:\Program Files\Android\Android Studio\jbr\bin` dans le PATH).

```bash
npm --prefix tool/firestore-rules-test install
firebase emulators:exec --only firestore --project demo-aoi "npm --prefix tool/firestore-rules-test test"
```

## Thème

Toutes les couleurs, tailles de texte, rayons, espacements et durées vivent
dans `lib/theme/`. Aucun écran ne contient de couleur littérale : on lit le
thème via `context.colors`, `context.texts` et `context.pond`. L'application
suit le réglage clair/sombre du téléphone, ou celui choisi dans le profil.

## Icône

Un koï kohaku à plat, vu d'en haut. Les sources sont dans `assets/icon/` :
`icon.png` (iOS, web, fiche Play), `foreground.png` et `monochrome.png`
(icône adaptative d'Android, déjà dessinée dans la zone sûre, d'où
`adaptive_icon_foreground_inset: 0`). Après une modification :

```bash
dart run flutter_launcher_icons
git checkout web/manifest.json   # l'outil l'écrase avec ses valeurs anglaises
```

Le même tracé, exporté dans `lib/theme/koi_mark.dart`, dessine `KoiEmblem`
dans l'appli : connexion, onglet Koï, vignettes sans photo.

## Données de démonstration

En mode debug seulement : Profil → Données de démonstration → Ajouter. Huit
koï avec photos, croissance et filiation, cinq semaines de relevés d'eau, des
plantes dans chaque zone, trois groupes d'autres poissons et une photo du
bassin s'il n'en a pas. Tout porte `demo: true` ; « Retirer » n'efface que
cela. Les photos viennent d'Unsplash (licence libre, auteurs cités dans
`lib/features/profile/demo_data.dart`).

## Tester sur iPhone via la PWA

Aucun Mac n'est nécessaire : on publie la version web et on l'ajoute à
l'écran d'accueil.

```bash
flutter build web --release
firebase deploy --only hosting
```

Sur l'iPhone, ouvrir l'URL affichée **dans Safari** (pas Chrome), puis
Partager → « Sur l'écran d'accueil ». Après une mise à jour, retirer et
remettre l'icône : une PWA installée garde son propre cache.

Un vrai build iOS (`.ipa`, TestFlight, App Store) exige macOS et Xcode.

## Publier une mise à jour

L'appli est en ligne sur Google Play. Chaque modification visible est notée
dans [CHANGELOG.md](CHANGELOG.md), sous « À venir », au fil de l'eau.

1. Si `firestore.rules` a changé depuis la dernière version, la déployer en
   premier (`firebase deploy --only firestore:rules`) : la nouvelle version
   peut en dépendre. Ces règles doivent aussi accepter la version déjà
   publiée, que les utilisateurs gardent tant qu'ils n'ont pas mis à jour.
2. Dans `pubspec.yaml`, augmenter `version` : le nom (2.0.1…) et le numéro
   après le `+`, toujours plus grand que le dernier envoyé — le Play Store
   refuse un numéro déjà utilisé.
3. `flutter build appbundle --release` →
   `build/app/outputs/bundle/release/app-release.aab`.
4. Play Console → Tests internes : nouvelle version avec les notes prêtes du
   journal, vérification sur un appareil, puis promotion en production.
5. Dans le journal, « À venir » prend le numéro publié.

## Tests

```bash
flutter test
```

Seuils de qualité d'eau, calcul d'âge, sérialisation des modèles, motifs
par variété et simulation des koï (bornes, plafond, pas de temps, toucher).
