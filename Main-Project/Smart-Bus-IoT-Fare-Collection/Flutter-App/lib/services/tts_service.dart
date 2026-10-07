import 'package:flutter/foundation.dart';

/// Lightweight no-op stand-in for text-to-speech.
///
/// The real flutter_tts plugin was removed — as of this build, it (along
/// with google_maps_flutter) triggers a known, unresolved Kotlin/Gradle
/// build-tool bug on Windows ("Could not close incremental caches" /
/// flutter/flutter#173456), which has nothing to do with this project's
/// code and can't be fixed from the Dart side. Removing the plugin keeps
/// the app light and reliably buildable.
///
/// This class keeps the exact same method signatures AppState already
/// calls (speak, setLanguage, stop, dispose, enabled), so nothing else in
/// the app needs to change — voice announcements are just silently
/// skipped instead of spoken. If you want real TTS back later, re-add
/// flutter_tts to pubspec.yaml and restore the implementation that calls
/// FlutterTts() here — everything that calls this class stays unchanged.
class TtsService {
  bool enabled = true;

  Future<void> setLanguage(String localeCode) async {
    debugPrint('TtsService (stub): language set to $localeCode — no plugin installed, nothing spoken.');
  }

  Future<void> speak(String text) async {
    debugPrint('TtsService (stub): would have said "$text"');
  }

  Future<void> stop() async {}

  void dispose() {}
}
