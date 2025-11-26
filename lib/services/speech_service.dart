import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  SpeechService._();
  static final SpeechService _instance = SpeechService._();
  factory SpeechService() => _instance;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;

  Future<void> init() async {
    try {
      _available = await _speech.initialize();
    } catch (e) {
      _available = false;
    }
  }

  bool get isAvailable => _available;

  /// Listens for a single phrase and returns the recognized text, or null.
  Future<String?> listen({int listenForSeconds = 8}) async {
    try {
      if (!_available) await init();
      if (!_available) return null;

      String? last;
      final completer = Completer<String?>();

      _speech.listen(
        onResult: (result) {
          last = result.recognizedWords;
          if (result.finalResult) {
            if (!completer.isCompleted) completer.complete(last);
          }
        },
        listenFor: Duration(seconds: listenForSeconds),
        cancelOnError: true,
      );

      // fallback: ensure we stop listening after timeout
      Future.delayed(Duration(seconds: listenForSeconds + 1), () async {
        if (!_speech.isNotListening) {
          await _speech.stop();
          if (!completer.isCompleted) completer.complete(last);
        }
      });

      return completer.future;
    } catch (e) {
      return null;
    }
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }
}
