// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `en`
  String get locale {
    return Intl.message(
      'en',
      name: 'locale',
      desc: '',
      args: [],
    );
  }

  /// `Let's Find\nYour\nPlace!`
  String get introPageText {
    return Intl.message(
      'Let\'s Find\nYour\nPlace!',
      name: 'introPageText',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get introPageGetStartedButtonText {
    return Intl.message(
      'Get Started',
      name: 'introPageGetStartedButtonText',
      desc: '',
      args: [],
    );
  }

  /// `The server does not response!`
  String get requestsNumberErrorMessageTitle {
    return Intl.message(
      'The server does not response!',
      name: 'requestsNumberErrorMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `The number of requests exceeded.`
  String get requestsNumberErrorMessageSubtitle {
    return Intl.message(
      'The number of requests exceeded.',
      name: 'requestsNumberErrorMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection!`
  String get noInternetErrorMessageTitle {
    return Intl.message(
      'No internet connection!',
      name: 'noInternetErrorMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection.`
  String get noInternetErrorMessageSubtitle {
    return Intl.message(
      'Please check your internet connection.',
      name: 'noInternetErrorMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get confirmMessageTitle {
    return Intl.message(
      'Are you sure?',
      name: 'confirmMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `If you are not sure, swipe to the right.`
  String get confirmMessageSubtitle {
    return Intl.message(
      'If you are not sure, swipe to the right.',
      name: 'confirmMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to close the app?`
  String get confirmExitMessageTitle {
    return Intl.message(
      'Do you want to close the app?',
      name: 'confirmExitMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `If you don't want it, swipe to the right.`
  String get confirmExitMessageSubtitle {
    return Intl.message(
      'If you don\'t want it, swipe to the right.',
      name: 'confirmExitMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong!`
  String get somethingWentWrongTitle {
    return Intl.message(
      'Something went wrong!',
      name: 'somethingWentWrongTitle',
      desc: '',
      args: [],
    );
  }

  /// `We can't connect to server.`
  String get somethingWentWrongSubtitle {
    return Intl.message(
      'We can\'t connect to server.',
      name: 'somethingWentWrongSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `You missed something!`
  String get emptySearchBoxErrorMessageTitle {
    return Intl.message(
      'You missed something!',
      name: 'emptySearchBoxErrorMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `The location text field can't be empty.`
  String get emptySearchBoxErrorMessageSubtitle {
    return Intl.message(
      'The location text field can\'t be empty.',
      name: 'emptySearchBoxErrorMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `No data is saved!`
  String get noSavedDataForLocationErrorMessageTitle {
    return Intl.message(
      'No data is saved!',
      name: 'noSavedDataForLocationErrorMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `There is no data for this location.`
  String get noSavedDataForLocationErrorMessageSubtitle {
    return Intl.message(
      'There is no data for this location.',
      name: 'noSavedDataForLocationErrorMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Data is out of date!`
  String get outOfDateDataWarningMessageTitle {
    return Intl.message(
      'Data is out of date!',
      name: 'outOfDateDataWarningMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Refresh to know the latest conditions.`
  String get outOfDateDataWarningMessageSubtitle {
    return Intl.message(
      'Refresh to know the latest conditions.',
      name: 'outOfDateDataWarningMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Unable to add "{name}"`
  String unableToAddLocationErrorMessage(String name) {
    return Intl.message(
      'Unable to add "$name"',
      name: 'unableToAddLocationErrorMessage',
      desc: '',
      args: [name],
    );
  }

  /// `Unable to open web page!`
  String get openWebpageErrorTitleMessage {
    return Intl.message(
      'Unable to open web page!',
      name: 'openWebpageErrorTitleMessage',
      desc: '',
      args: [],
    );
  }

  /// `The web page is unavailable.`
  String get openWebpageErrorSubtitleMessage {
    return Intl.message(
      'The web page is unavailable.',
      name: 'openWebpageErrorSubtitleMessage',
      desc: '',
      args: [],
    );
  }

  /// `Pull down to update data.`
  String get refreshIndicatorPullDownMessage {
    return Intl.message(
      'Pull down to update data.',
      name: 'refreshIndicatorPullDownMessage',
      desc: '',
      args: [],
    );
  }

  /// `Release to load data.`
  String get refreshIndicatorReleaseMessage {
    return Intl.message(
      'Release to load data.',
      name: 'refreshIndicatorReleaseMessage',
      desc: '',
      args: [],
    );
  }

  /// `Loading data from server...`
  String get refreshIndicatorLoadDataMessage {
    return Intl.message(
      'Loading data from server...',
      name: 'refreshIndicatorLoadDataMessage',
      desc: '',
      args: [],
    );
  }

  /// `Data successfully updated.`
  String get refreshIndicatorSuccessMessage {
    return Intl.message(
      'Data successfully updated.',
      name: 'refreshIndicatorSuccessMessage',
      desc: '',
      args: [],
    );
  }

  /// `The number of requests exceeded.`
  String get refreshIndicatorNoResponseMessage {
    return Intl.message(
      'The number of requests exceeded.',
      name: 'refreshIndicatorNoResponseMessage',
      desc: '',
      args: [],
    );
  }

  /// `We can't get data from server!`
  String get refreshIndicatorErrorMessage {
    return Intl.message(
      'We can\'t get data from server!',
      name: 'refreshIndicatorErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get unavailableText {
    return Intl.message(
      'Unavailable',
      name: 'unavailableText',
      desc: '',
      args: [],
    );
  }

  /// `WIND`
  String get windTitle {
    return Intl.message(
      'WIND',
      name: 'windTitle',
      desc: '',
      args: [],
    );
  }

  /// `UV INDEX`
  String get uvIndexTitle {
    return Intl.message(
      'UV INDEX',
      name: 'uvIndexTitle',
      desc: '',
      args: [],
    );
  }

  /// `FEELS LIKE`
  String get feelsLikeTitle {
    return Intl.message(
      'FEELS LIKE',
      name: 'feelsLikeTitle',
      desc: '',
      args: [],
    );
  }

  /// `HUMIDITY`
  String get humidityTitle {
    return Intl.message(
      'HUMIDITY',
      name: 'humidityTitle',
      desc: '',
      args: [],
    );
  }

  /// `VISIBILITY`
  String get visibilityTitle {
    return Intl.message(
      'VISIBILITY',
      name: 'visibilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sunrise`
  String get sunriseText {
    return Intl.message(
      'Sunrise',
      name: 'sunriseText',
      desc: '',
      args: [],
    );
  }

  /// `Sunset`
  String get sunsetText {
    return Intl.message(
      'Sunset',
      name: 'sunsetText',
      desc: '',
      args: [],
    );
  }

  /// `Air Quality Index`
  String get airQualityIndexTitle {
    return Intl.message(
      'Air Quality Index',
      name: 'airQualityIndexTitle',
      desc: '',
      args: [],
    );
  }

  /// `{locationName} air quality is `
  String airQualityIndexSubtitle(String locationName) {
    return Intl.message(
      '$locationName air quality is ',
      name: 'airQualityIndexSubtitle',
      desc: '',
      args: [locationName],
    );
  }

  /// `Fake Data`
  String get aqiFakeDateTagText {
    return Intl.message(
      'Fake Data',
      name: 'aqiFakeDateTagText',
      desc: '',
      args: [],
    );
  }

  /// `Excellent,Good,Fair,Poor,Unhealthy,Dangerous`
  String get aqiScaleText {
    return Intl.message(
      'Excellent,Good,Fair,Poor,Unhealthy,Dangerous',
      name: 'aqiScaleText',
      desc: '',
      args: [],
    );
  }

  /// `Tomorrow`
  String get tomorrowText {
    return Intl.message(
      'Tomorrow',
      name: 'tomorrowText',
      desc: '',
      args: [],
    );
  }

  /// `The Next 12 Days`
  String get next12DaysForecastButtonText {
    return Intl.message(
      'The Next 12 Days',
      name: 'next12DaysForecastButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Swipe down to update data!`
  String get refreshIndicatorSwipeState {
    return Intl.message(
      'Swipe down to update data!',
      name: 'refreshIndicatorSwipeState',
      desc: '',
      args: [],
    );
  }

  /// `Loading data from server...`
  String get refreshIndicatorLoadingState {
    return Intl.message(
      'Loading data from server...',
      name: 'refreshIndicatorLoadingState',
      desc: '',
      args: [],
    );
  }

  /// `Data updated successfully ;)`
  String get refreshIndicatorSuccessfulState {
    return Intl.message(
      'Data updated successfully ;)',
      name: 'refreshIndicatorSuccessfulState',
      desc: '',
      args: [],
    );
  }

  /// `Oops, Something went wrong!`
  String get refreshIndicatorErrorState {
    return Intl.message(
      'Oops, Something went wrong!',
      name: 'refreshIndicatorErrorState',
      desc: '',
      args: [],
    );
  }

  /// `Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday`
  String get weekDays {
    return Intl.message(
      'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
      name: 'weekDays',
      desc: '',
      args: [],
    );
  }

  /// `January,February,March,April,May,June,July,August,September,October,November,December`
  String get months {
    return Intl.message(
      'January,February,March,April,May,June,July,August,September,October,November,December',
      name: 'months',
      desc: '',
      args: [],
    );
  }

  /// `Manage Locations`
  String get manageLocationsTitle {
    return Intl.message(
      'Manage Locations',
      name: 'manageLocationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add or remove Locations.`
  String get manageLocationsSubtitle {
    return Intl.message(
      'Add or remove Locations.',
      name: 'manageLocationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Popular Locations`
  String get popularLocationsTitle {
    return Intl.message(
      'Popular Locations',
      name: 'popularLocationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Enter location`
  String get searchLocationTextFieldHint {
    return Intl.message(
      'Enter location',
      name: 'searchLocationTextFieldHint',
      desc: '',
      args: [],
    );
  }

  /// `Pin It`
  String get pinButtonText {
    return Intl.message(
      'Pin It',
      name: 'pinButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Pinned`
  String get pinnedTagText {
    return Intl.message(
      'Pinned',
      name: 'pinnedTagText',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yesButtonText {
    return Intl.message(
      'Yes',
      name: 'yesButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteButtonText {
    return Intl.message(
      'Delete',
      name: 'deleteButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Added`
  String get addedButtonText {
    return Intl.message(
      'Added',
      name: 'addedButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get okayButtonText {
    return Intl.message(
      'Okay',
      name: 'okayButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retryButtonText {
    return Intl.message(
      'Retry',
      name: 'retryButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refreshButtonText {
    return Intl.message(
      'Refresh',
      name: 'refreshButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Nothing Found!`
  String get locationNotFoundMessageTitle {
    return Intl.message(
      'Nothing Found!',
      name: 'locationNotFoundMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `No location with this name found.`
  String get locationNotFoundMessageSubtitle {
    return Intl.message(
      'No location with this name found.',
      name: 'locationNotFoundMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `The List Is Empty!`
  String get emptyListMessageTitle {
    return Intl.message(
      'The List Is Empty!',
      name: 'emptyListMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Let's add your favorite locations.`
  String get emptyListMessageSubtitle {
    return Intl.message(
      'Let\'s add your favorite locations.',
      name: 'emptyListMessageSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settingsTitle {
    return Intl.message(
      'Settings',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Customize the app.`
  String get settingsSubtitle {
    return Intl.message(
      'Customize the app.',
      name: 'settingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submitButtonText {
    return Intl.message(
      'Submit',
      name: 'submitButtonText',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelButtonText {
    return Intl.message(
      'Cancel',
      name: 'cancelButtonText',
      desc: '',
      args: [],
    );
  }

  /// `UNITS`
  String get unitsSettingsTitle {
    return Intl.message(
      'UNITS',
      name: 'unitsSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Temperature units`
  String get temperatureUnitItemText {
    return Intl.message(
      'Temperature units',
      name: 'temperatureUnitItemText',
      desc: '',
      args: [],
    );
  }

  /// `Wind speed units`
  String get windSpeedUnitItemText {
    return Intl.message(
      'Wind speed units',
      name: 'windSpeedUnitItemText',
      desc: '',
      args: [],
    );
  }

  /// `Visibility units`
  String get visibilityUnitItemText {
    return Intl.message(
      'Visibility units',
      name: 'visibilityUnitItemText',
      desc: '',
      args: [],
    );
  }

  /// `OTHER SETTINGS`
  String get otherSettingsTitle {
    return Intl.message(
      'OTHER SETTINGS',
      name: 'otherSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get languageItemText {
    return Intl.message(
      'Language',
      name: 'languageItemText',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get themeItemText {
    return Intl.message(
      'Theme',
      name: 'themeItemText',
      desc: '',
      args: [],
    );
  }

  /// `Automatic update`
  String get autoUpdateItemText {
    return Intl.message(
      'Automatic update',
      name: 'autoUpdateItemText',
      desc: '',
      args: [],
    );
  }

  /// `COMMUNICATION`
  String get communicationSettingsTitle {
    return Intl.message(
      'COMMUNICATION',
      name: 'communicationSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedbackItemText {
    return Intl.message(
      'Feedback',
      name: 'feedbackItemText',
      desc: '',
      args: [],
    );
  }

  /// `Contact Me`
  String get contactMeItemText {
    return Intl.message(
      'Contact Me',
      name: 'contactMeItemText',
      desc: '',
      args: [],
    );
  }

  /// `ABOUT`
  String get aboutTitle {
    return Intl.message(
      'ABOUT',
      name: 'aboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get appVersionItemText {
    return Intl.message(
      'App Version',
      name: 'appVersionItemText',
      desc: '',
      args: [],
    );
  }

  /// `Designed and developed by `
  String get developerItemText {
    return Intl.message(
      'Designed and developed by ',
      name: 'developerItemText',
      desc: '',
      args: [],
    );
  }

  /// `Radnive`
  String get developerName {
    return Intl.message(
      'Radnive',
      name: 'developerName',
      desc: '',
      args: [],
    );
  }

  /// `Weather data provider`
  String get weatherDataProviderItemText {
    return Intl.message(
      'Weather data provider',
      name: 'weatherDataProviderItemText',
      desc: '',
      args: [],
    );
  }

  /// `Sun status data provider`
  String get sunStatusDataProviderItemText {
    return Intl.message(
      'Sun status data provider',
      name: 'sunStatusDataProviderItemText',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicyItemText {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicyItemText',
      desc: '',
      args: [],
    );
  }

  /// `Select temperature unit`
  String get temperatureUnitBottomSheetTitle {
    return Intl.message(
      'Select temperature unit',
      name: 'temperatureUnitBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Celsius,Fahrenheit`
  String get temperatureUnitChoiceSubtitles {
    return Intl.message(
      'Celsius,Fahrenheit',
      name: 'temperatureUnitChoiceSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `Select wind speed unit`
  String get windSpeedUnitBottomSheetTitle {
    return Intl.message(
      'Select wind speed unit',
      name: 'windSpeedUnitBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Kilometer per hour,Miles per hour`
  String get windSpeedUnitChoiceSubtitles {
    return Intl.message(
      'Kilometer per hour,Miles per hour',
      name: 'windSpeedUnitChoiceSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `Select visibility unit`
  String get visibilityUnitBottomSheetTitle {
    return Intl.message(
      'Select visibility unit',
      name: 'visibilityUnitBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Kilometer,Mile`
  String get visibilityUnitChoiceSubtitles {
    return Intl.message(
      'Kilometer,Mile',
      name: 'visibilityUnitChoiceSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `Select default language`
  String get languageBottomSheetTitle {
    return Intl.message(
      'Select default language',
      name: 'languageBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Persian,English`
  String get languagesChoiceTitles {
    return Intl.message(
      'Persian,English',
      name: 'languagesChoiceTitles',
      desc: '',
      args: [],
    );
  }

  /// `Iran,United State`
  String get languagesChoiceSubtitles {
    return Intl.message(
      'Iran,United State',
      name: 'languagesChoiceSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `Select app theme language`
  String get themeBottomSheetTitle {
    return Intl.message(
      'Select app theme language',
      name: 'themeBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Auto,Light,Dark`
  String get themeChoiceTitles {
    return Intl.message(
      'Auto,Light,Dark',
      name: 'themeChoiceTitles',
      desc: '',
      args: [],
    );
  }

  /// `Device theme,White theme,Black Theme`
  String get themeChoiceSubtitles {
    return Intl.message(
      'Device theme,White theme,Black Theme',
      name: 'themeChoiceSubtitles',
      desc: '',
      args: [],
    );
  }

  /// `How do you feel about Weather App?`
  String get feedbackBottomSheetTitle {
    return Intl.message(
      'How do you feel about Weather App?',
      name: 'feedbackBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `How do you want to contact me?`
  String get contactMeBottomSheetTitle {
    return Intl.message(
      'How do you want to contact me?',
      name: 'contactMeBottomSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `Instagram,Github,Dribbble`
  String get contactMeChoiceSubtitles {
    return Intl.message(
      'Instagram,Github,Dribbble',
      name: 'contactMeChoiceSubtitles',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fa'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
