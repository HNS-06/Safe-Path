import 'package:flutter_tts/flutter_tts.dart';

class VoiceNavigationService {
  VoiceNavigationService._();
  static final VoiceNavigationService _instance = VoiceNavigationService._();
  factory VoiceNavigationService() => _instance;

  final FlutterTts _tts = FlutterTts();
  String _language = 'en-US';

  Future<void> init() async {
    try {
      await _tts.setLanguage(_language);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      // swallow init errors; caller can still fallback
    }
  }

  Future<void> speak(String text, {String? lang}) async {
    try {
      if (lang != null && lang != _language) {
        _language = lang;
        await _tts.setLanguage(_language);
      }
      await _tts.speak(text);
    } catch (e) {
      // ignore TTS failures in demo context
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  void setLanguage(String lang) {
    _language = lang;
    _tts.setLanguage(lang);
  }
}
