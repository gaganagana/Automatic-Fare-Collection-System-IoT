import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
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
    Locale('hi'),
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

  /// No description provided for @trafficLabel.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get trafficLabel;

  /// No description provided for @trafficLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get trafficLow;

  /// No description provided for @trafficMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get trafficMedium;

  /// No description provided for @trafficHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get trafficHigh;

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

  /// No description provided for @currentRoute.
  ///
  /// In en, this message translates to:
  /// **'CURRENT ROUTE'**
  String get currentRoute;

  /// No description provided for @activeTransit.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE TRANSIT'**
  String get activeTransit;

  /// No description provided for @routeSummary.
  ///
  /// In en, this message translates to:
  /// **'Kempegowda BS → BTM Layout (18 Stops)'**
  String get routeSummary;

  /// No description provided for @fareRate.
  ///
  /// In en, this message translates to:
  /// **'Fare: ₹10 per stop'**
  String get fareRate;

  /// No description provided for @liveMapTitle.
  ///
  /// In en, this message translates to:
  /// **'LIVE BUS ROUTE MAP'**
  String get liveMapTitle;

  /// No description provided for @speedKmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get speedKmh;

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

  /// No description provided for @controlRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'SMART BUS - CONTROL ROOM'**
  String get controlRoomTitle;

  /// No description provided for @adminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminPortal;

  /// No description provided for @passengerPortal.
  ///
  /// In en, this message translates to:
  /// **'Passenger Portal'**
  String get passengerPortal;

  /// No description provided for @passengerManagement.
  ///
  /// In en, this message translates to:
  /// **'Passenger Management'**
  String get passengerManagement;

  /// No description provided for @noPassengers.
  ///
  /// In en, this message translates to:
  /// **'No passengers registered yet.'**
  String get noPassengers;

  /// No description provided for @addPassenger.
  ///
  /// In en, this message translates to:
  /// **'Add Passenger'**
  String get addPassenger;

  /// No description provided for @deletePassenger.
  ///
  /// In en, this message translates to:
  /// **'Delete passenger'**
  String get deletePassenger;

  /// No description provided for @confirmDeletePassenger.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the Smart Bus system?'**
  String confirmDeletePassenger(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @passengerName.
  ///
  /// In en, this message translates to:
  /// **'Passenger name'**
  String get passengerName;

  /// No description provided for @temporaryPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary password (min 6 characters)'**
  String get temporaryPassword;

  /// No description provided for @registeredRfidUid.
  ///
  /// In en, this message translates to:
  /// **'Registered RFID UID'**
  String get registeredRfidUid;

  /// No description provided for @addPassengerButton.
  ///
  /// In en, this message translates to:
  /// **'ADD PASSENGER'**
  String get addPassengerButton;

  /// No description provided for @passengerAdded.
  ///
  /// In en, this message translates to:
  /// **'Passenger added successfully.'**
  String get passengerAdded;

  /// No description provided for @mySmartCard.
  ///
  /// In en, this message translates to:
  /// **'MY SMART CARD'**
  String get mySmartCard;

  /// No description provided for @noCardLinked.
  ///
  /// In en, this message translates to:
  /// **'No card linked to this account.'**
  String get noCardLinked;

  /// No description provided for @currentlyOnboard.
  ///
  /// In en, this message translates to:
  /// **'Status: Currently onboard'**
  String get currentlyOnboard;

  /// No description provided for @notOnTrip.
  ///
  /// In en, this message translates to:
  /// **'Status: Not on a trip'**
  String get notOnTrip;

  /// No description provided for @rechargeMyCard.
  ///
  /// In en, this message translates to:
  /// **'RECHARGE MY CARD'**
  String get rechargeMyCard;

  /// No description provided for @myTripHistory.
  ///
  /// In en, this message translates to:
  /// **'MY TRIP HISTORY'**
  String get myTripHistory;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet.'**
  String get noTransactions;

  /// No description provided for @rechargeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Recharge Card'**
  String get rechargeCardTitle;

  /// No description provided for @amountRupees.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get amountRupees;

  /// No description provided for @payAndRecharge.
  ///
  /// In en, this message translates to:
  /// **'PAY & RECHARGE'**
  String get payAndRecharge;

  /// No description provided for @rfidWallets.
  ///
  /// In en, this message translates to:
  /// **'RFID WALLETS'**
  String get rfidWallets;

  /// No description provided for @noRegisteredCards.
  ///
  /// In en, this message translates to:
  /// **'No registered RFID cards yet.'**
  String get noRegisteredCards;

  /// No description provided for @registerNewRfid.
  ///
  /// In en, this message translates to:
  /// **'REGISTER NEW RFID'**
  String get registerNewRfid;

  /// No description provided for @registerNewRfidTitle.
  ///
  /// In en, this message translates to:
  /// **'Register New RFID Card'**
  String get registerNewRfidTitle;

  /// No description provided for @cardUidHex.
  ///
  /// In en, this message translates to:
  /// **'Card UID (Hex)'**
  String get cardUidHex;

  /// No description provided for @holderName.
  ///
  /// In en, this message translates to:
  /// **'Holder Name'**
  String get holderName;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'ADD CARD'**
  String get addCard;

  /// No description provided for @noRealCards.
  ///
  /// In en, this message translates to:
  /// **'Register a real RFID card before adding a passenger.'**
  String get noRealCards;

  /// No description provided for @cardActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get cardActive;

  /// No description provided for @cardInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get cardInactive;

  /// No description provided for @cardOnboard.
  ///
  /// In en, this message translates to:
  /// **'ONBOARD'**
  String get cardOnboard;

  /// No description provided for @searchPassenger.
  ///
  /// In en, this message translates to:
  /// **'Search passenger or UID...'**
  String get searchPassenger;

  /// No description provided for @noMatchFound.
  ///
  /// In en, this message translates to:
  /// **'No matching passenger or card found.'**
  String get noMatchFound;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'RFID TRANSACTIONS & FARE AUDIT'**
  String get transactionsTitle;

  /// No description provided for @colTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get colTime;

  /// No description provided for @colPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get colPassenger;

  /// No description provided for @colUid.
  ///
  /// In en, this message translates to:
  /// **'Card UID'**
  String get colUid;

  /// No description provided for @colType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get colType;

  /// No description provided for @colStop.
  ///
  /// In en, this message translates to:
  /// **'Stop / Route'**
  String get colStop;

  /// No description provided for @colAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get colAmount;

  /// No description provided for @colBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get colBalance;

  /// No description provided for @typeBoarding.
  ///
  /// In en, this message translates to:
  /// **'BOARDING'**
  String get typeBoarding;

  /// No description provided for @typeExit.
  ///
  /// In en, this message translates to:
  /// **'EXIT'**
  String get typeExit;

  /// No description provided for @typeRecharge.
  ///
  /// In en, this message translates to:
  /// **'RECHARGE'**
  String get typeRecharge;

  /// No description provided for @typeDenied.
  ///
  /// In en, this message translates to:
  /// **'DENIED'**
  String get typeDenied;

  /// No description provided for @reasonLowBalance.
  ///
  /// In en, this message translates to:
  /// **'Low Balance'**
  String get reasonLowBalance;

  /// No description provided for @reasonDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated Card'**
  String get reasonDeactivated;

  /// No description provided for @reasonInvalid.
  ///
  /// In en, this message translates to:
  /// **'Unregistered Card'**
  String get reasonInvalid;

  /// No description provided for @passengerHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'PASSENGER JOURNEY AUDIT'**
  String get passengerHistoryTitle;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI & ML ROUTE CHATBOT'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about BMTC routes (600F, 500D, 335E, 365, 25A), timings, ₹10/stop fares & card info.'**
  String get aiAssistantSubtitle;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Ask in Kannada, Hindi, or English (e.g. 600F route)...'**
  String get askHint;

  /// No description provided for @voiceQuery.
  ///
  /// In en, this message translates to:
  /// **'Voice Query'**
  String get voiceQuery;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening... Speak your query'**
  String get listening;

  /// No description provided for @quickPromptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Queries'**
  String get quickPromptsTitle;

  /// No description provided for @promptNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get promptNextStop;

  /// No description provided for @promptBalance.
  ///
  /// In en, this message translates to:
  /// **'My card balance'**
  String get promptBalance;

  /// No description provided for @promptFare.
  ///
  /// In en, this message translates to:
  /// **'Fare to KR Circle'**
  String get promptFare;

  /// No description provided for @promptCardStatus.
  ///
  /// In en, this message translates to:
  /// **'My card status'**
  String get promptCardStatus;

  /// No description provided for @promptRoute600F.
  ///
  /// In en, this message translates to:
  /// **'600F Route'**
  String get promptRoute600F;

  /// No description provided for @promptRoute500D.
  ///
  /// In en, this message translates to:
  /// **'500D Route'**
  String get promptRoute500D;

  /// No description provided for @promptRoute335E.
  ///
  /// In en, this message translates to:
  /// **'335E Route'**
  String get promptRoute335E;

  /// No description provided for @promptRoute365.
  ///
  /// In en, this message translates to:
  /// **'365 Route'**
  String get promptRoute365;

  /// No description provided for @promptRoute25A.
  ///
  /// In en, this message translates to:
  /// **'25A Route'**
  String get promptRoute25A;

  /// No description provided for @promptFareRule.
  ///
  /// In en, this message translates to:
  /// **'₹10 Fare Rule'**
  String get promptFareRule;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @sendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendButton;

  /// No description provided for @speaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking...'**
  String get speaking;

  /// No description provided for @listenAudio.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listenAudio;

  /// No description provided for @routeTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'BENGALURU ROUTE STOPS (18 STOPS)'**
  String get routeTimelineTitle;

  /// No description provided for @farePerStop.
  ///
  /// In en, this message translates to:
  /// **'₹10 / stop'**
  String get farePerStop;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get settingsTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @linkedRfidCard.
  ///
  /// In en, this message translates to:
  /// **'Linked RFID Card'**
  String get linkedRfidCard;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @hardwareBridge.
  ///
  /// In en, this message translates to:
  /// **'NodeMCU Bridge'**
  String get hardwareBridge;

  /// No description provided for @tapCardPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap your RFID card on the reader to board'**
  String get tapCardPrompt;

  /// No description provided for @searchPassengerUid.
  ///
  /// In en, this message translates to:
  /// **'Search passenger / RFID UID'**
  String get searchPassengerUid;

  /// No description provided for @noPassengerRecords.
  ///
  /// In en, this message translates to:
  /// **'No matching passenger records.'**
  String get noPassengerRecords;

  /// No description provided for @cardMustBeRegistered.
  ///
  /// In en, this message translates to:
  /// **'The RFID card must already be registered.'**
  String get cardMustBeRegistered;

  /// No description provided for @enterValidPassengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid passenger details and a registered RFID UID.'**
  String get enterValidPassengerDetails;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @notLinked.
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get notLinked;

  /// No description provided for @signInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInTab;

  /// No description provided for @signUpTab.
  ///
  /// In en, this message translates to:
  /// **'Sign Up / Register'**
  String get signUpTab;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @rfidUidLabel.
  ///
  /// In en, this message translates to:
  /// **'Smart Card UID (RFID)'**
  String get rfidUidLabel;

  /// No description provided for @rfidUidHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5B850B1A from your smart card'**
  String get rfidUidHelper;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register Card & Account'**
  String get registerButton;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account and smart card registered successfully!'**
  String get registrationSuccess;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// No description provided for @needAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New passenger? Register your RFID card here'**
  String get needAccountPrompt;
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
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
