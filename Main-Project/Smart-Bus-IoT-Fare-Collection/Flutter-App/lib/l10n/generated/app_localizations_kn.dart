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
  String get onboardLabel => 'ಬೋರ್ಡ್‌ನಲ್ಲಿ';

  @override
  String get enteredLabel => 'ಪ್ರವೇಶಿಸಿದವರು';

  @override
  String get exitedLabel => 'ನಿರ್ಗಮಿಸಿದವರು';

  @override
  String get currentStopLabel => 'ಪ್ರಸ್ತುತ ನಿಲ್ದಾಣ';

  @override
  String get nextStopLabel => 'ಮುಂದಿನ ನಿಲ್ದಾಣ ಪ್ರಕಟಣೆ';

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
}
