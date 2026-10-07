import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Thin wrapper around the Razorpay Flutter plugin.
///
/// TEST MODE ONLY — the key below starts with "rzp_test_", which is a
/// public, safe-to-ship test key. Test mode can NEVER move real money —
/// it's a sandbox Razorpay provides specifically for development. Replace
/// it with your own test key from the Razorpay Dashboard (Settings ->
/// API Keys, after signing up for a free account) before using this.
///
/// This class does not touch AppState, Firestore, or the UI directly —
/// it only knows how to open the checkout screen and report back
/// success/failure/external-wallet events via plain callbacks. AppState
/// (see app_state.dart) is what decides what to DO with those events
/// (update the balance, write to Firestore, show the SMS banner, etc.).
class PaymentService {
  // TODO: replace with your own Razorpay test Key ID before building.
  static const String testKeyId = 'rzp_test_TQVSuAt5JWQLNi';

  final Razorpay _razorpay = Razorpay();

  void startCheckout({
    required double amountRupees,
    required String holderName,
    required String contactEmail,
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onError,
    void Function(ExternalWalletResponse response)? onExternalWallet,
  }) {
    _razorpay.clear();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      onExternalWallet ?? (ExternalWalletResponse response) {},
    );

    // Razorpay takes the amount in paise (1 rupee = 100 paise), as an int.
    final amountPaise = (amountRupees * 100).round();

    final options = {
      'key': testKeyId,
      'amount': amountPaise,
      'name': 'Smart Bus',
      'description': 'RFID card recharge',
      'prefill': {
        'contact': '', // left blank — no phone number is collected in this app
        'email': contactEmail,
      },
      'notes': {'holder': holderName},
      'theme': {'color': '#1F8A4C'},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
