// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get koiSexUnknown => 'Indéterminé';

  @override
  String get koiSexMale => 'Mâle';

  @override
  String get koiSexFemale => 'Femelle';

  @override
  String get koiStatusAlive => 'Vivant';

  @override
  String get koiStatusDeceased => 'Décédé';

  @override
  String get koiStatusSold => 'Vendu';

  @override
  String get koiStatusGiven => 'Donné';

  @override
  String get ageUnknown => 'Âge inconnu';

  @override
  String get ageLessThanAMonth => 'Moins d\'un mois';

  @override
  String ageMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String ageYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String ageApproxYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '~$years ans',
      one: '~1 an',
    );
    return '$_temp0';
  }

  @override
  String ageYearsAndMonths(String years, String months) {
    return '$years et $months';
  }

  @override
  String yearClassOver(int count) {
    return 'Plus de $count ans';
  }

  @override
  String get plantZoneBerge => 'Berge';

  @override
  String get plantZoneMarecage => 'Marécage';

  @override
  String get plantZoneImmergee => 'Immergée';

  @override
  String get plantZoneProfonde => 'Profonde';

  @override
  String get plantZoneBergeDescription =>
      'Sol humide, jamais immergé : carex, joncs, iris des marais.';

  @override
  String get plantZoneMarecageDescription =>
      'De 0 à 20 cm d\'eau : iris, sagittaires, cyperus.';

  @override
  String get plantZoneImmergeeDescription =>
      'De 20 à 40 cm : plantes émergées, racines sous l\'eau.';

  @override
  String get plantZoneProfondeDescription =>
      'De 40 cm à 1 m : nénuphars et plantes oxygénantes.';

  @override
  String get waterPh => 'pH';

  @override
  String get waterTemperature => 'Température';

  @override
  String get waterAmmonia => 'Ammoniaque';

  @override
  String get waterNitrite => 'Nitrites';

  @override
  String get waterNitrate => 'Nitrates';

  @override
  String get waterKh => 'KH';

  @override
  String get waterGh => 'GH';

  @override
  String get waterPhExplanation =>
      'Un pH instable stresse les koï et rend l\'ammoniaque plus toxique.';

  @override
  String get waterTemperatureExplanation =>
      'Sous 10 °C les koï ralentissent ; au-dessus de 28 °C l\'eau manque d\'oxygène.';

  @override
  String get waterAmmoniaExplanation =>
      'L\'ammoniaque brûle les branchies. Sa présence signale un filtre débordé.';

  @override
  String get waterNitriteExplanation =>
      'Les nitrites asphyxient les koï en bloquant le transport de l\'oxygène.';

  @override
  String get waterNitrateExplanation =>
      'Les nitrates s\'accumulent lentement. Ils se corrigent par des changements d\'eau.';

  @override
  String get waterKhExplanation =>
      'Le KH tamponne le pH. Trop bas, le pH peut s\'effondrer d\'un coup.';

  @override
  String get waterGhExplanation =>
      'Le GH mesure la dureté générale, qui soutient l\'osmorégulation des koï.';

  @override
  String waterReadingSummary(String parameter, String value, String unit) {
    return '$parameter : $value $unit';
  }

  @override
  String get waterConditionIdeal => 'SAIN';

  @override
  String get waterConditionWarning => 'ALERTE';

  @override
  String get waterConditionDanger => 'DANGER';

  @override
  String get waterSummaryIdeal => 'Eau saine';

  @override
  String get waterSummaryWarning => 'Eau à surveiller';

  @override
  String get waterSummaryDanger => 'Eau en danger';

  @override
  String get waterAdviceIdeal =>
      'Les paramètres relevés sont dans la bonne plage.';

  @override
  String get waterAdviceWarning =>
      'Un paramètre s\'écarte de la plage idéale. À surveiller.';

  @override
  String get waterAdviceDanger =>
      'Un paramètre est hors plage. Intervenez sans attendre.';

  @override
  String get pendingWrite =>
      'Enregistré sur l\'appareil : l\'envoi se fera au retour du réseau.';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Valider';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get sessionExpired => 'Session expirée';

  @override
  String get sessionExpiredSignIn => 'Session expirée, reconnectez-vous.';

  @override
  String saveError(Object error) {
    return 'Erreur lors de la sauvegarde : $error';
  }

  @override
  String deleteError(Object error) {
    return 'Suppression impossible : $error';
  }

  @override
  String get formNameRequired => 'Veuillez entrer un nom';

  @override
  String get formRequired => 'Obligatoire';

  @override
  String get formSaveChanges => 'Enregistrer les modifications';

  @override
  String get dateNotSet => 'Non renseignée';

  @override
  String get koiFormBirthDateHelp => 'Date de naissance du koï';

  @override
  String get koiFormBirthDate => 'Date de naissance';

  @override
  String get koiUpdated => 'Fiche mise à jour.';

  @override
  String get koiAdded => 'Carpe koï ajoutée.';

  @override
  String koiDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get koiDeleteBody =>
      'La fiche, son historique de croissance et sa photo seront effacés définitivement.\n\nLes koï qui la désignent comme parent garderont la trace d\'une filiation, marquée comme introuvable.';

  @override
  String koiDeleted(String name) {
    return '$name a été supprimé.';
  }

  @override
  String get koiFormTitleEdit => 'Modifier la fiche';

  @override
  String get koiFormTitleAdd => 'Ajouter un koï';

  @override
  String get koiDeleteTooltip => 'Supprimer ce koï';

  @override
  String get koiFormSectionBasics => 'Informations de base';

  @override
  String get koiFormName => 'Nom du koï';

  @override
  String get koiFormVariety => 'Variété (ex : Kohaku)';

  @override
  String get koiFormVarietyRequired => 'Veuillez entrer une variété';

  @override
  String get koiFormSize => 'Taille (cm)';

  @override
  String get koiFormSizeInvalid => 'Taille invalide';

  @override
  String get koiFormSizeUnrealistic => 'Taille irréaliste';

  @override
  String get koiFormSectionIdentity => 'Naissance & identité';

  @override
  String get koiFormSex => 'Sexe';

  @override
  String get koiFormStatus => 'Statut';

  @override
  String get koiFormBreeder => 'Éleveur (optionnel)';

  @override
  String get koiFormOrigin => 'Provenance (optionnel)';

  @override
  String get koiFormSectionLineage => 'Généalogie & origines';

  @override
  String get koiFormSectionNotes => 'Notes';

  @override
  String get koiFormNotesHint => 'Observations, particularités…';

  @override
  String get koiFormSave => 'Sauvegarder la carpe';

  @override
  String get koiFormClearDate => 'Effacer la date';

  @override
  String get koiFather => 'Père';

  @override
  String get koiMother => 'Mère';

  @override
  String get koiFatherManual => 'Nom / variété du père';

  @override
  String get koiMotherManual => 'Nom / variété de la mère';

  @override
  String get parentNotSet => 'Non renseigné';

  @override
  String get parentManual => 'Saisie manuelle / autre origine';

  @override
  String get koiUnnamed => 'Sans nom';

  @override
  String errorDetail(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get koiNotFound => 'Ce koï n\'existe plus.';

  @override
  String get koiSectionGallery => 'Galerie';

  @override
  String get koiSectionIdentity => 'Identité';

  @override
  String get koiSectionOrigin => 'Provenance';

  @override
  String get koiSectionLineage => 'Généalogie';

  @override
  String get koiSectionGrowth => 'Croissance';

  @override
  String get photoUploading => 'Envoi de la photo…';

  @override
  String get koiPhotoAdded => 'Photo ajoutée à la galerie.';

  @override
  String uploadError(Object error) {
    return 'Erreur lors du transfert : $error';
  }

  @override
  String get koiListTitle => 'Mes koï';

  @override
  String get koiListEmptyTitle => 'Votre collection est vide';

  @override
  String get koiListEmptyMessage =>
      'Ajoutez vos premières carpes koï pour suivre leur croissance et leur lignée.';

  @override
  String get parentManualShort => 'Saisie manuelle';

  @override
  String get parentUnknown => 'Inconnu';

  @override
  String get parentNotFound => 'Introuvable';

  @override
  String get loading => 'Chargement';

  @override
  String get varietyUnknown => 'Variété inconnue';

  @override
  String get koiLastSize => 'Dernière taille mesurée';

  @override
  String get koiMeasure => 'Mesurer';

  @override
  String get koiGrowthEmpty =>
      'Enregistrez une mesure pour tracer la courbe de croissance.';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get koiVariety => 'Variété';

  @override
  String get koiAge => 'Âge';

  @override
  String get koiBirthDateMissing => 'Date de naissance à renseigner';

  @override
  String koiBornOn(String date) {
    return 'Né le $date';
  }

  @override
  String get koiAgeApprox => 'Âge approximatif repris de l\'ancienne fiche';

  @override
  String get tapToAdd => 'Appuyez pour l\'ajouter';

  @override
  String koiYearClass(String yearClass) {
    return 'Classe d\'âge : $yearClass';
  }

  @override
  String koiBirthDateOf(String name) {
    return 'Date de naissance de $name';
  }

  @override
  String get commonSave => 'Enregistrer';

  @override
  String koiBirthDateError(Object error) {
    return 'Impossible d\'enregistrer la date : $error';
  }

  @override
  String get koiBreeder => 'Éleveur';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get photoMain => 'Photo principale';

  @override
  String get photo => 'Photo';

  @override
  String get photoMainBadge => 'PRINCIPALE';

  @override
  String get commonClose => 'Fermer';

  @override
  String get photoSetMain => 'Définir comme principale';

  @override
  String updateError(Object error) {
    return 'Modification impossible : $error';
  }

  @override
  String get photoDeleteTitle => 'Supprimer cette photo ?';

  @override
  String get photoDeleteBody => 'Le cliché sera définitivement effacé.';

  @override
  String get sizeInvalidCm => 'Entrez une taille valide, en centimètres.';

  @override
  String saveImpossible(Object error) {
    return 'Enregistrement impossible : $error';
  }

  @override
  String get koiUpdateSize => 'Mettre à jour la taille';

  @override
  String get koiUpdateSizeHint =>
      'Elle sera ajoutée à la courbe de croissance.';

  @override
  String get koiNewSize => 'Nouvelle taille';

  @override
  String get koiConfirmMeasure => 'Confirmer la mesure';

  @override
  String get plantNotFound => 'Cette plante n\'existe plus.';

  @override
  String get plantFormTitleEdit => 'Modifier la plante';

  @override
  String get plantFormTitleAdd => 'Ajouter une plante';

  @override
  String get plantSectionPlanting => 'Plantation';

  @override
  String get plantZone => 'Zone';

  @override
  String get plantQuantity => 'Quantité';

  @override
  String get plantPlanted => 'Plantée';

  @override
  String get plantDepth => 'Profondeur';

  @override
  String get photoUpdated => 'Photo mise à jour.';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get plantFloatingBadge => 'FLOTTANTE';

  @override
  String get plantOxygenatingBadge => 'OXYGÉNANTE';

  @override
  String get plantFormDate => 'Date de plantation';

  @override
  String get plantUpdated => 'Plante mise à jour.';

  @override
  String get plantAdded => 'Plante ajoutée.';

  @override
  String plantDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get plantDeleteBody => 'La fiche et sa photo seront effacées.';

  @override
  String plantDeleted(String name) {
    return '$name a été supprimée.';
  }

  @override
  String get plantDeleteTooltip => 'Supprimer cette plante';

  @override
  String get plantFormName => 'Nom (ex : Nénuphar rose)';

  @override
  String get plantFormSpecies => 'Espèce ou variété (optionnel)';

  @override
  String get plantFormQuantity => 'Nombre de pots ou de pieds';

  @override
  String get formAtLeastOne => 'Au moins 1';

  @override
  String get formUnrealistic => 'Valeur irréaliste';

  @override
  String get plantSectionZone => 'Zone de plantation';

  @override
  String get plantFloating => 'Flottante';

  @override
  String get plantFloatingHint =>
      'Non enracinée : elle ombrage l\'eau et abrite les alevins.';

  @override
  String get plantOxygenating => 'Oxygénante';

  @override
  String get plantOxygenatingHint =>
      'Immergée : elle consomme les nitrates et produit l\'oxygène.';

  @override
  String get plantFormNotesHint => 'Division, engrais, hivernage…';

  @override
  String get plantFormSave => 'Ajouter la plante';

  @override
  String plantZoneUpTo(String zone, int depth) {
    return '$zone · jusqu\'à $depth cm';
  }

  @override
  String get plantListTitle => 'Plantes';

  @override
  String get plantListEmptyTitle => 'Aucune plante';

  @override
  String get plantListEmptyMessage =>
      'Nénuphars, iris, oxygénantes… Notez ce que vous plantez, où, et quand.';

  @override
  String get pondSeeAll => 'Voir tout';

  @override
  String get pondOtherFish => 'Autres habitants';

  @override
  String get pondNewReading => 'Nouvelle mesure';

  @override
  String get pondPhotoUpdated => 'Photo du bassin mise à jour.';

  @override
  String get pondPhotoRemoved => 'Photo retirée : retour à l\'eau.';

  @override
  String get pondOptions => 'Options du bassin';

  @override
  String get pondEdit => 'Modifier le bassin';

  @override
  String get pondAddPhoto => 'Ajouter une photo du bassin';

  @override
  String get pondRemovePhoto => 'Retirer la photo, revenir à l\'eau';

  @override
  String pondDepthCm(String depth) {
    return '$depth cm de profondeur';
  }

  @override
  String get pondWelcome => 'Bienvenue dans votre écosystème,';

  @override
  String get pondDefaultName => 'Mon bassin';

  @override
  String get pondNoReading => 'AUCUN RELEVÉ';

  @override
  String get formInvalidValue => 'Valeur invalide';

  @override
  String get pondFormName => 'Nom du bassin';

  @override
  String get pondSectionDimensions => 'Dimensions';

  @override
  String get pondFormVolume => 'Volume (L)';

  @override
  String get pondFormDepth => 'Profondeur (cm)';

  @override
  String get pondFormNotesHint => 'Filtration, exposition, historique…';

  @override
  String get fishFormDate => 'Date d\'introduction';

  @override
  String get fishUpdated => 'Groupe mis à jour.';

  @override
  String get fishAdded => 'Groupe ajouté.';

  @override
  String fishDeleteTitle(String species) {
    return 'Supprimer $species ?';
  }

  @override
  String get fishDeleteBody => 'Le groupe et sa photo seront effacés.';

  @override
  String get fishDeleted => 'Groupe supprimé.';

  @override
  String get fishFormTitleEdit => 'Modifier le groupe';

  @override
  String get fishFormTitleAdd => 'Ajouter des poissons';

  @override
  String get fishDeleteTooltip => 'Supprimer ce groupe';

  @override
  String get fishSectionSpecies => 'Espèce';

  @override
  String get fishFormSpecies => 'Espèce (ex : Ide mélanote, Esturgeon)';

  @override
  String get fishFormSpeciesRequired => 'Veuillez entrer l\'espèce';

  @override
  String get fishFormCount => 'Effectif';

  @override
  String get fishSectionIntroduction => 'Introduction';

  @override
  String get fishFormNotesHint => 'Origine, comportement, pertes…';

  @override
  String get fishFormSave => 'Ajouter le groupe';

  @override
  String get fishChangePhoto => 'Changer la photo du groupe';

  @override
  String get fishAddPhoto => 'Ajouter une photo du groupe';

  @override
  String get fishEmptyTitle => 'Aucun autre habitant';

  @override
  String get fishEmptyMessage =>
      'Esturgeons, ides, carassins… Notez les espèces qui partagent le bassin avec vos koï.';

  @override
  String fishSummary(int fish, int groups) {
    String _temp0 = intl.Intl.pluralLogic(
      fish,
      locale: localeName,
      other: '$fish poissons',
      one: '$fish poisson',
    );
    String _temp1 = intl.Intl.pluralLogic(
      groups,
      locale: localeName,
      other: '$groups groupes',
      one: '$groups groupe',
    );
    return '$_temp0 en $_temp1';
  }

  @override
  String get fishDateUnknown => 'Date d\'introduction inconnue';

  @override
  String fishSince(String date) {
    return 'Depuis $date';
  }

  @override
  String get sceneEmpty => 'Bassin vide';

  @override
  String sceneWithKoi(int count, String names) {
    return 'Bassin avec $count koï : $names';
  }

  @override
  String get readingSaved => 'Mesure enregistrée !';

  @override
  String formBetween(double min, double max) {
    final intl.NumberFormat minNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String minString = minNumberFormat.format(min);
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'Entre $minString et $maxString';
  }

  @override
  String get readingSectionMain => 'Relevé principal';

  @override
  String get readingPhLabel => 'pH (ex : 7,2)';

  @override
  String get readingTempLabel => 'Température (°C)';

  @override
  String get readingSectionNitrogen => 'Cycle de l\'azote (optionnel)';

  @override
  String get readingAmmoniaLabel => 'Ammoniaque NH₃/NH₄ (mg/L)';

  @override
  String get readingSectionHardness => 'Duretés (optionnel)';

  @override
  String get readingSave => 'Enregistrer la mesure';

  @override
  String get historyTitle => 'Historique des mesures';

  @override
  String get historyEmptyTitle => 'Aucun relevé';

  @override
  String get historyEmptyMessage =>
      'Les mesures que vous enregistrez apparaîtront ici.';

  @override
  String get readingAdd => 'Ajouter une mesure';

  @override
  String get readingDeleteTitle => 'Supprimer ce relevé ?';

  @override
  String get readingDeleteBody =>
      'Il disparaîtra de l\'historique et des courbes. Cette action est définitive.';

  @override
  String get readingDeleted => 'Relevé supprimé.';

  @override
  String get readingDeleteTooltip => 'Supprimer ce relevé';

  @override
  String get dateUnknown => 'Date inconnue';

  @override
  String get waterTitle => 'Eau';

  @override
  String get waterHistory => 'Historique';

  @override
  String get waterEmptyTitle => 'Aucune analyse d\'eau';

  @override
  String get waterEmptyMessage =>
      'Enregistrez votre premier relevé pour suivre la qualité du bassin.';

  @override
  String get waterLatest => 'Dernier relevé';

  @override
  String get waterPhTrend => 'Évolution du pH';

  @override
  String get waterTempTrend => 'Suivi de la température';

  @override
  String get chartNoData => 'Aucune donnée pour le moment';

  @override
  String get bannerHealthy => 'Bassin en bonne santé';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDisplay => 'Affichage';

  @override
  String get profileTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get profileReducedMotion => 'Animations réduites';

  @override
  String get profileReducedMotionHint =>
      'Fige la scène du bassin et les transitions. Utile sur un appareil modeste.';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteAccountButton => 'Supprimer mon compte et mes données';

  @override
  String get profileDefaultName => 'Passionné';

  @override
  String get pondDimensionsMissing => 'Volume et profondeur à renseigner';

  @override
  String get deleteIdentityFailed =>
      'La vérification d\'identité a échoué. Rien n\'a été supprimé.';

  @override
  String get deleteNeedsInternet =>
      'Connexion à Internet requise : la suppression n\'a pas pu aboutir. Relancez-la une fois connecté, elle reprendra là où elle s\'est arrêtée.';

  @override
  String deleteInterrupted(Object error) {
    return 'La suppression s\'est interrompue ($error). Relancez-la : elle reprendra là où elle s\'est arrêtée.';
  }

  @override
  String get deleteAccountDone =>
      'Votre compte et toutes vos données ont été supprimés.';

  @override
  String get deleteAccountNeedsConfirmation =>
      'Vos données sont effacées, mais le compte n\'a pas pu l\'être sans confirmation. Relancez la suppression.';

  @override
  String deleteAccountFailed(String code) {
    return 'Vos données sont effacées, mais le compte n\'a pas pu l\'être ($code). Relancez la suppression.';
  }

  @override
  String deleteWrongAccount(String provider) {
    return 'Ce n\'est pas le compte $provider connecté. Choisissez le même compte. Rien n\'a été supprimé.';
  }

  @override
  String deletePopupBlocked(String provider) {
    return 'La fenêtre $provider n\'a pas pu s\'ouvrir. Déconnectez-vous, reconnectez-vous, puis relancez la suppression dans les cinq minutes.';
  }

  @override
  String get deleteNoInternet =>
      'Pas de connexion à Internet. Rien n\'a été supprimé.';

  @override
  String deleteIdentityFailedCode(String code) {
    return 'La vérification d\'identité a échoué ($code). Rien n\'a été supprimé.';
  }

  @override
  String get deleteAccountConfirmWord => 'SUPPRIMER';

  @override
  String get deleteAccountTitle => 'Supprimer votre compte ?';

  @override
  String get deleteAccountBody =>
      'Tout sera effacé définitivement : vos koï et leurs photos, leur croissance, vos relevés d\'eau, vos plantes, vos autres poissons et votre bassin. Rien ne pourra être récupéré.';

  @override
  String deleteAccountIdentityHint(String provider) {
    return '$provider vous demandera peut-être de confirmer votre identité.';
  }

  @override
  String deleteAccountTypeWord(String word) {
    return 'Tapez $word pour confirmer';
  }

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String get deleteInProgress => 'Suppression de vos données…';

  @override
  String get loginFailed => 'La connexion a échoué. Réessayez.';

  @override
  String get loginNoNetwork =>
      'Connexion impossible : vérifiez votre accès à Internet.';

  @override
  String get loginAccountExists =>
      'Un compte existe déjà avec cette adresse : connectez-vous comme la première fois, avec Google ou avec Apple.';

  @override
  String get loginUnauthorizedDomain =>
      'Ce domaine n\'est pas autorisé dans la console Firebase.';

  @override
  String get loginTagline => 'Le carnet de votre bassin';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get navPond => 'Bassin';

  @override
  String get navKoi => 'Koï';

  @override
  String get pondNotFound => 'Bassin introuvable.';

  @override
  String get fishNotFound => 'Ce groupe n\'existe plus.';

  @override
  String privacyOpenError(String url) {
    return 'Impossible d\'ouvrir la page : $url';
  }

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get errorPermission =>
      'Accès refusé par les règles de sécurité. Vérifiez que vous êtes bien connecté au bon compte.';

  @override
  String get errorNetwork =>
      'Connexion au serveur impossible. Vérifiez votre accès à Internet.';

  @override
  String get errorIndex =>
      'Un index Firestore manque pour cette requête. Déployez les index du projet.';

  @override
  String get errorLoading => 'Une erreur est survenue pendant le chargement.';

  @override
  String get loadFailed => 'Chargement impossible';
}
