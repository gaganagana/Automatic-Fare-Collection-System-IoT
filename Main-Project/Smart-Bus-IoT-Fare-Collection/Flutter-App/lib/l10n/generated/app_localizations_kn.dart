// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appTitle => 'ಸ್ಮಾರ್ಟ್ ಬಸ್ ನಿಯಂತ್ರಣ ಕೊಠಡಿ';

  @override
  String get dashboardSubtitle =>
      'ಐಒಟಿ ಫ್ಲೀಟ್ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ / ಬೆಂಗಳೂರು ಮಾರ್ಗ - ಬಸ್-01';

  @override
  String get loginTitle => 'ಸ್ಮಾರ್ಟ್ ಬಸ್ - ನಿಯಂತ್ರಣ ಕೊಠಡಿ';

  @override
  String get loginSubtitle =>
      'ನಿರ್ವಾಹಕ/ಆಪರೇಟರ್ ಆಗಿ ಅಥವಾ ನಿಮ್ಮ ಪ್ರಯಾಣಿಕರ ಕಾರ್ಡ್ ಮೂಲಕ ಸೈನ್ ಇನ್ ಮಾಡಿ.';

  @override
  String get emailLabel => 'ಇಮೇಲ್';

  @override
  String get passwordLabel => 'ಪಾಸ್‌ವರ್ಡ್';

  @override
  String get loginButton => 'ಲಾಗಿನ್';

  @override
  String get loginSuccessMessage =>
      'ಲಾಗಿನ್ ಯಶಸ್ವಿಯಾಗಿದೆ — ದೃಢೀಕರಣ ಇಮೇಲ್ ಬರುತ್ತಿದೆ.';

  @override
  String get registerPrompt => 'ಹೊಸ ಪ್ರಯಾಣಿಕರೇ? ಕಾರ್ಡ್ ಖಾತೆ ನೋಂದಾಯಿಸಿ';

  @override
  String get statusLabel => 'ಸ್ಥಿತಿ';

  @override
  String get statusMoving => 'ಚಲಿಸುತ್ತಿದೆ';

  @override
  String get statusStopped => 'ನಿಂತಿದೆ';

  @override
  String get onboardLabel => 'ಬೋರ್ಡ್‌ನಲ್ಲಿದ್ದಾರೆ';

  @override
  String get enteredLabel => 'ಪ್ರವೇಶಿಸಿದವರು';

  @override
  String get exitedLabel => 'ನಿರ್ಗಮಿಸಿದವರು';

  @override
  String get trafficLabel => 'ದಟ್ಟಣೆ';

  @override
  String get trafficLow => 'ಕಡಿಮೆ';

  @override
  String get trafficMedium => 'ಮಧ್ಯಮ';

  @override
  String get trafficHigh => 'ಹೆಚ್ಚು';

  @override
  String get currentStopLabel => 'ಪ್ರಸ್ತುತ ನಿಲ್ದಾಣ';

  @override
  String get nextStopLabel => 'ಮುಂದಿನ ನಿಲ್ದಾಣ ಪ್ರಕಟಣೆ';

  @override
  String get currentRoute => 'ಪ್ರಸ್ತುತ ಮಾರ್ಗ';

  @override
  String get activeTransit => 'ಸಕ್ರಿಯ ಸಾರಿಗೆ';

  @override
  String get routeSummary => 'ಕೆಂಪೇಗೌಡ ಬಿ.ಎಸ್. → ಬಿಟಿಎಂ ಲೇಔಟ್ (18 ನಿಲ್ದಾಣಗಳು)';

  @override
  String get fareRate => 'ದರ: ಪ್ರತಿ ನಿಲ್ದಾಣಕ್ಕೆ ₹10';

  @override
  String get liveMapTitle => 'ಲೈವ್ ಬಸ್ ಮಾರ್ಗ ನಕ್ಷೆ';

  @override
  String get speedKmh => 'ಕಿ.ಮೀ/ಗಂಟೆ';

  @override
  String get startSimulator => 'ಸಿಮ್ಯುಲೇಟರ್ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get stopSimulator => 'ಸಿಮ್ಯುಲೇಟರ್ ನಿಲ್ಲಿಸಿ';

  @override
  String get simulateTap => 'ಆರ್‌ಎಫ್‌ಐಡಿ ಟ್ಯಾಪ್ ಅನುಕರಿಸಿ';

  @override
  String get rechargeButton => 'ರೀಚಾರ್ಜ್';

  @override
  String get registerCard => 'ಹೊಸ ಆರ್‌ಎಫ್‌ಐಡಿ ನೋಂದಾಯಿಸಿ';

  @override
  String busStatusSemantic(String status, String speed, String stop) {
    return 'ಬಸ್ ಸ್ಥಿತಿ: $status, ವೇಗ ಗಂಟೆಗೆ $speed ಕಿಲೋಮೀಟರ್, ಪ್ರಸ್ತುತ $stop ನಲ್ಲಿದೆ';
  }

  @override
  String ttsBoarding(String name, String stop, String amount) {
    return '$name $stop ನಲ್ಲಿ ಹತ್ತಿದರು. $amount ರೂಪಾಯಿ ದರ ಕಡಿತಗೊಂಡಿದೆ.';
  }

  @override
  String ttsExit(String name, String stop) {
    return '$name $stop ನಲ್ಲಿ ಇಳಿದರು.';
  }

  @override
  String get ttsDenied => 'ಪ್ರವೇಶ ನಿರಾಕರಿಸಲಾಗಿದೆ. ಸಾಕಷ್ಟು ಬ್ಯಾಲೆನ್ಸ್ ಇಲ್ಲ.';

  @override
  String ttsApproachingStop(String stop) {
    return '$stop ಸಮೀಪಿಸುತ್ತಿದೆ.';
  }

  @override
  String ttsRecharge(String amount) {
    return 'ರೀಚಾರ್ಜ್ ಯಶಸ್ವಿಯಾಗಿದೆ. ಹೊಸ ಬ್ಯಾಲೆನ್ಸ್ $amount ರೂಪಾಯಿ.';
  }

  @override
  String get languageLabel => 'ಭಾಷೆ';

  @override
  String get ttsToggleLabel => 'ಧ್ವನಿ ಪ್ರಕಟಣೆಗಳು';

  @override
  String get controlRoomTitle => 'ಸ್ಮಾರ್ಟ್ ಬಸ್ - ನಿಯಂತ್ರಣ ಕೊಠಡಿ';

  @override
  String get adminPortal => 'ನಿರ್ವಾಹಕರ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್';

  @override
  String get passengerPortal => 'ಪ್ರಯಾಣಿಕರ ಪೋರ್ಟಲ್';

  @override
  String get passengerManagement => 'ಪ್ರಯಾಣಿಕರ ನಿರ್ವಹಣೆ';

  @override
  String get noPassengers => 'ಇನ್ನೂ ಯಾವುದೇ ಪ್ರಯಾಣಿಕರು ನೋಂದಾಯಿಸಲ್ಪಟ್ಟಿಲ್ಲ.';

  @override
  String get addPassenger => 'ಪ್ರಯಾಣಿಕರನ್ನು ಸೇರಿಸಿ';

  @override
  String get deletePassenger => 'ಪ್ರಯಾಣಿಕರನ್ನು ಅಳಿಸಿ';

  @override
  String confirmDeletePassenger(String name) {
    return 'ಸ್ಮಾರ್ಟ್ ಬಸ್ ವ್ಯವಸ್ಥೆಯಿಂದ $name ಅವರನ್ನು ತೆಗೆದುಹಾಕುವುದೇ?';
  }

  @override
  String get cancel => 'ರದ್ದುಮಾಡಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get passengerName => 'ಪ್ರಯಾಣಿಕರ ಹೆಸರು';

  @override
  String get temporaryPassword => 'ತಾತ್ಕಾಲಿಕ ಪಾಸ್‌ವರ್ಡ್ (ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು)';

  @override
  String get registeredRfidUid => 'ನೋಂದಾಯಿತ RFID UID';

  @override
  String get addPassengerButton => 'ಪ್ರಯಾಣಿಕರನ್ನು ಸೇರಿಸಿ';

  @override
  String get passengerAdded => 'ಪ್ರಯಾಣಿಕರನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಸೇರಿಸಲಾಗಿದೆ.';

  @override
  String get mySmartCard => 'ನನ್ನ ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್';

  @override
  String get noCardLinked => 'ಈ ಖಾತೆಗೆ ಯಾವುದೇ ಕಾರ್ಡ್ ಲಿಂಕ್ ಮಾಡಲಾಗಿಲ್ಲ.';

  @override
  String get currentlyOnboard => 'ಸ್ಥಿತಿ: ಪ್ರಸ್ತುತ ಬೋರ್ಡ್‌ನಲ್ಲಿದ್ದಾರೆ';

  @override
  String get notOnTrip => 'ಸ್ಥಿತಿ: ಪ್ರಯಾಣದಲ್ಲಿಲ್ಲ';

  @override
  String get rechargeMyCard => 'ನನ್ನ ಕಾರ್ಡ್ ರೀಚಾರ್ಜ್ ಮಾಡಿ';

  @override
  String get myTripHistory => 'ನನ್ನ ಪ್ರಯಾಣದ ಇತಿಹಾಸ';

  @override
  String get noTransactions => 'ಇನ್ನೂ ಯಾವುದೇ ವಹಿವಾಟುಗಳಿಲ್ಲ.';

  @override
  String get rechargeCardTitle => 'ಕಾರ್ಡ್ ರೀಚಾರ್ಜ್';

  @override
  String get amountRupees => 'ಮೊತ್ತ (₹)';

  @override
  String get payAndRecharge => 'ಪಾವತಿಸಿ ಮತ್ತು ರೀಚಾರ್ಜ್ ಮಾಡಿ';

  @override
  String get rfidWallets => 'RFID ವಾಲೆಟ್‌ಗಳು';

  @override
  String get noRegisteredCards =>
      'ಇನ್ನೂ ಯಾವುದೇ RFID ಕಾರ್ಡ್‌ಗಳು ನೋಂದಾಯಿಸಲ್ಪಟ್ಟಿಲ್ಲ.';

  @override
  String get registerNewRfid => 'ಹೊಸ RFID ನೋಂದಾಯಿಸಿ';

  @override
  String get registerNewRfidTitle => 'ಹೊಸ RFID ಕಾರ್ಡ್ ನೋಂದಾಯಿಸಿ';

  @override
  String get cardUidHex => 'ಕಾರ್ಡ್ UID (Hex)';

  @override
  String get holderName => 'ಕಾರ್ಡ್ ಹೊಂದಿರುವವರ ಹೆಸರು';

  @override
  String get addCard => 'ಕಾರ್ಡ್ ಸೇರಿಸಿ';

  @override
  String get noRealCards =>
      'ಪ್ರಯಾಣಿಕರನ್ನು ಸೇರಿಸುವ ಮೊದಲು ನಿಜವಾದ RFID ಕಾರ್ಡ್ ನೋಂದಾಯಿಸಿ.';

  @override
  String get cardActive => 'ಸಕ್ರಿಯ';

  @override
  String get cardInactive => 'ನಿಷ್ಕ್ರಿಯ';

  @override
  String get cardOnboard => 'ಬೋರ್ಡ್‌ನಲ್ಲಿದ್ದಾರೆ';

  @override
  String get searchPassenger => 'ಪ್ರಯಾಣಿಕ ಅಥವಾ UID ಹುಡುಕಿ...';

  @override
  String get noMatchFound => 'ಯಾವುದೇ ಹೊಂದಾಣಿಕೆಯ ಪ್ರಯಾಣಿಕರು ಕಂಡುಬಂದಿಲ್ಲ.';

  @override
  String get transactionsTitle => 'RFID ವಹಿವಾಟುಗಳು ಮತ್ತು ದರ ಲೆಕ್ಕಪರಿಶೋಧನೆ';

  @override
  String get colTime => 'ಸಮಯ';

  @override
  String get colPassenger => 'ಪ್ರಯಾಣಿಕ';

  @override
  String get colUid => 'ಕಾರ್ಡ್ UID';

  @override
  String get colType => 'ಪ್ರಕಾರ';

  @override
  String get colStop => 'ನಿಲ್ದಾಣ / ಮಾರ್ಗ';

  @override
  String get colAmount => 'ಮೊತ್ತ';

  @override
  String get colBalance => 'ಉಳಿಕೆ ಬ್ಯಾಲೆನ್ಸ್';

  @override
  String get typeBoarding => 'ಪ್ರವೇಶ (ಹತ್ತಿದರು)';

  @override
  String get typeExit => 'ನಿರ್ಗಮನ (ಇಳಿದರು)';

  @override
  String get typeRecharge => 'ರೀಚಾರ್ಜ್';

  @override
  String get typeDenied => 'ನಿರಾಕರಿಸಲಾಗಿದೆ';

  @override
  String get reasonLowBalance => 'ಕಡಿಮೆ ಬ್ಯಾಲೆನ್ಸ್';

  @override
  String get reasonDeactivated => 'ಅಮಾನತುಗೊಂಡ ಕಾರ್ಡ್';

  @override
  String get reasonInvalid => 'ನೋಂದಾಯಿಸದ ಕಾರ್ಡ್';

  @override
  String get passengerHistoryTitle => 'ಪ್ರಯಾಣಿಕರ ಪ್ರಯಾಣ ಲೆಕ್ಕಪರಿಶೋಧನೆ';

  @override
  String get aiAssistantTitle => 'AI & ML ಮಾರ್ಗ ಚಾಟ್‌ಬಾಟ್';

  @override
  String get aiAssistantSubtitle =>
      'BMTC ಮಾರ್ಗಗಳು (600F, 500D, 335E, 365, 25A), ಸಮಯ, ₹10/ನಿಲ್ದಾಣ ದರ ಮತ್ತು ಕಾರ್ಡ್ ವಿವರಗಳನ್ನು ಕೇಳಿ.';

  @override
  String get askHint =>
      'ಕನ್ನಡ, ಹಿಂದಿ ಅಥವಾ ಇಂಗ್ಲಿಷ್‌ನಲ್ಲಿ ಕೇಳಿ (ಉದಾ: 600F ಮಾರ್ಗ)...';

  @override
  String get voiceQuery => 'ಧ್ವನಿ ಪ್ರಶ್ನೆ';

  @override
  String get listening => 'ಕೇಳಿಸಿಕೊಳ್ಳುತ್ತಿದೆ... ನಿಮ್ಮ ಪ್ರಶ್ನೆ ಕೇಳಿ';

  @override
  String get quickPromptsTitle => 'ತ್ವರಿತ ಪ್ರಶ್ನೆಗಳು';

  @override
  String get promptNextStop => 'ಮುಂದಿನ ನಿಲ್ದಾಣ';

  @override
  String get promptBalance => 'ನನ್ನ ಕಾರ್ಡ್ ಬ್ಯಾಲೆನ್ಸ್';

  @override
  String get promptFare => 'ಕೆ.ಆರ್. ವೃತ್ತಕ್ಕೆ ದರ';

  @override
  String get promptCardStatus => 'ನನ್ನ ಕಾರ್ಡ್ ಸ್ಥಿತಿ';

  @override
  String get promptRoute600F => '600F ಮಾರ್ಗ';

  @override
  String get promptRoute500D => '500D ಮಾರ್ಗ';

  @override
  String get promptRoute335E => '335E ಮಾರ್ಗ';

  @override
  String get promptRoute365 => '365 ಮಾರ್ಗ';

  @override
  String get promptRoute25A => '25A ಮಾರ್ಗ';

  @override
  String get promptFareRule => '₹10 ದರ ನಿಯಮ';

  @override
  String get clearChat => 'ಚಾಟ್ ತೆರವುಗೊಳಿಸಿ';

  @override
  String get sendButton => 'ಕಳುಹಿಸಿ';

  @override
  String get speaking => 'ಮಾತನಾಡುತ್ತಿದೆ...';

  @override
  String get listenAudio => 'ಆಲಿಸಿ';

  @override
  String get routeTimelineTitle => 'ಬೆಂಗಳೂರು ಮಾರ್ಗದ ನಿಲ್ದಾಣಗಳು (18 ನಿಲ್ದಾಣಗಳು)';

  @override
  String get farePerStop => 'ಪ್ರತಿ ನಿಲ್ದಾಣಕ್ಕೆ ₹10';

  @override
  String get profileTitle => 'ಬಳಕೆದಾರರ ಪ್ರೊಫೈಲ್';

  @override
  String get settingsTitle => 'ವ್ಯವಸ್ಥೆಯ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get logoutButton => 'ಲಾಗ್‌ಔಟ್';

  @override
  String get roleLabel => 'ಪಾತ್ರ';

  @override
  String get emailAddress => 'ಇಮೇಲ್ ವಿಳಾಸ';

  @override
  String get linkedRfidCard => 'ಲಿಂಕ್ ಮಾಡಲಾದ RFID ಕಾರ್ಡ್';

  @override
  String get connected => 'ಸಂಪರ್ಕಗೊಂಡಿದೆ';

  @override
  String get disconnected => 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ';

  @override
  String get hardwareBridge => 'NodeMCU ಬ್ರಿಡ್ಜ್';

  @override
  String get tapCardPrompt =>
      'ಬಸ್ ಹತ್ತಲು ನಿಮ್ಮ RFID ಕಾರ್ಡ್ ಅನ್ನು ರೀಡರ್ ಮೇಲೆ ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get searchPassengerUid => 'ಪ್ರಯಾಣಿಕ / RFID UID ಹುಡುಕಿ';

  @override
  String get noPassengerRecords => 'ಯಾವುದೇ ಹೊಂದಾಣಿಕೆಯ ಪ್ರಯಾಣಿಕರ ದಾಖಲೆಗಳಿಲ್ಲ.';

  @override
  String get cardMustBeRegistered => 'RFID ಕಾರ್ಡ್ ಈಗಾಗಲೇ ನೋಂದಾಯಿಸಲ್ಪಟ್ಟಿರಬೇಕು.';

  @override
  String get enterValidPassengerDetails =>
      'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಪ್ರಯಾಣಿಕರ ವಿವರಗಳು ಮತ್ತು ನೋಂದಾಯಿತ RFID UID ನಮೂದಿಸಿ.';

  @override
  String get balanceLabel => 'ಬ್ಯಾಲೆನ್ಸ್';

  @override
  String get notLinked => 'ಲಿಂಕ್ ಮಾಡಲಾಗಿಲ್ಲ';

  @override
  String get signInTab => 'ಸೈನ್ ಇನ್';

  @override
  String get signUpTab => 'ಸೈನ್ ಅಪ್ / ನೋಂದಣಿ';

  @override
  String get fullNameLabel => 'ಪೂರ್ಣ ಹೆಸರು';

  @override
  String get rfidUidLabel => 'ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ UID (RFID)';

  @override
  String get rfidUidHelper => 'ಉದಾ., ನಿಮ್ಮ ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್‌ನಿಂದ 5B850B1A';

  @override
  String get confirmPasswordLabel => 'ಪಾಸ್‌ವರ್ಡ್ ದೃಢೀಕರಿಸಿ';

  @override
  String get registerButton => 'ಕಾರ್ಡ್ ಮತ್ತು ಖಾತೆಯನ್ನು ನೋಂದಾಯಿಸಿ';

  @override
  String get passwordsDoNotMatch => 'ಪಾಸ್‌ವರ್ಡ್‌ಗಳು ಹೊಂದಿಕೆಯಾಗುತ್ತಿಲ್ಲ.';

  @override
  String get registrationSuccess =>
      'ಖಾತೆ ಮತ್ತು ಸ್ಮಾರ್ಟ್ ಕಾರ್ಡ್ ಯಶಸ್ವಿಯಾಗಿ ನೋಂದಾಯಿಸಲ್ಪಟ್ಟಿದೆ!';

  @override
  String get alreadyHaveAccount => 'ಈಗಾಗಲೇ ಖಾತೆ ಹೊಂದಿದ್ದೀರಾ? ಸೈನ್ ಇನ್ ಮಾಡಿ';

  @override
  String get needAccountPrompt =>
      'ಹೊಸ ಪ್ರಯಾಣಿಕರೇ? ನಿಮ್ಮ RFID ಕಾರ್ಡ್ ಅನ್ನು ಇಲ್ಲಿ ನೋಂದಾಯಿಸಿ';
}
