# Journal des versions — AOI KOI

L'appli est publiée sur Google Play. Chaque modification visible est notée
ici au fil de l'eau, sous « À venir ». Au moment de publier, cette section
prend le numéro de la version, et ses nouveautés deviennent les notes de
version de la Play Console (500 caractères au plus, balises `<fr-FR>`
comprises).

## 2.0.1 (9) — octobre 2026

### Nouveautés
- **Photo des autres habitants** : un groupe de poissons (ides, esturgeons,
  poissons rouges…) peut avoir sa photo. On la choisit en touchant la photo
  ronde en haut du formulaire, dès la création du groupe ou en le modifiant.

### Corrections
- **Champs obligatoires** : dans un formulaire (koï, plante, autres
  habitants, mesure, bassin), un champ obligatoire laissé vide en haut
  n'était pas signalé si l'on avait fait défiler l'écran jusqu'au bouton.
  L'enregistrement échouait alors (« permission denied »), ou retenait une
  valeur par défaut à la place de la saisie (taille 0, pH 7, 0 °C). Le
  champ est désormais signalé, et l'écran remonte jusqu'à lui.
- **Ajout d'un koï** : l'enregistrement pouvait échouer au premier essai
  (« permission denied ») alors que la fiche était bel et bien créée, et le
  second essai la créait une deuxième fois. Sur Android, la fiche et sa
  première mesure de taille partaient en deux écritures dont l'ordre
  d'arrivée n'est pas garanti ; elles partent désormais en un seul lot.
- **Textes avec emoji** : un nom ou des notes riches en emoji pouvaient être
  refusés à l'enregistrement alors que le formulaire les acceptait (les
  règles comptaient un emoji pour deux caractères).

### En coulisses (hors notes Play)
- Configuration Android à jour avec la clé de signature de Google Play.
- Règles Firestore : la première mesure de taille est acceptée dans le même
  lot que la création du koï. **À déployer avant de publier la 2.0.1**
  (`firebase deploy --only firestore:rules`) : sans elles, tout ajout de koï
  serait refusé. Elles ne changent rien pour la 2.0.0. Déployées le 12 octobre.
- Règles Firestore : plafonds de longueur deux fois et demie plus hauts que
  les limites de saisie de l'appli, pour les emoji (même déploiement).
- Champs numériques : « NaN » collé dans un champ est refusé par le
  formulaire au lieu de l'être par le serveur.
- Tests des règles : chaque formulaire rempli au minimum, textes en emoji
  (103 tests).
- Formulaires : un même conteneur (`FormBody`) garde tous les champs
  construits, même hors de l'écran, pour que la validation les voie tous.
  Tests des vrais écrans enregistrés depuis leur bouton, clavier ouvert.

### Notes Play prêtes à coller
```
<fr-FR>
Nouveau : ajoutez une photo à vos autres habitants (ides, esturgeons, poissons rouges…), dès la création du groupe ou en le modifiant.
Corrigé : un champ obligatoire oublié est désormais signalé, au lieu d'une erreur à l'enregistrement.
Corrigé : l'ajout d'un koï pouvait échouer au premier essai et créer un doublon.
</fr-FR>
```

## 2.0.0 (7) — octobre 2026

Première version publiée sur Google Play.

- Une fiche par koï : variété, taille, sexe, éleveur, âge et classe d'âge
  japonaise, généalogie, courbe de croissance, galerie photo, statut.
- Les plantes classées par zone de plantation, avec photo.
- Les relevés d'eau (pH, température, ammoniaque, nitrites, nitrates, KH,
  GH), jugés selon des seuils adaptés aux koï, et leurs courbes.
- Les autres habitants du bassin, et la photo du bassin en ouverture.
- Connexion avec un compte Google, données hébergées en Europe, suppression
  du compte et des données depuis l'appli.
