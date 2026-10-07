// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'स्मार्ट बस नियंत्रण कक्ष';

  @override
  String get dashboardSubtitle => 'IoT फ्लीट डैशबोर्ड / बेंगलुरु मार्ग - बस-01';

  @override
  String get loginTitle => 'स्मार्ट बस - नियंत्रण कक्ष';

  @override
  String get loginSubtitle => 'एडमिन/ऑपरेटर या यात्री कार्ड से साइन इन करें।';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get loginButton => 'लॉगिन';

  @override
  String get loginSuccessMessage => 'लॉगिन सफल — पुष्टि ईमेल भेजा जा रहा है।';

  @override
  String get registerPrompt => 'नए यात्री? कार्ड खाता पंजीकृत करें';

  @override
  String get statusLabel => 'स्थिति';

  @override
  String get statusMoving => 'चल रहा है';

  @override
  String get statusStopped => 'रुका हुआ';

  @override
  String get onboardLabel => 'बस में हैं';

  @override
  String get enteredLabel => 'प्रवेश';

  @override
  String get exitedLabel => 'निकास';

  @override
  String get trafficLabel => 'ट्रैफ़िक';

  @override
  String get trafficLow => 'कम';

  @override
  String get trafficMedium => 'मध्यम';

  @override
  String get trafficHigh => 'अधिक';

  @override
  String get currentStopLabel => 'वर्तमान स्टॉप';

  @override
  String get nextStopLabel => 'अगले स्टॉप की घोषणा';

  @override
  String get currentRoute => 'वर्तमान मार्ग';

  @override
  String get activeTransit => 'सक्रिय पारगमन';

  @override
  String get routeSummary => 'केम्पेगौड़ा बी.एस. → बीटीएम लेआउट (18 स्टॉप)';

  @override
  String get fareRate => 'किराया: ₹10 प्रति स्टॉप';

  @override
  String get liveMapTitle => 'लाइव बस रूट मानचित्र';

  @override
  String get speedKmh => 'किमी/घंटा';

  @override
  String get startSimulator => 'सिम्युलेटर शुरू करें';

  @override
  String get stopSimulator => 'सिम्युलेटर रोकें';

  @override
  String get simulateTap => 'RFID टैप सिम्युलेट करें';

  @override
  String get rechargeButton => 'रिचार्ज';

  @override
  String get registerCard => 'नया RFID पंजीकृत करें';

  @override
  String busStatusSemantic(String status, String speed, String stop) {
    return 'बस स्थिति: $status, गति $speed किलोमीटर प्रति घंटा, वर्तमान में $stop पर';
  }

  @override
  String ttsBoarding(String name, String stop, String amount) {
    return '$name $stop पर बस में चढ़े। $amount रुपये किराया काटा गया।';
  }

  @override
  String ttsExit(String name, String stop) {
    return '$name $stop पर बस से उतरे।';
  }

  @override
  String get ttsDenied => 'प्रवेश अस्वीकृत। पर्याप्त बैलेंस नहीं है।';

  @override
  String ttsApproachingStop(String stop) {
    return '$stop पास आ रहा है।';
  }

  @override
  String ttsRecharge(String amount) {
    return 'रिचार्ज सफल हुआ। नया बैलेंस $amount रुपये है.';
  }

  @override
  String get languageLabel => 'भाषा';

  @override
  String get ttsToggleLabel => 'आवाज घोषणाएं';

  @override
  String get controlRoomTitle => 'स्मार्ट बस - नियंत्रण कक्ष';

  @override
  String get adminPortal => 'एडमिन डैशबोर्ड';

  @override
  String get passengerPortal => 'यात्री पोर्टल';

  @override
  String get passengerManagement => 'यात्री प्रबंधन';

  @override
  String get noPassengers => 'अभी तक कोई यात्री पंजीकृत नहीं है।';

  @override
  String get addPassenger => 'यात्री जोड़ें';

  @override
  String get deletePassenger => 'यात्री हटाएं';

  @override
  String confirmDeletePassenger(String name) {
    return 'क्या $name को स्मार्ट बस सिस्टम से हटाना है?';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get passengerName => 'यात्री का नाम';

  @override
  String get temporaryPassword => 'अस्थायी पासवर्ड (कम से कम 6 अक्षर)';

  @override
  String get registeredRfidUid => 'पंजीकृत RFID UID';

  @override
  String get addPassengerButton => 'यात्री जोड़ें';

  @override
  String get passengerAdded => 'यात्री सफलतापूर्वक जोड़ा गया।';

  @override
  String get mySmartCard => 'मेरा स्मार्ट कार्ड';

  @override
  String get noCardLinked => 'इस खाते से कोई कार्ड लिंक नहीं है।';

  @override
  String get currentlyOnboard => 'स्थिति: अभी बस में हैं';

  @override
  String get notOnTrip => 'स्थिति: यात्रा पर नहीं';

  @override
  String get rechargeMyCard => 'मेरा कार्ड रिचार्ज करें';

  @override
  String get myTripHistory => 'मेरी यात्रा का इतिहास';

  @override
  String get noTransactions => 'अभी तक कोई लेनदेन नहीं है।';

  @override
  String get rechargeCardTitle => 'कार्ड रिचार्ज';

  @override
  String get amountRupees => 'राशि (₹)';

  @override
  String get payAndRecharge => 'भुगतान करें और रिचार्ज करें';

  @override
  String get rfidWallets => 'RFID वॉलेट';

  @override
  String get noRegisteredCards => 'अभी तक कोई RFID कार्ड पंजीकृत नहीं है।';

  @override
  String get registerNewRfid => 'नया RFID पंजीकृत करें';

  @override
  String get registerNewRfidTitle => 'नया RFID कार्ड पंजीकृत करें';

  @override
  String get cardUidHex => 'कार्ड UID (Hex)';

  @override
  String get holderName => 'धारक का नाम';

  @override
  String get addCard => 'कार्ड जोड़ें';

  @override
  String get noRealCards =>
      'यात्री जोड़ने से पहले वास्तविक RFID कार्ड पंजीकृत करें।';

  @override
  String get cardActive => 'सक्रिय';

  @override
  String get cardInactive => 'निष्क्रिय';

  @override
  String get cardOnboard => 'बस में हैं';

  @override
  String get searchPassenger => 'यात्री या UID खोजें...';

  @override
  String get noMatchFound => 'कोई मेल खाने वाला यात्री या कार्ड नहीं मिला।';

  @override
  String get transactionsTitle => 'RFID लेनदेन और किराया ऑडिट';

  @override
  String get colTime => 'समय';

  @override
  String get colPassenger => 'यात्री';

  @override
  String get colUid => 'कार्ड UID';

  @override
  String get colType => 'प्रकार';

  @override
  String get colStop => 'स्टॉप / मार्ग';

  @override
  String get colAmount => 'राशि';

  @override
  String get colBalance => 'शेष राशि';

  @override
  String get typeBoarding => 'प्रवेश (सवारी)';

  @override
  String get typeExit => 'निकास (उतरे)';

  @override
  String get typeRecharge => 'रिचार्ज';

  @override
  String get typeDenied => 'अस्वीकृत';

  @override
  String get reasonLowBalance => 'कम बैलेंस';

  @override
  String get reasonDeactivated => 'निष्क्रिय कार्ड';

  @override
  String get reasonInvalid => 'अवैध कार्ड';

  @override
  String get passengerHistoryTitle => 'यात्री यात्रा ऑडिट';

  @override
  String get aiAssistantTitle => 'AI & ML मार्ग चैटबॉट';

  @override
  String get aiAssistantSubtitle =>
      'BMTC रूट्स (600F, 500D, 335E, 365, 25A), समय, ₹10/स्टॉप किराया और कार्ड की जानकारी पूछें।';

  @override
  String get askHint =>
      'कन्नड़, हिंदी या अंग्रेजी में पूछें (उदा: 600F रूट)...';

  @override
  String get voiceQuery => 'आवाज प्रश्न';

  @override
  String get listening => 'सुन रहा है... अपना प्रश्न बोलें';

  @override
  String get quickPromptsTitle => 'त्वरित प्रश्न';

  @override
  String get promptNextStop => 'अगला स्टॉप';

  @override
  String get promptBalance => 'मेरा कार्ड बैलेंस';

  @override
  String get promptFare => 'के.आर. सर्कल का किराया';

  @override
  String get promptCardStatus => 'मेरे कार्ड की स्थिति';

  @override
  String get promptRoute600F => '600F रूट';

  @override
  String get promptRoute500D => '500D रूट';

  @override
  String get promptRoute335E => '335E रूट';

  @override
  String get promptRoute365 => '365 रूट';

  @override
  String get promptRoute25A => '25A रूट';

  @override
  String get promptFareRule => '₹10 किराया नियम';

  @override
  String get clearChat => 'चैट साफ़ करें';

  @override
  String get sendButton => 'भेजें';

  @override
  String get speaking => 'बोल रहा है...';

  @override
  String get listenAudio => 'सुनें';

  @override
  String get routeTimelineTitle => 'बेंगलुरु रूट स्टॉप्स (18 स्टॉप)';

  @override
  String get farePerStop => '₹10 / स्टॉप';

  @override
  String get profileTitle => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String get settingsTitle => 'सिस्टम सेटिंग्स';

  @override
  String get logoutButton => 'लॉगआउट';

  @override
  String get roleLabel => 'भूमिका';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get linkedRfidCard => 'लिंक्ड RFID कार्ड';

  @override
  String get connected => 'कनेक्टेड';

  @override
  String get disconnected => 'डिस्कनेक्टेड';

  @override
  String get hardwareBridge => 'NodeMCU ब्रिज';

  @override
  String get tapCardPrompt =>
      'बस में चढ़ने के लिए अपने RFID कार्ड को रीडर पर टैप करें';

  @override
  String get searchPassengerUid => 'यात्री / RFID UID खोजें';

  @override
  String get noPassengerRecords =>
      'कोई मेल खाने वाला यात्री रिकॉर्ड नहीं मिला।';

  @override
  String get cardMustBeRegistered => 'RFID कार्ड पहले से पंजीकृत होना चाहिए।';

  @override
  String get enterValidPassengerDetails =>
      'कृपया मान्य यात्री विवरण और एक पंजीकृत RFID UID दर्ज करें।';

  @override
  String get balanceLabel => 'बैलेंस';

  @override
  String get notLinked => 'लिंक नहीं किया गया';

  @override
  String get signInTab => 'साइन इन';

  @override
  String get signUpTab => 'साइन अप / पंजीकरण';

  @override
  String get fullNameLabel => 'पूरा नाम';

  @override
  String get rfidUidLabel => 'स्मार्ट कार्ड UID (RFID)';

  @override
  String get rfidUidHelper => 'उदा., आपके स्मार्ट कार्ड से 5B850B1A';

  @override
  String get confirmPasswordLabel => 'पासवर्ड की पुष्टि करें';

  @override
  String get registerButton => 'कार्ड और खाता पंजीकृत करें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get registrationSuccess =>
      'खाता और स्मार्ट कार्ड सफलतापूर्वक पंजीकृत हो गया!';

  @override
  String get alreadyHaveAccount =>
      'क्या आपके पास पहले से एक खाता मौजूद है? साइन इन करें';

  @override
  String get needAccountPrompt =>
      'नए यात्री? अपना RFID कार्ड यहाँ पंजीकृत करें';
}
