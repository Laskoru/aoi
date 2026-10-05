# Fiche Google Play — AOI KOI

Tout ce que la Play Console demande pour publier, prêt à copier.

## Visuels

| Élément | Fichier | Exigence Google |
|---|---|---|
| Icône | `store/icon-512.png` | 512 × 512, PNG |
| Image de présentation | `store/feature-graphic.png` | 1024 × 500, PNG sans transparence |
| Captures d'écran téléphone | à prendre sur la tablette ou l'iPhone | 2 à 8, côté court ≥ 320 px, rapport ≤ 2:1 |

Captures suggérées, dans cet ordre : l'accueil avec la photo du bassin, la
grille des koï, une fiche de koï (âge, généalogie, croissance), l'onglet Eau
avec le bandeau de santé, la liste des plantes par zone.

## Textes

**Nom de l'application** (30 caractères max) :

```
AOI KOI : carnet de bassin
```

**Description courte** (80 caractères max) :

```
Suivez vos koï, vos plantes et la qualité de l'eau de votre bassin.
```

**Description complète** (4 000 caractères max) :

```
AOI KOI est le carnet de votre bassin de jardin : vos carpes koï, vos autres poissons, vos plantes et la qualité de l'eau, au même endroit.

VOS KOÏ, UN PAR UN
• Une fiche par koï : nom, variété, taille, sexe, éleveur, provenance, notes.
• La date de naissance, d'où l'âge se calcule tout seul — avec la classe d'âge japonaise : tosai, nisai, sansai…
• La généalogie : père et mère, liés à d'autres koï de votre bassin ou saisis à la main.
• La courbe de croissance, mesure après mesure.
• Une galerie photo par koï, pour suivre l'évolution de son motif d'une année sur l'autre.
• Un statut pour chaque poisson : vivant, vendu, donné ou décédé — sa place dans la généalogie est conservée.

LA QUALITÉ DE L'EAU
• pH, température, ammoniaque, nitrites, nitrates, KH et GH.
• Des seuils adaptés aux koï : chaque valeur est jugée saine, en alerte ou dangereuse.
• Un bandeau nomme le paramètre qui pose problème et explique ce qu'il coûte à vos poissons.
• L'historique complet des relevés et leurs courbes.

LES PLANTES
• Classées par zone de plantation, de la berge vers le fond : berge, marécage, immergée, profonde.
• Flottantes et oxygénantes repérées d'un coup d'œil.
• Date de plantation, quantité, photo, notes d'entretien.

LES AUTRES HABITANTS
Ides, esturgeons, carassins… suivis par espèce et par effectif, avec leur date d'introduction.

VOTRE BASSIN
Son nom, son volume, sa profondeur, et sa photo en ouverture de l'application.

VOS DONNÉES VOUS APPARTIENNENT
• Connexion avec votre compte Google.
• Vos données sont hébergées en Europe et ne sont visibles que par vous.
• Aucune publicité, aucun traceur, aucune revente.
• Suppression du compte et de toutes les données depuis l'application, à tout moment.

Thème clair et sombre, et réduction des animations pour qui la préfère.
```

## Coordonnées et liens

| Champ | Valeur |
|---|---|
| Règles de confidentialité | `https://aoi-koi.web.app/confidentialite.html` |
| Suppression de compte | `https://aoi-koi.web.app/suppression-compte.html` |
| E-mail de contact | `hugob.web@gmail.com` (affiché publiquement) |
| Site web | l'un de tes sites |
| Catégorie | Style de vie |

## Questionnaires de la Play Console

**Accès à l'application** — Certaines fonctionnalités sont restreintes.
Instructions pour l'examinateur :

```
L'application demande une connexion Google. N'importe quel compte Google fonctionne : aucun identifiant spécifique n'est nécessaire. Toutes les fonctionnalités sont accessibles après connexion.
```

**Annonces** — Non, l'application ne contient pas de publicité.

**Classification du contenu** (questionnaire IARC) — Catégorie « Utilitaire,
productivité, communication ou autre ». Répondre non à tout : ni violence, ni
contenu sexuel, ni langage grossier, ni substances, ni jeux d'argent ; les
utilisateurs n'interagissent pas entre eux et ne partagent ni contenu ni
position. Résultat attendu : PEGI 3.

**Public cible** — 18 ans et plus. (Cibler des mineurs déclenche les
obligations du programme Famille, sans intérêt ici ; ce choix ne limite pas
qui peut télécharger l'application.)

**Application d'actualités, santé, finance, services publics** — Non à tout.

**Sécurité des données** :

| Question | Réponse |
|---|---|
| L'application collecte-t-elle ou partage-t-elle des données ? | Oui |
| Les données sont-elles chiffrées en transit ? | Oui |
| Les utilisateurs peuvent-ils demander la suppression de leurs données ? | Oui — `https://aoi-koi.web.app/suppression-compte.html` |
| Des données sont-elles partagées avec des tiers ? | Non (Firebase est un sous-traitant, pas un tiers au sens de Google Play) |

Types de données collectées, toutes **non partagées**, **non traitées de façon
éphémère** :

| Catégorie | Type | Obligatoire | Finalités |
|---|---|---|---|
| Informations personnelles | Nom | Oui | Fonctionnalité de l'appli, gestion du compte |
| Informations personnelles | Adresse e-mail | Oui | Gestion du compte |
| Informations personnelles | Identifiants utilisateur | Oui | Gestion du compte |
| Photos et vidéos | Photos | Non | Fonctionnalité de l'appli |
| Activité dans l'appli | Autres contenus générés par l'utilisateur | Non | Fonctionnalité de l'appli |

## Publication

1. **Version** : déposer `AOI-KOI-play.aab` (sur le Bureau).
2. Commencer par le canal **Tests internes** : jusqu'à 100 testeurs, disponible
   en quelques minutes, sans examen. S'y ajouter soi-même, installer depuis le
   Play Store sur la tablette, vérifier la connexion Google.
3. **Empreinte Play App Signing** : Google Play re-signe l'application avec sa
   propre clé. Relever son SHA-1 dans *Test et publication → Intégrité de
   l'application*, et l'ajouter à Firebase — sans elle, la connexion Google
   échoue sur la version téléchargée du Play Store.
4. Puis **Production** → envoyer pour examen. Compter quelques jours.
