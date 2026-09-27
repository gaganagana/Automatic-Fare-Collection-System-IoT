import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around `flutter_tts` so the rest of the app never touches
/// the plugin directly. Import this one class wherever you need to speak
/// something out loud (stop announcements, fare alerts, denied taps).
///
/// Usage:
///   final tts = TtsService();
///   await tts.setLanguage('kn-IN');   // or 'en-IN'
///   await tts.speak('Approaching KR Circle');
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _initialized = false;
  bool enabled = true; // lets the UI mute announcements without disposing the engine

  /// Maps the app's Locale codes to the BCP-47 language tags flutter_tts
  /// expects. Kannada TTS voice availability depends on the device — most
  /// modern Android phones have it via Google's TTS engine (Settings ->
  /// System -> Languages -> Text-to-speech -> install Kannada voice data
  /// if it's missing). iOS Kannada support varies by device/OS version.
  static const Map<String, String> _localeToTtsLanguage = {
    'en': 'en-IN',
    'kn': 'kn-IN',
  };

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _flutterTts.setSpeechRate(0.48); // slightly slower than default — clearer for transit announcements
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    _initialized = true;
  }

  /// Switches the TTS engine's voice/language. Call this whenever the
  /// app's locale changes (see AppState.setLocale).
  Future<void> setLanguage(String localeCode) async {
    await _ensureInit();
    final ttsLang = _localeToTtsLanguage[localeCode] ?? 'en-IN';
    try {
      await _flutterTts.setLanguage(ttsLang);
    } catch (e) {
      debugPrint('TtsService: language "$ttsLang" not available on this device — $e');
    }
  }

  /// Speaks [text] aloud. No-ops silently if TTS has been muted via
  /// [enabled], so callers don't need to check that flag everywhere.
  Future<void> speak(String text) async {
    if (!enabled || text.trim().isEmpty) return;
    await _ensureInit();
    await _flutterTts.stop(); // cut off whatever was mid-sentence so announcements don't queue up and lag behind real events
    await _flutterTts.speak(text);
  }

  Future<void> stop() => _flutterTts.stop();

  void dispose() {
    _flutterTts.stop();
  }
}
