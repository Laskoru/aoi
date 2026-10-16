import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @koiSexUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Indéterminé'**
  String get koiSexUnknown;

  /// No description provided for @koiSexMale.
  ///
  /// In fr, this message translates to:
  /// **'Mâle'**
  String get koiSexMale;

  /// No description provided for @koiSexFemale.
  ///
  /// In fr, this message translates to:
  /// **'Femelle'**
  String get koiSexFemale;

  /// No description provided for @koiStatusAlive.
  ///
  /// In fr, this message translates to:
  /// **'Vivant'**
  String get koiStatusAlive;

  /// No description provided for @koiStatusDeceased.
  ///
  /// In fr, this message translates to:
  /// **'Décédé'**
  String get koiStatusDeceased;

  /// No description provided for @koiStatusSold.
  ///
  /// In fr, this message translates to:
  /// **'Vendu'**
  String get koiStatusSold;

  /// No description provided for @koiStatusGiven.
  ///
  /// In fr, this message translates to:
  /// **'Donné'**
  String get koiStatusGiven;

  /// No description provided for @ageUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Âge inconnu'**
  String get ageUnknown;

  /// No description provided for @ageLessThanAMonth.
  ///
  /// In fr, this message translates to:
  /// **'Moins d\'un mois'**
  String get ageLessThanAMonth;

  /// No description provided for @ageMonths.
  ///
  /// In fr, this message translates to:
  /// **'{months, plural, =1{1 mois} other{{months} mois}}'**
  String ageMonths(int months);

  /// No description provided for @ageYears.
  ///
  /// In fr, this message translates to:
  /// **'{years, plural, =1{1 an} other{{years} ans}}'**
  String ageYears(int years);

  /// Âge approximatif des fiches anciennes, saisi en années.
  ///
  /// In fr, this message translates to:
  /// **'{years, plural, =1{~1 an} other{~{years} ans}}'**
  String ageApproxYears(int years);

  /// Assemble ageYears et ageMonths : « 3 ans et 2 mois ».
  ///
  /// In fr, this message translates to:
  /// **'{years} et {months}'**
  String ageYearsAndMonths(String years, String months);

  /// No description provided for @yearClassOver.
  ///
  /// In fr, this message translates to:
  /// **'Plus de {count} ans'**
  String yearClassOver(int count);

  /// No description provided for @plantZoneBerge.
  ///
  /// In fr, this message translates to:
  /// **'Berge'**
  String get plantZoneBerge;

  /// No description provided for @plantZoneMarecage.
  ///
  /// In fr, this message translates to:
  /// **'Marécage'**
  String get plantZoneMarecage;

  /// No description provided for @plantZoneImmergee.
  ///
  /// In fr, this message translates to:
  /// **'Immergée'**
  String get plantZoneImmergee;

  /// No description provided for @plantZoneProfonde.
  ///
  /// In fr, this message translates to:
  /// **'Profonde'**
  String get plantZoneProfonde;

  /// No description provided for @plantZoneBergeDescription.
  ///
  /// In fr, this message translates to:
  /// **'Sol humide, jamais immergé : carex, joncs, iris des marais.'**
  String get plantZoneBergeDescription;

  /// No description provided for @plantZoneMarecageDescription.
  ///
  /// In fr, this message translates to:
  /// **'De 0 à 20 cm d\'eau : iris, sagittaires, cyperus.'**
  String get plantZoneMarecageDescription;

  /// No description provided for @plantZoneImmergeeDescription.
  ///
  /// In fr, this message translates to:
  /// **'De 20 à 40 cm : plantes émergées, racines sous l\'eau.'**
  String get plantZoneImmergeeDescription;

  /// No description provided for @plantZoneProfondeDescription.
  ///
  /// In fr, this message translates to:
  /// **'De 40 cm à 1 m : nénuphars et plantes oxygénantes.'**
  String get plantZoneProfondeDescription;

  /// No description provided for @waterPh.
  ///
  /// In fr, this message translates to:
  /// **'pH'**
  String get waterPh;

  /// No description provided for @waterTemperature.
  ///
  /// In fr, this message translates to:
  /// **'Température'**
  String get waterTemperature;

  /// No description provided for @waterAmmonia.
  ///
  /// In fr, this message translates to:
  /// **'Ammoniaque'**
  String get waterAmmonia;

  /// No description provided for @waterNitrite.
  ///
  /// In fr, this message translates to:
  /// **'Nitrites'**
  String get waterNitrite;

  /// No description provided for @waterNitrate.
  ///
  /// In fr, this message translates to:
  /// **'Nitrates'**
  String get waterNitrate;

  /// No description provided for @waterKh.
  ///
  /// In fr, this message translates to:
  /// **'KH'**
  String get waterKh;

  /// No description provided for @waterGh.
  ///
  /// In fr, this message translates to:
  /// **'GH'**
  String get waterGh;

  /// No description provided for @waterPhExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Un pH instable stresse les koï et rend l\'ammoniaque plus toxique.'**
  String get waterPhExplanation;

  /// No description provided for @waterTemperatureExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Sous 10 °C les koï ralentissent ; au-dessus de 28 °C l\'eau manque d\'oxygène.'**
  String get waterTemperatureExplanation;

  /// No description provided for @waterAmmoniaExplanation.
  ///
  /// In fr, this message translates to:
  /// **'L\'ammoniaque brûle les branchies. Sa présence signale un filtre débordé.'**
  String get waterAmmoniaExplanation;

  /// No description provided for @waterNitriteExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Les nitrites asphyxient les koï en bloquant le transport de l\'oxygène.'**
  String get waterNitriteExplanation;

  /// No description provided for @waterNitrateExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Les nitrates s\'accumulent lentement. Ils se corrigent par des changements d\'eau.'**
  String get waterNitrateExplanation;

  /// No description provided for @waterKhExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Le KH tamponne le pH. Trop bas, le pH peut s\'effondrer d\'un coup.'**
  String get waterKhExplanation;

  /// No description provided for @waterGhExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Le GH mesure la dureté générale, qui soutient l\'osmorégulation des koï.'**
  String get waterGhExplanation;

  /// Une valeur relevée dans le bandeau : « Nitrites : 0.15 mg/L ». L'unité peut être vide (pH).
  ///
  /// In fr, this message translates to:
  /// **'{parameter} : {value} {unit}'**
  String waterReadingSummary(String parameter, String value, String unit);

  /// Badge d'un paramètre dans sa plage, en capitales.
  ///
  /// In fr, this message translates to:
  /// **'SAIN'**
  String get waterConditionIdeal;

  /// Badge d'un paramètre un peu hors plage, en capitales.
  ///
  /// In fr, this message translates to:
  /// **'ALERTE'**
  String get waterConditionWarning;

  /// Badge d'un paramètre hors plage, en capitales.
  ///
  /// In fr, this message translates to:
  /// **'DANGER'**
  String get waterConditionDanger;

  /// No description provided for @waterSummaryIdeal.
  ///
  /// In fr, this message translates to:
  /// **'Eau saine'**
  String get waterSummaryIdeal;

  /// No description provided for @waterSummaryWarning.
  ///
  /// In fr, this message translates to:
  /// **'Eau à surveiller'**
  String get waterSummaryWarning;

  /// No description provided for @waterSummaryDanger.
  ///
  /// In fr, this message translates to:
  /// **'Eau en danger'**
  String get waterSummaryDanger;

  /// No description provided for @waterAdviceIdeal.
  ///
  /// In fr, this message translates to:
  /// **'Les paramètres relevés sont dans la bonne plage.'**
  String get waterAdviceIdeal;

  /// No description provided for @waterAdviceWarning.
  ///
  /// In fr, this message translates to:
  /// **'Un paramètre s\'écarte de la plage idéale. À surveiller.'**
  String get waterAdviceWarning;

  /// No description provided for @waterAdviceDanger.
  ///
  /// In fr, this message translates to:
  /// **'Un paramètre est hors plage. Intervenez sans attendre.'**
  String get waterAdviceDanger;

  /// No description provided for @pendingWrite.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré sur l\'appareil : l\'envoi se fera au retour du réseau.'**
  String get pendingWrite;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @sessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée'**
  String get sessionExpired;

  /// No description provided for @sessionExpiredSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Session expirée, reconnectez-vous.'**
  String get sessionExpiredSignIn;

  /// No description provided for @saveError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la sauvegarde : {error}'**
  String saveError(Object error);

  /// No description provided for @deleteError.
  ///
  /// In fr, this message translates to:
  /// **'Suppression impossible : {error}'**
  String deleteError(Object error);

  /// No description provided for @formNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom'**
  String get formNameRequired;

  /// No description provided for @formRequired.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get formRequired;

  /// No description provided for @formSaveChanges.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get formSaveChanges;

  /// Date absente (féminin en français).
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée'**
  String get dateNotSet;

  /// No description provided for @koiFormBirthDateHelp.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance du koï'**
  String get koiFormBirthDateHelp;

  /// No description provided for @koiFormBirthDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get koiFormBirthDate;

  /// No description provided for @koiUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Fiche mise à jour.'**
  String get koiUpdated;

  /// No description provided for @koiAdded.
  ///
  /// In fr, this message translates to:
  /// **'Carpe koï ajoutée.'**
  String get koiAdded;

  /// No description provided for @koiDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name} ?'**
  String koiDeleteTitle(String name);

  /// No description provided for @koiDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'La fiche, son historique de croissance et sa photo seront effacés définitivement.\n\nLes koï qui la désignent comme parent garderont la trace d\'une filiation, marquée comme introuvable.'**
  String get koiDeleteBody;

  /// No description provided for @koiDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{name} a été supprimé.'**
  String koiDeleted(String name);

  /// No description provided for @koiFormTitleEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get koiFormTitleEdit;

  /// No description provided for @koiFormTitleAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un koï'**
  String get koiFormTitleAdd;

  /// No description provided for @koiDeleteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce koï'**
  String get koiDeleteTooltip;

  /// No description provided for @koiFormSectionBasics.
  ///
  /// In fr, this message translates to:
  /// **'Informations de base'**
  String get koiFormSectionBasics;

  /// No description provided for @koiFormName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du koï'**
  String get koiFormName;

  /// No description provided for @koiFormVariety.
  ///
  /// In fr, this message translates to:
  /// **'Variété (ex : Kohaku)'**
  String get koiFormVariety;

  /// No description provided for @koiFormVarietyRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer une variété'**
  String get koiFormVarietyRequired;

  /// No description provided for @koiFormSize.
  ///
  /// In fr, this message translates to:
  /// **'Taille (cm)'**
  String get koiFormSize;

  /// No description provided for @koiFormSizeInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Taille invalide'**
  String get koiFormSizeInvalid;

  /// No description provided for @koiFormSizeUnrealistic.
  ///
  /// In fr, this message translates to:
  /// **'Taille irréaliste'**
  String get koiFormSizeUnrealistic;

  /// No description provided for @koiFormSectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Naissance & identité'**
  String get koiFormSectionIdentity;

  /// No description provided for @koiFormSex.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get koiFormSex;

  /// No description provided for @koiFormStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get koiFormStatus;

  /// No description provided for @koiFormBreeder.
  ///
  /// In fr, this message translates to:
  /// **'Éleveur (optionnel)'**
  String get koiFormBreeder;

  /// No description provided for @koiFormOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Provenance (optionnel)'**
  String get koiFormOrigin;

  /// No description provided for @koiFormSectionLineage.
  ///
  /// In fr, this message translates to:
  /// **'Généalogie & origines'**
  String get koiFormSectionLineage;

  /// No description provided for @koiFormSectionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get koiFormSectionNotes;

  /// No description provided for @koiFormNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Observations, particularités…'**
  String get koiFormNotesHint;

  /// No description provided for @koiFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder la carpe'**
  String get koiFormSave;

  /// No description provided for @koiFormClearDate.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la date'**
  String get koiFormClearDate;

  /// No description provided for @koiFather.
  ///
  /// In fr, this message translates to:
  /// **'Père'**
  String get koiFather;

  /// No description provided for @koiMother.
  ///
  /// In fr, this message translates to:
  /// **'Mère'**
  String get koiMother;

  /// No description provided for @koiFatherManual.
  ///
  /// In fr, this message translates to:
  /// **'Nom / variété du père'**
  String get koiFatherManual;

  /// No description provided for @koiMotherManual.
  ///
  /// In fr, this message translates to:
  /// **'Nom / variété de la mère'**
  String get koiMotherManual;

  /// Parent absent (masculin en français).
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get parentNotSet;

  /// No description provided for @parentManual.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle / autre origine'**
  String get parentManual;

  /// No description provided for @koiUnnamed.
  ///
  /// In fr, this message translates to:
  /// **'Sans nom'**
  String get koiUnnamed;

  /// No description provided for @errorDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorDetail(Object error);

  /// No description provided for @koiNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce koï n\'existe plus.'**
  String get koiNotFound;

  /// No description provided for @koiSectionGallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get koiSectionGallery;

  /// No description provided for @koiSectionIdentity.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get koiSectionIdentity;

  /// No description provided for @koiSectionOrigin.
  ///
  /// In fr, this message translates to:
  /// **'Provenance'**
  String get koiSectionOrigin;

  /// No description provided for @koiSectionLineage.
  ///
  /// In fr, this message translates to:
  /// **'Généalogie'**
  String get koiSectionLineage;

  /// No description provided for @koiSectionGrowth.
  ///
  /// In fr, this message translates to:
  /// **'Croissance'**
  String get koiSectionGrowth;

  /// No description provided for @photoUploading.
  ///
  /// In fr, this message translates to:
  /// **'Envoi de la photo…'**
  String get photoUploading;

  /// No description provided for @koiPhotoAdded.
  ///
  /// In fr, this message translates to:
  /// **'Photo ajoutée à la galerie.'**
  String get koiPhotoAdded;

  /// No description provided for @uploadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du transfert : {error}'**
  String uploadError(Object error);

  /// No description provided for @koiListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes koï'**
  String get koiListTitle;

  /// No description provided for @koiListEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre collection est vide'**
  String get koiListEmptyTitle;

  /// No description provided for @koiListEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos premières carpes koï pour suivre leur croissance et leur lignée.'**
  String get koiListEmptyMessage;

  /// No description provided for @parentManualShort.
  ///
  /// In fr, this message translates to:
  /// **'Saisie manuelle'**
  String get parentManualShort;

  /// No description provided for @parentUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get parentUnknown;

  /// No description provided for @parentNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable'**
  String get parentNotFound;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get loading;

  /// No description provided for @varietyUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Variété inconnue'**
  String get varietyUnknown;

  /// No description provided for @koiLastSize.
  ///
  /// In fr, this message translates to:
  /// **'Dernière taille mesurée'**
  String get koiLastSize;

  /// No description provided for @koiMeasure.
  ///
  /// In fr, this message translates to:
  /// **'Mesurer'**
  String get koiMeasure;

  /// No description provided for @koiGrowthEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez une mesure pour tracer la courbe de croissance.'**
  String get koiGrowthEmpty;

  /// No description provided for @addPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get addPhoto;

  /// No description provided for @koiVariety.
  ///
  /// In fr, this message translates to:
  /// **'Variété'**
  String get koiVariety;

  /// No description provided for @koiAge.
  ///
  /// In fr, this message translates to:
  /// **'Âge'**
  String get koiAge;

  /// No description provided for @koiBirthDateMissing.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance à renseigner'**
  String get koiBirthDateMissing;

  /// No description provided for @koiBornOn.
  ///
  /// In fr, this message translates to:
  /// **'Né le {date}'**
  String koiBornOn(String date);

  /// No description provided for @koiAgeApprox.
  ///
  /// In fr, this message translates to:
  /// **'Âge approximatif repris de l\'ancienne fiche'**
  String get koiAgeApprox;

  /// No description provided for @tapToAdd.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour l\'ajouter'**
  String get tapToAdd;

  /// No description provided for @koiYearClass.
  ///
  /// In fr, this message translates to:
  /// **'Classe d\'âge : {yearClass}'**
  String koiYearClass(String yearClass);

  /// No description provided for @koiBirthDateOf.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance de {name}'**
  String koiBirthDateOf(String name);

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @koiBirthDateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer la date : {error}'**
  String koiBirthDateError(Object error);

  /// No description provided for @koiBreeder.
  ///
  /// In fr, this message translates to:
  /// **'Éleveur'**
  String get koiBreeder;

  /// No description provided for @commonAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get commonAdd;

  /// No description provided for @photoMain.
  ///
  /// In fr, this message translates to:
  /// **'Photo principale'**
  String get photoMain;

  /// No description provided for @photo.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get photo;

  /// Badge sur la photo principale, en capitales.
  ///
  /// In fr, this message translates to:
  /// **'PRINCIPALE'**
  String get photoMainBadge;

  /// No description provided for @commonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get commonClose;

  /// No description provided for @photoSetMain.
  ///
  /// In fr, this message translates to:
  /// **'Définir comme principale'**
  String get photoSetMain;

  /// No description provided for @updateError.
  ///
  /// In fr, this message translates to:
  /// **'Modification impossible : {error}'**
  String updateError(Object error);

  /// No description provided for @photoDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette photo ?'**
  String get photoDeleteTitle;

  /// No description provided for @photoDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Le cliché sera définitivement effacé.'**
  String get photoDeleteBody;

  /// No description provided for @sizeInvalidCm.
  ///
  /// In fr, this message translates to:
  /// **'Entrez une taille valide, en centimètres.'**
  String get sizeInvalidCm;

  /// No description provided for @saveImpossible.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible : {error}'**
  String saveImpossible(Object error);

  /// No description provided for @koiUpdateSize.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour la taille'**
  String get koiUpdateSize;

  /// No description provided for @koiUpdateSizeHint.
  ///
  /// In fr, this message translates to:
  /// **'Elle sera ajoutée à la courbe de croissance.'**
  String get koiUpdateSizeHint;

  /// No description provided for @koiNewSize.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle taille'**
  String get koiNewSize;

  /// No description provided for @koiConfirmMeasure.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la mesure'**
  String get koiConfirmMeasure;

  /// No description provided for @plantNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette plante n\'existe plus.'**
  String get plantNotFound;

  /// No description provided for @plantFormTitleEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la plante'**
  String get plantFormTitleEdit;

  /// No description provided for @plantFormTitleAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une plante'**
  String get plantFormTitleAdd;

  /// No description provided for @plantSectionPlanting.
  ///
  /// In fr, this message translates to:
  /// **'Plantation'**
  String get plantSectionPlanting;

  /// No description provided for @plantZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone'**
  String get plantZone;

  /// No description provided for @plantQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get plantQuantity;

  /// No description provided for @plantPlanted.
  ///
  /// In fr, this message translates to:
  /// **'Plantée'**
  String get plantPlanted;

  /// No description provided for @plantDepth.
  ///
  /// In fr, this message translates to:
  /// **'Profondeur'**
  String get plantDepth;

  /// No description provided for @photoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo mise à jour.'**
  String get photoUpdated;

  /// No description provided for @changePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get changePhoto;

  /// Badge en capitales.
  ///
  /// In fr, this message translates to:
  /// **'FLOTTANTE'**
  String get plantFloatingBadge;

  /// Badge en capitales.
  ///
  /// In fr, this message translates to:
  /// **'OXYGÉNANTE'**
  String get plantOxygenatingBadge;

  /// No description provided for @plantFormDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de plantation'**
  String get plantFormDate;

  /// No description provided for @plantUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Plante mise à jour.'**
  String get plantUpdated;

  /// No description provided for @plantAdded.
  ///
  /// In fr, this message translates to:
  /// **'Plante ajoutée.'**
  String get plantAdded;

  /// No description provided for @plantDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {name} ?'**
  String plantDeleteTitle(String name);

  /// No description provided for @plantDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'La fiche et sa photo seront effacées.'**
  String get plantDeleteBody;

  /// No description provided for @plantDeleted.
  ///
  /// In fr, this message translates to:
  /// **'{name} a été supprimée.'**
  String plantDeleted(String name);

  /// No description provided for @plantDeleteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette plante'**
  String get plantDeleteTooltip;

  /// No description provided for @plantFormName.
  ///
  /// In fr, this message translates to:
  /// **'Nom (ex : Nénuphar rose)'**
  String get plantFormName;

  /// No description provided for @plantFormSpecies.
  ///
  /// In fr, this message translates to:
  /// **'Espèce ou variété (optionnel)'**
  String get plantFormSpecies;

  /// No description provided for @plantFormQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pots ou de pieds'**
  String get plantFormQuantity;

  /// No description provided for @formAtLeastOne.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 1'**
  String get formAtLeastOne;

  /// No description provided for @formUnrealistic.
  ///
  /// In fr, this message translates to:
  /// **'Valeur irréaliste'**
  String get formUnrealistic;

  /// No description provided for @plantSectionZone.
  ///
  /// In fr, this message translates to:
  /// **'Zone de plantation'**
  String get plantSectionZone;

  /// No description provided for @plantFloating.
  ///
  /// In fr, this message translates to:
  /// **'Flottante'**
  String get plantFloating;

  /// No description provided for @plantFloatingHint.
  ///
  /// In fr, this message translates to:
  /// **'Non enracinée : elle ombrage l\'eau et abrite les alevins.'**
  String get plantFloatingHint;

  /// No description provided for @plantOxygenating.
  ///
  /// In fr, this message translates to:
  /// **'Oxygénante'**
  String get plantOxygenating;

  /// No description provided for @plantOxygenatingHint.
  ///
  /// In fr, this message translates to:
  /// **'Immergée : elle consomme les nitrates et produit l\'oxygène.'**
  String get plantOxygenatingHint;

  /// No description provided for @plantFormNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Division, engrais, hivernage…'**
  String get plantFormNotesHint;

  /// No description provided for @plantFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter la plante'**
  String get plantFormSave;

  /// No description provided for @plantZoneUpTo.
  ///
  /// In fr, this message translates to:
  /// **'{zone} · jusqu\'à {depth} cm'**
  String plantZoneUpTo(String zone, int depth);

  /// No description provided for @plantListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Plantes'**
  String get plantListTitle;

  /// No description provided for @plantListEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune plante'**
  String get plantListEmptyTitle;

  /// No description provided for @plantListEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nénuphars, iris, oxygénantes… Notez ce que vous plantez, où, et quand.'**
  String get plantListEmptyMessage;

  /// No description provided for @pondSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get pondSeeAll;

  /// No description provided for @pondOtherFish.
  ///
  /// In fr, this message translates to:
  /// **'Autres habitants'**
  String get pondOtherFish;

  /// No description provided for @pondNewReading.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle mesure'**
  String get pondNewReading;

  /// No description provided for @pondPhotoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo du bassin mise à jour.'**
  String get pondPhotoUpdated;

  /// No description provided for @pondPhotoRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Photo retirée : retour à l\'eau.'**
  String get pondPhotoRemoved;

  /// No description provided for @pondOptions.
  ///
  /// In fr, this message translates to:
  /// **'Options du bassin'**
  String get pondOptions;

  /// No description provided for @pondEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le bassin'**
  String get pondEdit;

  /// No description provided for @pondAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo du bassin'**
  String get pondAddPhoto;

  /// No description provided for @pondRemovePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo, revenir à l\'eau'**
  String get pondRemovePhoto;

  /// No description provided for @pondDepthCm.
  ///
  /// In fr, this message translates to:
  /// **'{depth} cm de profondeur'**
  String pondDepthCm(String depth);

  /// No description provided for @pondWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans votre écosystème,'**
  String get pondWelcome;

  /// No description provided for @pondDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Mon bassin'**
  String get pondDefaultName;

  /// Pastille en capitales.
  ///
  /// In fr, this message translates to:
  /// **'AUCUN RELEVÉ'**
  String get pondNoReading;

  /// No description provided for @formInvalidValue.
  ///
  /// In fr, this message translates to:
  /// **'Valeur invalide'**
  String get formInvalidValue;

  /// No description provided for @pondFormName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du bassin'**
  String get pondFormName;

  /// No description provided for @pondSectionDimensions.
  ///
  /// In fr, this message translates to:
  /// **'Dimensions'**
  String get pondSectionDimensions;

  /// No description provided for @pondFormVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume (L)'**
  String get pondFormVolume;

  /// No description provided for @pondFormDepth.
  ///
  /// In fr, this message translates to:
  /// **'Profondeur (cm)'**
  String get pondFormDepth;

  /// No description provided for @pondFormNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtration, exposition, historique…'**
  String get pondFormNotesHint;

  /// No description provided for @fishFormDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'introduction'**
  String get fishFormDate;

  /// No description provided for @fishUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Groupe mis à jour.'**
  String get fishUpdated;

  /// No description provided for @fishAdded.
  ///
  /// In fr, this message translates to:
  /// **'Groupe ajouté.'**
  String get fishAdded;

  /// No description provided for @fishDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer {species} ?'**
  String fishDeleteTitle(String species);

  /// No description provided for @fishDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Le groupe et sa photo seront effacés.'**
  String get fishDeleteBody;

  /// No description provided for @fishDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Groupe supprimé.'**
  String get fishDeleted;

  /// No description provided for @fishFormTitleEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le groupe'**
  String get fishFormTitleEdit;

  /// No description provided for @fishFormTitleAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter des poissons'**
  String get fishFormTitleAdd;

  /// No description provided for @fishDeleteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce groupe'**
  String get fishDeleteTooltip;

  /// No description provided for @fishSectionSpecies.
  ///
  /// In fr, this message translates to:
  /// **'Espèce'**
  String get fishSectionSpecies;

  /// No description provided for @fishFormSpecies.
  ///
  /// In fr, this message translates to:
  /// **'Espèce (ex : Ide mélanote, Esturgeon)'**
  String get fishFormSpecies;

  /// No description provided for @fishFormSpeciesRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer l\'espèce'**
  String get fishFormSpeciesRequired;

  /// No description provided for @fishFormCount.
  ///
  /// In fr, this message translates to:
  /// **'Effectif'**
  String get fishFormCount;

  /// No description provided for @fishSectionIntroduction.
  ///
  /// In fr, this message translates to:
  /// **'Introduction'**
  String get fishSectionIntroduction;

  /// No description provided for @fishFormNotesHint.
  ///
  /// In fr, this message translates to:
  /// **'Origine, comportement, pertes…'**
  String get fishFormNotesHint;

  /// No description provided for @fishFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le groupe'**
  String get fishFormSave;

  /// No description provided for @fishChangePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo du groupe'**
  String get fishChangePhoto;

  /// No description provided for @fishAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo du groupe'**
  String get fishAddPhoto;

  /// No description provided for @fishEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun autre habitant'**
  String get fishEmptyTitle;

  /// No description provided for @fishEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Esturgeons, ides, carassins… Notez les espèces qui partagent le bassin avec vos koï.'**
  String get fishEmptyMessage;

  /// No description provided for @fishSummary.
  ///
  /// In fr, this message translates to:
  /// **'{fish, plural, one{{fish} poisson} other{{fish} poissons}} en {groups, plural, one{{groups} groupe} other{{groups} groupes}}'**
  String fishSummary(int fish, int groups);

  /// No description provided for @fishDateUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'introduction inconnue'**
  String get fishDateUnknown;

  /// No description provided for @fishSince.
  ///
  /// In fr, this message translates to:
  /// **'Depuis {date}'**
  String fishSince(String date);

  /// No description provided for @sceneEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Bassin vide'**
  String get sceneEmpty;

  /// No description provided for @sceneWithKoi.
  ///
  /// In fr, this message translates to:
  /// **'Bassin avec {count} koï : {names}'**
  String sceneWithKoi(int count, String names);

  /// No description provided for @readingSaved.
  ///
  /// In fr, this message translates to:
  /// **'Mesure enregistrée !'**
  String get readingSaved;

  /// No description provided for @formBetween.
  ///
  /// In fr, this message translates to:
  /// **'Entre {min} et {max}'**
  String formBetween(double min, double max);

  /// No description provided for @readingSectionMain.
  ///
  /// In fr, this message translates to:
  /// **'Relevé principal'**
  String get readingSectionMain;

  /// No description provided for @readingPhLabel.
  ///
  /// In fr, this message translates to:
  /// **'pH (ex : 7,2)'**
  String get readingPhLabel;

  /// No description provided for @readingTempLabel.
  ///
  /// In fr, this message translates to:
  /// **'Température (°C)'**
  String get readingTempLabel;

  /// No description provided for @readingSectionNitrogen.
  ///
  /// In fr, this message translates to:
  /// **'Cycle de l\'azote (optionnel)'**
  String get readingSectionNitrogen;

  /// No description provided for @readingAmmoniaLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ammoniaque NH₃/NH₄ (mg/L)'**
  String get readingAmmoniaLabel;

  /// No description provided for @readingSectionHardness.
  ///
  /// In fr, this message translates to:
  /// **'Duretés (optionnel)'**
  String get readingSectionHardness;

  /// No description provided for @readingSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la mesure'**
  String get readingSave;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des mesures'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun relevé'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les mesures que vous enregistrez apparaîtront ici.'**
  String get historyEmptyMessage;

  /// No description provided for @readingAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une mesure'**
  String get readingAdd;

  /// No description provided for @readingDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce relevé ?'**
  String get readingDeleteTitle;

  /// No description provided for @readingDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Il disparaîtra de l\'historique et des courbes. Cette action est définitive.'**
  String get readingDeleteBody;

  /// No description provided for @readingDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Relevé supprimé.'**
  String get readingDeleted;

  /// No description provided for @readingDeleteTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce relevé'**
  String get readingDeleteTooltip;

  /// No description provided for @dateUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Date inconnue'**
  String get dateUnknown;

  /// No description provided for @waterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Eau'**
  String get waterTitle;

  /// No description provided for @waterHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get waterHistory;

  /// No description provided for @waterEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune analyse d\'eau'**
  String get waterEmptyTitle;

  /// No description provided for @waterEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez votre premier relevé pour suivre la qualité du bassin.'**
  String get waterEmptyMessage;

  /// No description provided for @waterLatest.
  ///
  /// In fr, this message translates to:
  /// **'Dernier relevé'**
  String get waterLatest;

  /// No description provided for @waterPhTrend.
  ///
  /// In fr, this message translates to:
  /// **'Évolution du pH'**
  String get waterPhTrend;

  /// No description provided for @waterTempTrend.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de la température'**
  String get waterTempTrend;

  /// No description provided for @chartNoData.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée pour le moment'**
  String get chartNoData;

  /// No description provided for @bannerHealthy.
  ///
  /// In fr, this message translates to:
  /// **'Bassin en bonne santé'**
  String get bannerHealthy;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileDisplay.
  ///
  /// In fr, this message translates to:
  /// **'Affichage'**
  String get profileDisplay;

  /// No description provided for @profileTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get profileTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @profileReducedMotion.
  ///
  /// In fr, this message translates to:
  /// **'Animations réduites'**
  String get profileReducedMotion;

  /// No description provided for @profileReducedMotionHint.
  ///
  /// In fr, this message translates to:
  /// **'Fige la scène du bassin et les transitions. Utile sur un appareil modeste.'**
  String get profileReducedMotionHint;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @deleteAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer mon compte et mes données'**
  String get deleteAccountButton;

  /// Nom affiché quand le compte n'en a pas.
  ///
  /// In fr, this message translates to:
  /// **'Passionné'**
  String get profileDefaultName;

  /// No description provided for @pondDimensionsMissing.
  ///
  /// In fr, this message translates to:
  /// **'Volume et profondeur à renseigner'**
  String get pondDimensionsMissing;

  /// No description provided for @deleteIdentityFailed.
  ///
  /// In fr, this message translates to:
  /// **'La vérification d\'identité a échoué. Rien n\'a été supprimé.'**
  String get deleteIdentityFailed;

  /// No description provided for @deleteNeedsInternet.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à Internet requise : la suppression n\'a pas pu aboutir. Relancez-la une fois connecté, elle reprendra là où elle s\'est arrêtée.'**
  String get deleteNeedsInternet;

  /// No description provided for @deleteInterrupted.
  ///
  /// In fr, this message translates to:
  /// **'La suppression s\'est interrompue ({error}). Relancez-la : elle reprendra là où elle s\'est arrêtée.'**
  String deleteInterrupted(Object error);

  /// No description provided for @deleteAccountDone.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte et toutes vos données ont été supprimés.'**
  String get deleteAccountDone;

  /// No description provided for @deleteAccountNeedsConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont effacées, mais le compte n\'a pas pu l\'être sans confirmation. Relancez la suppression.'**
  String get deleteAccountNeedsConfirmation;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont effacées, mais le compte n\'a pas pu l\'être ({code}). Relancez la suppression.'**
  String deleteAccountFailed(String code);

  /// No description provided for @deleteWrongAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ce n\'est pas le compte {provider} connecté. Choisissez le même compte. Rien n\'a été supprimé.'**
  String deleteWrongAccount(String provider);

  /// No description provided for @deletePopupBlocked.
  ///
  /// In fr, this message translates to:
  /// **'La fenêtre {provider} n\'a pas pu s\'ouvrir. Déconnectez-vous, reconnectez-vous, puis relancez la suppression dans les cinq minutes.'**
  String deletePopupBlocked(String provider);

  /// No description provided for @deleteNoInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion à Internet. Rien n\'a été supprimé.'**
  String get deleteNoInternet;

  /// No description provided for @deleteIdentityFailedCode.
  ///
  /// In fr, this message translates to:
  /// **'La vérification d\'identité a échoué ({code}). Rien n\'a été supprimé.'**
  String deleteIdentityFailedCode(String code);

  /// Mot à taper pour confirmer la suppression du compte, en capitales.
  ///
  /// In fr, this message translates to:
  /// **'SUPPRIMER'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer votre compte ?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In fr, this message translates to:
  /// **'Tout sera effacé définitivement : vos koï et leurs photos, leur croissance, vos relevés d\'eau, vos plantes, vos autres poissons et votre bassin. Rien ne pourra être récupéré.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountIdentityHint.
  ///
  /// In fr, this message translates to:
  /// **'{provider} vous demandera peut-être de confirmer votre identité.'**
  String deleteAccountIdentityHint(String provider);

  /// No description provided for @deleteAccountTypeWord.
  ///
  /// In fr, this message translates to:
  /// **'Tapez {word} pour confirmer'**
  String deleteAccountTypeWord(String word);

  /// No description provided for @deleteForever.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement'**
  String get deleteForever;

  /// No description provided for @deleteInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Suppression de vos données…'**
  String get deleteInProgress;

  /// No description provided for @loginFailed.
  ///
  /// In fr, this message translates to:
  /// **'La connexion a échoué. Réessayez.'**
  String get loginFailed;

  /// No description provided for @loginNoNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible : vérifiez votre accès à Internet.'**
  String get loginNoNetwork;

  /// No description provided for @loginAccountExists.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse : connectez-vous comme la première fois, avec Google ou avec Apple.'**
  String get loginAccountExists;

  /// No description provided for @loginUnauthorizedDomain.
  ///
  /// In fr, this message translates to:
  /// **'Ce domaine n\'est pas autorisé dans la console Firebase.'**
  String get loginUnauthorizedDomain;

  /// No description provided for @loginTagline.
  ///
  /// In fr, this message translates to:
  /// **'Le carnet de votre bassin'**
  String get loginTagline;

  /// No description provided for @signInWithApple.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec Google'**
  String get signInWithGoogle;

  /// No description provided for @navPond.
  ///
  /// In fr, this message translates to:
  /// **'Bassin'**
  String get navPond;

  /// No description provided for @navKoi.
  ///
  /// In fr, this message translates to:
  /// **'Koï'**
  String get navKoi;

  /// No description provided for @pondNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bassin introuvable.'**
  String get pondNotFound;

  /// No description provided for @fishNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce groupe n\'existe plus.'**
  String get fishNotFound;

  /// No description provided for @privacyOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la page : {url}'**
  String privacyOpenError(String url);

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @errorPermission.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé par les règles de sécurité. Vérifiez que vous êtes bien connecté au bon compte.'**
  String get errorPermission;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur impossible. Vérifiez votre accès à Internet.'**
  String get errorNetwork;

  /// No description provided for @errorIndex.
  ///
  /// In fr, this message translates to:
  /// **'Un index Firestore manque pour cette requête. Déployez les index du projet.'**
  String get errorIndex;

  /// No description provided for @errorLoading.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue pendant le chargement.'**
  String get errorLoading;

  /// No description provided for @loadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Chargement impossible'**
  String get loadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
