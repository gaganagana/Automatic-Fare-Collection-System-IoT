import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Sends real emails through Gmail SMTP.
///
/// SETUP (see SETUP_GUIDE.md section 6 for the full walkthrough):
///  1. Use a Google account you control.
///  2. Turn on 2-Step Verification on that account.
///  3. Create an "App Password" (Google Account -> Security -> App
///     passwords) — a 16 character code. Do NOT use your normal Gmail
///     password here.
///  4. Paste that app password below (or, better, load it from
///     --dart-define so it never gets committed to git — see the guide).
///
/// This file intentionally keeps things simple for a student project. For a
/// production app, sending email directly from a mobile client is not
/// recommended (it exposes the SMTP credential inside the compiled app) —
/// the guide explains the safer alternative (a tiny backend / cloud
/// function) as well.
class EmailService {
  // ---- EDIT THESE THREE LINES -------------------------------------------
  static const String senderEmail = 'smartbuscontrol@gmail.com';
  static const String senderAppPassword = 'pdma govd dilc tmyc';
  static const String senderName = 'Smart Bus Control Room';
  // -------------------------------------------------------------------------

  static SmtpServer get _smtp => gmail(senderEmail, senderAppPassword);

  /// True once you've actually edited the two placeholder constants above.
  /// Used to skip a doomed network call (and its slow timeout) and instead
  /// return a clear, specific reason immediately.
  static bool get isConfigured =>
      senderEmail != 'youraddress@gmail.com' &&
      senderAppPassword != 'xxxx xxxx xxxx xxxx' &&
      senderEmail.contains('@') &&
      senderAppPassword.trim().isNotEmpty;

  /// Fired once, right after a successful login. Returns a result object
  /// instead of a bare bool so the UI can tell the person *why* it failed
  /// (not configured yet vs. a real send error) instead of failing silently.
  static Future<EmailResult> sendLoginNotification({
    required String toEmail,
    required String username,
    required String role,
  }) async {
    if (!isConfigured) {
      return EmailResult.skipped(
          'Email not sent — SMTP isn\'t configured yet (see lib/services/email_service.dart).');
    }
    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.add(toEmail)
      ..subject = 'Smart Bus Dashboard — New Login Detected'
      ..text = 'Hi $username,\n\n'
          'A successful login was just recorded on the Smart Bus '
          'Control Room dashboard.\n\n'
          'Role: $role\n'
          'Time: ${DateTime.now()}\n\n'
          'If this was not you, please contact the transport admin '
          'immediately.\n\n'
          '— Smart Bus IoT Fleet System';

    return _send(message);
  }

  /// Fired whenever a fare debit/credit happens, mirrors the in-app SMS
  /// banner as a real email as well (optional — call it if you want an
  /// email per transaction, not just per login).
  static Future<EmailResult> sendTransactionAlert({
    required String toEmail,
    required String body,
  }) async {
    if (!isConfigured) {
      return EmailResult.skipped('SMTP not configured yet.');
    }
    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.add(toEmail)
      ..subject = 'Smart Bus — Transaction Alert'
      ..text = body;

    return _send(message);
  }

  static Future<EmailResult> _send(Message message) async {
    try {
      await send(message, _smtp);
      return EmailResult.success();
    } catch (e) {
      // Give a specific, human-readable reason for the most common SMTP
      // failures instead of a raw exception dump.
      final msg = e.toString();
      String reason;
      if (msg.contains('535') || msg.toLowerCase().contains('username and password not accepted')) {
        reason = 'Gmail rejected the credentials — double check you used an '
            'App Password (not your normal Gmail password) and that 2-Step '
            'Verification is on.';
      } else if (msg.toLowerCase().contains('socket') || msg.toLowerCase().contains('timeout')) {
        reason = 'Could not reach Gmail\'s SMTP server — check the device\'s '
            'internet connection.';
      } else {
        reason = 'Send failed: $msg';
      }
      // ignore: avoid_print
      print('EmailService: $reason');
      return EmailResult.failure(reason);
    }
  }
}

class EmailResult {
  final bool sent;
  final String? reason; // populated when sent == false

  EmailResult._(this.sent, this.reason);
  factory EmailResult.success() => EmailResult._(true, null);
  factory EmailResult.failure(String reason) => EmailResult._(false, reason);
  factory EmailResult.skipped(String reason) => EmailResult._(false, reason);
}
