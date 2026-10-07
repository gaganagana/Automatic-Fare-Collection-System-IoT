// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Bus Control Room';

  @override
  String get dashboardSubtitle =>
      'IoT Fleet Dashboard / Bengaluru Route - Bus-01';

  @override
  String get loginTitle => 'Smart Bus - Control Room';

  @override
  String get loginSubtitle =>
      'Sign in as Admin/Operator or with your Passenger card login.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginSuccessMessage =>
      'Login successful — a confirmation email is on its way.';

  @override
  String get registerPrompt => 'New passenger? Register a card account';

  @override
  String get statusLabel => 'Status';

  @override
  String get statusMoving => 'Moving';

  @override
  String get statusStopped => 'Stopped';

  @override
  String get onboardLabel => 'Onboard';

  @override
  String get enteredLabel => 'Entered';

  @override
  String get exitedLabel => 'Exited';

  @override
  String get trafficLabel => 'Traffic';

  @override
  String get trafficLow => 'Low';

  @override
  String get trafficMedium => 'Medium';

  @override
  String get trafficHigh => 'High';

  @override
  String get currentStopLabel => 'Current Stop';

  @override
  String get nextStopLabel => 'Next Stop Announcement';

  @override
  String get currentRoute => 'CURRENT ROUTE';

  @override
  String get activeTransit => 'ACTIVE TRANSIT';

  @override
  String get routeSummary => 'Kempegowda BS → BTM Layout (18 Stops)';

  @override
  String get fareRate => 'Fare: ₹10 per stop';

  @override
  String get liveMapTitle => 'LIVE BUS ROUTE MAP';

  @override
  String get speedKmh => 'km/h';

  @override
  String get startSimulator => 'Start Simulator';

  @override
  String get stopSimulator => 'Stop Simulator';

  @override
  String get simulateTap => 'Simulate RFID Tap';

  @override
  String get rechargeButton => 'Recharge';

  @override
  String get registerCard => 'Register New RFID';

  @override
  String busStatusSemantic(String status, String speed, String stop) {
    return 'Bus status: $status, speed $speed kilometers per hour, currently at $stop';
  }

  @override
  String ttsBoarding(String name, String stop, String amount) {
    return '$name boarded at $stop. Fare $amount rupees deducted.';
  }

  @override
  String ttsExit(String name, String stop) {
    return '$name exited at $stop.';
  }

  @override
  String get ttsDenied => 'Access denied. Insufficient balance.';

  @override
  String ttsApproachingStop(String stop) {
    return 'Approaching $stop.';
  }

  @override
  String ttsRecharge(String amount) {
    return 'Recharge successful. New balance $amount rupees.';
  }

  @override
  String get languageLabel => 'Language';

  @override
  String get ttsToggleLabel => 'Voice announcements';

  @override
  String get controlRoomTitle => 'SMART BUS - CONTROL ROOM';

  @override
  String get adminPortal => 'Admin Dashboard';

  @override
  String get passengerPortal => 'Passenger Portal';

  @override
  String get passengerManagement => 'Passenger Management';

  @override
  String get noPassengers => 'No passengers registered yet.';

  @override
  String get addPassenger => 'Add Passenger';

  @override
  String get deletePassenger => 'Delete passenger';

  @override
  String confirmDeletePassenger(String name) {
    return 'Remove $name from the Smart Bus system?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get passengerName => 'Passenger name';

  @override
  String get temporaryPassword => 'Temporary password (min 6 characters)';

  @override
  String get registeredRfidUid => 'Registered RFID UID';

  @override
  String get addPassengerButton => 'ADD PASSENGER';

  @override
  String get passengerAdded => 'Passenger added successfully.';

  @override
  String get mySmartCard => 'MY SMART CARD';

  @override
  String get noCardLinked => 'No card linked to this account.';

  @override
  String get currentlyOnboard => 'Status: Currently onboard';

  @override
  String get notOnTrip => 'Status: Not on a trip';

  @override
  String get rechargeMyCard => 'RECHARGE MY CARD';

  @override
  String get myTripHistory => 'MY TRIP HISTORY';

  @override
  String get noTransactions => 'No transactions yet.';

  @override
  String get rechargeCardTitle => 'Recharge Card';

  @override
  String get amountRupees => 'Amount (₹)';

  @override
  String get payAndRecharge => 'PAY & RECHARGE';

  @override
  String get rfidWallets => 'RFID WALLETS';

  @override
  String get noRegisteredCards => 'No registered RFID cards yet.';

  @override
  String get registerNewRfid => 'REGISTER NEW RFID';

  @override
  String get registerNewRfidTitle => 'Register New RFID Card';

  @override
  String get cardUidHex => 'Card UID (Hex)';

  @override
  String get holderName => 'Holder Name';

  @override
  String get addCard => 'ADD CARD';

  @override
  String get noRealCards =>
      'Register a real RFID card before adding a passenger.';

  @override
  String get cardActive => 'ACTIVE';

  @override
  String get cardInactive => 'INACTIVE';

  @override
  String get cardOnboard => 'ONBOARD';

  @override
  String get searchPassenger => 'Search passenger or UID...';

  @override
  String get noMatchFound => 'No matching passenger or card found.';

  @override
  String get transactionsTitle => 'RFID TRANSACTIONS & FARE AUDIT';

  @override
  String get colTime => 'Time';

  @override
  String get colPassenger => 'Passenger';

  @override
  String get colUid => 'Card UID';

  @override
  String get colType => 'Type';

  @override
  String get colStop => 'Stop / Route';

  @override
  String get colAmount => 'Amount';

  @override
  String get colBalance => 'Balance';

  @override
  String get typeBoarding => 'BOARDING';

  @override
  String get typeExit => 'EXIT';

  @override
  String get typeRecharge => 'RECHARGE';

  @override
  String get typeDenied => 'DENIED';

  @override
  String get reasonLowBalance => 'Low Balance';

  @override
  String get reasonDeactivated => 'Deactivated Card';

  @override
  String get reasonInvalid => 'Unregistered Card';

  @override
  String get passengerHistoryTitle => 'PASSENGER JOURNEY AUDIT';

  @override
  String get aiAssistantTitle => 'AI & ML ROUTE CHATBOT';

  @override
  String get aiAssistantSubtitle =>
      'Ask about BMTC routes (600F, 500D, 335E, 365, 25A), timings, ₹10/stop fares & card info.';

  @override
  String get askHint =>
      'Ask in Kannada, Hindi, or English (e.g. 600F route)...';

  @override
  String get voiceQuery => 'Voice Query';

  @override
  String get listening => 'Listening... Speak your query';

  @override
  String get quickPromptsTitle => 'Quick Queries';

  @override
  String get promptNextStop => 'Next stop';

  @override
  String get promptBalance => 'My card balance';

  @override
  String get promptFare => 'Fare to KR Circle';

  @override
  String get promptCardStatus => 'My card status';

  @override
  String get promptRoute600F => '600F Route';

  @override
  String get promptRoute500D => '500D Route';

  @override
  String get promptRoute335E => '335E Route';

  @override
  String get promptRoute365 => '365 Route';

  @override
  String get promptRoute25A => '25A Route';

  @override
  String get promptFareRule => '₹10 Fare Rule';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get sendButton => 'Send';

  @override
  String get speaking => 'Speaking...';

  @override
  String get listenAudio => 'Listen';

  @override
  String get routeTimelineTitle => 'BENGALURU ROUTE STOPS (18 STOPS)';

  @override
  String get farePerStop => '₹10 / stop';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get settingsTitle => 'System Settings';

  @override
  String get logoutButton => 'Logout';

  @override
  String get roleLabel => 'Role';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get linkedRfidCard => 'Linked RFID Card';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get hardwareBridge => 'NodeMCU Bridge';

  @override
  String get tapCardPrompt => 'Tap your RFID card on the reader to board';

  @override
  String get searchPassengerUid => 'Search passenger / RFID UID';

  @override
  String get noPassengerRecords => 'No matching passenger records.';

  @override
  String get cardMustBeRegistered =>
      'The RFID card must already be registered.';

  @override
  String get enterValidPassengerDetails =>
      'Please enter valid passenger details and a registered RFID UID.';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get notLinked => 'Not linked';

  @override
  String get signInTab => 'Sign In';

  @override
  String get signUpTab => 'Sign Up / Register';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get rfidUidLabel => 'Smart Card UID (RFID)';

  @override
  String get rfidUidHelper => 'e.g., 5B850B1A from your smart card';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerButton => 'Register Card & Account';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get registrationSuccess =>
      'Account and smart card registered successfully!';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get needAccountPrompt => 'New passenger? Register your RFID card here';
}
