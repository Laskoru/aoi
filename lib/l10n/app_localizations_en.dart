// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get koiSexUnknown => 'Unknown';

  @override
  String get koiSexMale => 'Male';

  @override
  String get koiSexFemale => 'Female';

  @override
  String get koiStatusAlive => 'Alive';

  @override
  String get koiStatusDeceased => 'Deceased';

  @override
  String get koiStatusSold => 'Sold';

  @override
  String get koiStatusGiven => 'Given away';

  @override
  String get ageUnknown => 'Age unknown';

  @override
  String get ageLessThanAMonth => 'Less than a month';

  @override
  String ageMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String ageYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String ageApproxYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '~$years years',
      one: '~1 year',
    );
    return '$_temp0';
  }

  @override
  String ageYearsAndMonths(String years, String months) {
    return '$years and $months';
  }

  @override
  String yearClassOver(int count) {
    return 'Over $count years';
  }

  @override
  String get plantZoneBerge => 'Bog';

  @override
  String get plantZoneMarecage => 'Marginal';

  @override
  String get plantZoneImmergee => 'Deep marginal';

  @override
  String get plantZoneProfonde => 'Deep water';

  @override
  String get plantZoneBergeDescription =>
      'Moist soil, never under water: sedges, rushes, yellow flag iris.';

  @override
  String get plantZoneMarecageDescription =>
      '0 to 20 cm of water: irises, arrowheads, cyperus.';

  @override
  String get plantZoneImmergeeDescription =>
      '20 to 40 cm: emergent plants, roots under water.';

  @override
  String get plantZoneProfondeDescription =>
      '40 cm to 1 m: water lilies and oxygenating plants.';

  @override
  String get waterPh => 'pH';

  @override
  String get waterTemperature => 'Temperature';

  @override
  String get waterAmmonia => 'Ammonia';

  @override
  String get waterNitrite => 'Nitrite';

  @override
  String get waterNitrate => 'Nitrate';

  @override
  String get waterKh => 'KH';

  @override
  String get waterGh => 'GH';

  @override
  String get waterPhExplanation =>
      'An unstable pH stresses koi and makes ammonia more toxic.';

  @override
  String get waterTemperatureExplanation =>
      'Below 10 °C koi slow down; above 28 °C the water runs short of oxygen.';

  @override
  String get waterAmmoniaExplanation =>
      'Ammonia burns the gills. Any trace of it points to an overloaded filter.';

  @override
  String get waterNitriteExplanation =>
      'Nitrite suffocates koi by blocking oxygen transport in the blood.';

  @override
  String get waterNitrateExplanation =>
      'Nitrate builds up slowly. Partial water changes bring it down.';

  @override
  String get waterKhExplanation =>
      'KH buffers the pH. When it runs too low, the pH can crash overnight.';

  @override
  String get waterGhExplanation =>
      'GH measures general hardness, which supports koi osmoregulation.';

  @override
  String waterReadingSummary(String parameter, String value, String unit) {
    return '$parameter: $value $unit';
  }

  @override
  String get waterConditionIdeal => 'GOOD';

  @override
  String get waterConditionWarning => 'WARNING';

  @override
  String get waterConditionDanger => 'DANGER';

  @override
  String get waterSummaryIdeal => 'Healthy water';

  @override
  String get waterSummaryWarning => 'Watch your water';

  @override
  String get waterSummaryDanger => 'Water in danger';

  @override
  String get waterAdviceIdeal => 'All readings are within the healthy range.';

  @override
  String get waterAdviceWarning =>
      'A reading is drifting out of the ideal range. Keep an eye on it.';

  @override
  String get waterAdviceDanger =>
      'A reading is out of range. Act without delay.';

  @override
  String get pendingWrite =>
      'Saved on this device. It will be sent once you\'re back online.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'OK';

  @override
  String get commonDelete => 'Delete';

  @override
  String get sessionExpired => 'Session expired';

  @override
  String get sessionExpiredSignIn => 'Session expired. Please sign in again.';

  @override
  String saveError(Object error) {
    return 'Could not save: $error';
  }

  @override
  String deleteError(Object error) {
    return 'Could not delete: $error';
  }

  @override
  String get formNameRequired => 'Please enter a name';

  @override
  String get formRequired => 'Required';

  @override
  String get formSaveChanges => 'Save changes';

  @override
  String get dateNotSet => 'Not set';

  @override
  String get koiFormBirthDateHelp => 'Koi\'s date of birth';

  @override
  String get koiFormBirthDate => 'Date of birth';

  @override
  String get koiUpdated => 'Koi updated.';

  @override
  String get koiAdded => 'Koi added.';

  @override
  String koiDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get koiDeleteBody =>
      'The record, its growth history and its photo will be permanently deleted.\n\nKoi that list it as a parent will keep a trace of their lineage, marked as not found.';

  @override
  String koiDeleted(String name) {
    return '$name has been deleted.';
  }

  @override
  String get koiFormTitleEdit => 'Edit koi';

  @override
  String get koiFormTitleAdd => 'Add a koi';

  @override
  String get koiDeleteTooltip => 'Delete this koi';

  @override
  String get koiFormSectionBasics => 'Basic information';

  @override
  String get koiFormName => 'Koi name';

  @override
  String get koiFormVariety => 'Variety (e.g. Kohaku)';

  @override
  String get koiFormVarietyRequired => 'Please enter a variety';

  @override
  String get koiFormSize => 'Size (cm)';

  @override
  String get koiFormSizeInvalid => 'Invalid size';

  @override
  String get koiFormSizeUnrealistic => 'Unrealistic size';

  @override
  String get koiFormSectionIdentity => 'Birth & identity';

  @override
  String get koiFormSex => 'Sex';

  @override
  String get koiFormStatus => 'Status';

  @override
  String get koiFormBreeder => 'Breeder (optional)';

  @override
  String get koiFormOrigin => 'Origin (optional)';

  @override
  String get koiFormSectionLineage => 'Lineage & origins';

  @override
  String get koiFormSectionNotes => 'Notes';

  @override
  String get koiFormNotesHint => 'Observations, distinctive traits…';

  @override
  String get koiFormSave => 'Save koi';

  @override
  String get koiFormClearDate => 'Clear date';

  @override
  String get koiFather => 'Father';

  @override
  String get koiMother => 'Mother';

  @override
  String get koiFatherManual => 'Father\'s name / variety';

  @override
  String get koiMotherManual => 'Mother\'s name / variety';

  @override
  String get parentNotSet => 'Not set';

  @override
  String get parentManual => 'Enter manually / other origin';

  @override
  String get koiUnnamed => 'Unnamed';

  @override
  String errorDetail(Object error) {
    return 'Error: $error';
  }

  @override
  String get koiNotFound => 'This koi no longer exists.';

  @override
  String get koiSectionGallery => 'Gallery';

  @override
  String get koiSectionIdentity => 'Identity';

  @override
  String get koiSectionOrigin => 'Origin';

  @override
  String get koiSectionLineage => 'Lineage';

  @override
  String get koiSectionGrowth => 'Growth';

  @override
  String get photoUploading => 'Uploading photo…';

  @override
  String get koiPhotoAdded => 'Photo added to the gallery.';

  @override
  String uploadError(Object error) {
    return 'Upload failed: $error';
  }

  @override
  String get koiListTitle => 'My koi';

  @override
  String get koiListEmptyTitle => 'Your collection is empty';

  @override
  String get koiListEmptyMessage =>
      'Add your first koi to follow their growth and lineage.';

  @override
  String get parentManualShort => 'Entered manually';

  @override
  String get parentUnknown => 'Unknown';

  @override
  String get parentNotFound => 'Not found';

  @override
  String get loading => 'Loading';

  @override
  String get varietyUnknown => 'Unknown variety';

  @override
  String get koiLastSize => 'Last measured size';

  @override
  String get koiMeasure => 'Measure';

  @override
  String get koiGrowthEmpty => 'Record a measurement to draw the growth curve.';

  @override
  String get addPhoto => 'Add a photo';

  @override
  String get koiVariety => 'Variety';

  @override
  String get koiAge => 'Age';

  @override
  String get koiBirthDateMissing => 'Date of birth not set';

  @override
  String koiBornOn(String date) {
    return 'Born $date';
  }

  @override
  String get koiAgeApprox => 'Approximate age carried over from the old record';

  @override
  String get tapToAdd => 'Tap to add it';

  @override
  String koiYearClass(String yearClass) {
    return 'Age class: $yearClass';
  }

  @override
  String koiBirthDateOf(String name) {
    return '$name\'s date of birth';
  }

  @override
  String get commonSave => 'Save';

  @override
  String koiBirthDateError(Object error) {
    return 'Could not save the date: $error';
  }

  @override
  String get koiBreeder => 'Breeder';

  @override
  String get commonAdd => 'Add';

  @override
  String get photoMain => 'Main photo';

  @override
  String get photo => 'Photo';

  @override
  String get photoMainBadge => 'MAIN';

  @override
  String get commonClose => 'Close';

  @override
  String get photoSetMain => 'Set as main photo';

  @override
  String updateError(Object error) {
    return 'Could not update: $error';
  }

  @override
  String get photoDeleteTitle => 'Delete this photo?';

  @override
  String get photoDeleteBody => 'The photo will be permanently deleted.';

  @override
  String get sizeInvalidCm => 'Enter a valid size in centimetres.';

  @override
  String saveImpossible(Object error) {
    return 'Could not save: $error';
  }

  @override
  String get koiUpdateSize => 'Update size';

  @override
  String get koiUpdateSizeHint => 'It will be added to the growth curve.';

  @override
  String get koiNewSize => 'New size';

  @override
  String get koiConfirmMeasure => 'Save measurement';

  @override
  String get plantNotFound => 'This plant no longer exists.';

  @override
  String get plantFormTitleEdit => 'Edit plant';

  @override
  String get plantFormTitleAdd => 'Add a plant';

  @override
  String get plantSectionPlanting => 'Planting';

  @override
  String get plantZone => 'Zone';

  @override
  String get plantQuantity => 'Quantity';

  @override
  String get plantPlanted => 'Planted';

  @override
  String get plantDepth => 'Depth';

  @override
  String get photoUpdated => 'Photo updated.';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get plantFloatingBadge => 'FLOATING';

  @override
  String get plantOxygenatingBadge => 'OXYGENATING';

  @override
  String get plantFormDate => 'Planting date';

  @override
  String get plantUpdated => 'Plant updated.';

  @override
  String get plantAdded => 'Plant added.';

  @override
  String plantDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get plantDeleteBody => 'The record and its photo will be deleted.';

  @override
  String plantDeleted(String name) {
    return '$name has been deleted.';
  }

  @override
  String get plantDeleteTooltip => 'Delete this plant';

  @override
  String get plantFormName => 'Name (e.g. Pink water lily)';

  @override
  String get plantFormSpecies => 'Species or variety (optional)';

  @override
  String get plantFormQuantity => 'Number of pots or plants';

  @override
  String get formAtLeastOne => 'At least 1';

  @override
  String get formUnrealistic => 'Unrealistic value';

  @override
  String get plantSectionZone => 'Planting zone';

  @override
  String get plantFloating => 'Floating';

  @override
  String get plantFloatingHint =>
      'Not rooted: it shades the water and shelters the fry.';

  @override
  String get plantOxygenating => 'Oxygenating';

  @override
  String get plantOxygenatingHint =>
      'Submerged: it takes up nitrate and produces oxygen.';

  @override
  String get plantFormNotesHint => 'Dividing, feeding, overwintering…';

  @override
  String get plantFormSave => 'Add plant';

  @override
  String plantZoneUpTo(String zone, int depth) {
    return '$zone · up to $depth cm';
  }

  @override
  String get plantListTitle => 'Plants';

  @override
  String get plantListEmptyTitle => 'No plants yet';

  @override
  String get plantListEmptyMessage =>
      'Water lilies, irises, oxygenators… Note what you plant, where and when.';

  @override
  String get pondSeeAll => 'See all';

  @override
  String get pondOtherFish => 'Other fish';

  @override
  String get pondNewReading => 'New reading';

  @override
  String get pondPhotoUpdated => 'Pond photo updated.';

  @override
  String get pondPhotoRemoved => 'Photo removed: back to the water.';

  @override
  String get pondOptions => 'Pond options';

  @override
  String get pondEdit => 'Edit pond';

  @override
  String get pondAddPhoto => 'Add a pond photo';

  @override
  String get pondRemovePhoto => 'Remove photo, back to the water';

  @override
  String pondDepthCm(String depth) {
    return '$depth cm deep';
  }

  @override
  String get pondWelcome => 'Welcome to your ecosystem,';

  @override
  String get pondDefaultName => 'My pond';

  @override
  String get pondNoReading => 'NO READINGS';

  @override
  String get formInvalidValue => 'Invalid value';

  @override
  String get pondFormName => 'Pond name';

  @override
  String get pondSectionDimensions => 'Dimensions';

  @override
  String get pondFormVolume => 'Volume (L)';

  @override
  String get pondFormDepth => 'Depth (cm)';

  @override
  String get pondFormNotesHint => 'Filtration, sun exposure, history…';

  @override
  String get fishFormDate => 'Date introduced';

  @override
  String get fishUpdated => 'Group updated.';

  @override
  String get fishAdded => 'Group added.';

  @override
  String fishDeleteTitle(String species) {
    return 'Delete $species?';
  }

  @override
  String get fishDeleteBody => 'The group and its photo will be deleted.';

  @override
  String get fishDeleted => 'Group deleted.';

  @override
  String get fishFormTitleEdit => 'Edit group';

  @override
  String get fishFormTitleAdd => 'Add fish';

  @override
  String get fishDeleteTooltip => 'Delete this group';

  @override
  String get fishSectionSpecies => 'Species';

  @override
  String get fishFormSpecies => 'Species (e.g. Golden orfe, Sturgeon)';

  @override
  String get fishFormSpeciesRequired => 'Please enter the species';

  @override
  String get fishFormCount => 'Number of fish';

  @override
  String get fishSectionIntroduction => 'Introduction';

  @override
  String get fishFormNotesHint => 'Origin, behaviour, losses…';

  @override
  String get fishFormSave => 'Add group';

  @override
  String get fishChangePhoto => 'Change the group photo';

  @override
  String get fishAddPhoto => 'Add a group photo';

  @override
  String get fishEmptyTitle => 'No other fish yet';

  @override
  String get fishEmptyMessage =>
      'Sturgeon, orfe, goldfish… Note the species that share the pond with your koi.';

  @override
  String fishSummary(int fish, int groups) {
    String _temp0 = intl.Intl.pluralLogic(
      fish,
      locale: localeName,
      other: '$fish fish',
      one: '$fish fish',
    );
    String _temp1 = intl.Intl.pluralLogic(
      groups,
      locale: localeName,
      other: '$groups groups',
      one: '$groups group',
    );
    return '$_temp0 in $_temp1';
  }

  @override
  String get fishDateUnknown => 'Date introduced unknown';

  @override
  String fishSince(String date) {
    return 'Since $date';
  }

  @override
  String get sceneEmpty => 'Empty pond';

  @override
  String sceneWithKoi(int count, String names) {
    return 'Pond with $count koi: $names';
  }

  @override
  String get readingSaved => 'Reading saved!';

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

    return 'Between $minString and $maxString';
  }

  @override
  String get readingSectionMain => 'Main reading';

  @override
  String get readingPhLabel => 'pH (e.g. 7.2)';

  @override
  String get readingTempLabel => 'Temperature (°C)';

  @override
  String get readingSectionNitrogen => 'Nitrogen cycle (optional)';

  @override
  String get readingAmmoniaLabel => 'Ammonia NH₃/NH₄ (mg/L)';

  @override
  String get readingSectionHardness => 'Hardness (optional)';

  @override
  String get readingSave => 'Save reading';

  @override
  String get historyTitle => 'Reading history';

  @override
  String get historyEmptyTitle => 'No readings';

  @override
  String get historyEmptyMessage => 'The readings you save will appear here.';

  @override
  String get readingAdd => 'Add a reading';

  @override
  String get readingDeleteTitle => 'Delete this reading?';

  @override
  String get readingDeleteBody =>
      'It will disappear from the history and the charts. This cannot be undone.';

  @override
  String get readingDeleted => 'Reading deleted.';

  @override
  String get readingDeleteTooltip => 'Delete this reading';

  @override
  String get dateUnknown => 'Unknown date';

  @override
  String get waterTitle => 'Water';

  @override
  String get waterHistory => 'History';

  @override
  String get waterEmptyTitle => 'No water tests yet';

  @override
  String get waterEmptyMessage =>
      'Save your first reading to track your pond\'s water quality.';

  @override
  String get waterLatest => 'Latest reading';

  @override
  String get waterPhTrend => 'pH trend';

  @override
  String get waterTempTrend => 'Temperature trend';

  @override
  String get chartNoData => 'No data yet';

  @override
  String get bannerHealthy => 'Pond in good health';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDisplay => 'Display';

  @override
  String get profileTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profileReducedMotion => 'Reduce motion';

  @override
  String get profileReducedMotionHint =>
      'Freezes the pond scene and transitions. Handy on a modest device.';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccountButton => 'Delete my account and data';

  @override
  String get profileDefaultName => 'Koi keeper';

  @override
  String get pondDimensionsMissing => 'Volume and depth not set';

  @override
  String get deleteIdentityFailed =>
      'Identity check failed. Nothing was deleted.';

  @override
  String get deleteNeedsInternet =>
      'An internet connection is required: the deletion could not finish. Start it again once you\'re online; it will pick up where it stopped.';

  @override
  String deleteInterrupted(Object error) {
    return 'The deletion was interrupted ($error). Start it again: it will pick up where it stopped.';
  }

  @override
  String get deleteAccountDone =>
      'Your account and all your data have been deleted.';

  @override
  String get deleteAccountNeedsConfirmation =>
      'Your data has been deleted, but the account could not be without confirmation. Start the deletion again.';

  @override
  String deleteAccountFailed(String code) {
    return 'Your data has been deleted, but the account could not be ($code). Start the deletion again.';
  }

  @override
  String deleteWrongAccount(String provider) {
    return 'That\'s not the signed-in $provider account. Choose the same account. Nothing was deleted.';
  }

  @override
  String deletePopupBlocked(String provider) {
    return 'The $provider window couldn\'t open. Sign out, sign back in, then start the deletion again within five minutes.';
  }

  @override
  String get deleteNoInternet => 'No internet connection. Nothing was deleted.';

  @override
  String deleteIdentityFailedCode(String code) {
    return 'Identity check failed ($code). Nothing was deleted.';
  }

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String get deleteAccountTitle => 'Delete your account?';

  @override
  String get deleteAccountBody =>
      'Everything will be permanently deleted: your koi and their photos, their growth, your water readings, your plants, your other fish and your pond. Nothing can be recovered.';

  @override
  String deleteAccountIdentityHint(String provider) {
    return '$provider may ask you to confirm your identity.';
  }

  @override
  String deleteAccountTypeWord(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get deleteInProgress => 'Deleting your data…';

  @override
  String get loginFailed => 'Sign-in failed. Please try again.';

  @override
  String get loginNoNetwork =>
      'Can\'t sign in: check your internet connection.';

  @override
  String get loginAccountExists =>
      'An account already uses this email address: sign in the way you did the first time, with Google or with Apple.';

  @override
  String get loginUnauthorizedDomain =>
      'This domain isn\'t authorised in the Firebase console.';

  @override
  String get loginTagline => 'Your pond journal';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get navPond => 'Pond';

  @override
  String get navKoi => 'Koi';

  @override
  String get pondNotFound => 'Pond not found.';

  @override
  String get fishNotFound => 'This group no longer exists.';

  @override
  String privacyOpenError(String url) {
    return 'Couldn\'t open the page: $url';
  }

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get errorPermission =>
      'Access denied by the security rules. Check that you\'re signed in to the right account.';

  @override
  String get errorNetwork =>
      'Can\'t reach the server. Check your internet connection.';

  @override
  String get errorIndex =>
      'A Firestore index is missing for this query. Deploy the project\'s indexes.';

  @override
  String get errorLoading => 'Something went wrong while loading.';

  @override
  String get loadFailed => 'Couldn\'t load';
}
