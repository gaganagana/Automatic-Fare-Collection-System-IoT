import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('kn')
  ];

  /// App title shown in the OS task switcher and browser tab
  ///
  /// In en, this message translates to:
  /// **'Smart Bus Control Room'**
  String get appTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'IoT Fleet Dashboard / Bengaluru Route - Bus-01'**
  String get dashboardSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Bus - Control Room'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in as Admin/Operator or with your Passenger card login.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Login successful — a confirmation email is on its way.'**
  String get loginSuccessMessage;

  /// No description provided for @registerPrompt.
  ///
  /// In en, this message translates to:
  /// **'New passenger? Register a card account'**
  String get registerPrompt;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @statusMoving.
  ///
  /// In en, this message translates to:
  /// **'Moving'**
  String get statusMoving;

  /// No description provided for @statusStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get statusStopped;

  /// No description provided for @onboardLabel.
  ///
  /// In en, this message translates to:
  /// **'Onboard'**
  String get onboardLabel;

  /// No description provided for @enteredLabel.
  ///
  /// In en, this message translates to:
  /// **'Entered'**
  String get enteredLabel;

  /// No description provided for @exitedLabel.
  ///
  /// In en, this message translates to:
  /// **'Exited'**
  String get exitedLabel;

  /// No description provided for @currentStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stop'**
  String get currentStopLabel;

  /// No description provided for @nextStopLabel.
  ///
  /// In en, this message translates to:
  /// **'Next Stop Announcement'**
  String get nextStopLabel;

  /// No description provided for @startSimulator.
  ///
  /// In en, this message translates to:
  /// **'Start Simulator'**
  String get startSimulator;

  /// No description provided for @stopSimulator.
  ///
  /// In en, this message translates to:
  /// **'Stop Simulator'**
  String get stopSimulator;

  /// No description provided for @simulateTap.
  ///
  /// In en, this message translates to:
  /// **'Simulate RFID Tap'**
  String get simulateTap;

  /// No description provided for @rechargeButton.
  ///
  /// In en, this message translates to:
  /// **'Recharge'**
  String get rechargeButton;

  /// No description provided for @registerCard.
  ///
  /// In en, this message translates to:
  /// **'Register New RFID'**
  String get registerCard;

  /// Full sentence read aloud by TalkBack/screen readers for the bus status card
  ///
  /// In en, this message translates to:
  /// **'Bus status: {status}, speed {speed} kilometers per hour, currently at {stop}'**
  String busStatusSemantic(String status, String speed, String stop);

  /// No description provided for @ttsBoarding.
  ///
  /// In en, this message translates to:
  /// **'{name} boarded at {stop}. Fare {amount} rupees deducted.'**
  String ttsBoarding(String name, String stop, String amount);

  /// No description provided for @ttsExit.
  ///
  /// In en, this message translates to:
  /// **'{name} exited at {stop}.'**
  String ttsExit(String name, String stop);

  /// No description provided for @ttsDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Insufficient balance.'**
  String get ttsDenied;

  /// No description provided for @ttsApproachingStop.
  ///
  /// In en, this message translates to:
  /// **'Approaching {stop}.'**
  String ttsApproachingStop(String stop);

  /// No description provided for @ttsRecharge.
  ///
  /// In en, this message translates to:
  /// **'Recharge successful. New balance {amount} rupees.'**
  String ttsRecharge(String amount);

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @ttsToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice announcements'**
  String get ttsToggleLabel;
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
      <String>['en', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
