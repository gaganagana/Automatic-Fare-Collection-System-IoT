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
  String get currentStopLabel => 'Current Stop';

  @override
  String get nextStopLabel => 'Next Stop Announcement';

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
}
