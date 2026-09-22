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
  └ photos/{id}       url, storagePath, takenAt
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

Storage : `kois_photos/{uid}/{koiId}/{photoId}.jpg` pour les galeries,
`user_media/{uid}/**` pour le reste.

### Champ `age` (obsolète)

Les fiches créées avant l'ajout de `birthDate` portent un `age` entier, figé
au moment de la saisie. Il est lu en repli et affiché comme une approximation
(« ~4 ans »). Renseigner la date de naissance depuis la fiche le supprime.

## La scène du bassin

L'eau est un fragment shader (`shaders/pond_water.frag`) : dégradé de
profondeur, ondulations, caustiques, aux couleurs du thème. Les koï sont
dessinés par code, sans asset : leur longueur suit leur taille réelle, leur
motif se déduit du nom de variété, et une simulation les fait errer en
évitant les bords et les voisins. Toucher un koï ouvre sa fiche.

Sous réduction des animations — réglage système ou préréglage du profil —
la scène est rendue fixe, avec un dégradé peint à la main à la place du
shader. Le ticker s'arrête aussi en arrière-plan et hors de l'onglet.

## Déployer les règles de sécurité

Les règles restreignent chaque document à son propriétaire. Sans elles, les
données du bassin sont lisibles par n'importe qui.

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

## Thème

Toutes les couleurs, tailles de texte, rayons, espacements et durées vivent
dans `lib/theme/`. Aucun écran ne contient de couleur littérale : on lit le
thème via `context.colors`, `context.texts` et `context.pond`. L'application
suit le réglage clair/sombre du téléphone, ou celui choisi dans le profil.

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

## Tests

```bash
flutter test
```

Seuils de qualité d'eau, calcul d'âge, sérialisation des modèles, motifs
par variété et simulation des koï (bornes, plafond, pas de temps, toucher).
