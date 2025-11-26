import 'package:safepath/models/safety_report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safepath/features/voice_navigation/voice_navigation_service.dart';
import 'package:safepath/services/speech_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  bool _isListening = false;
  bool _enabled = false;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool('voice_assistant') ?? true;
      if (_enabled) {
        await VoiceNavigationService().init();
      }
    } catch (e) {
      _enabled = false;
    }
  }

  bool get isListening => _isListening;
  bool get isAvailable => _enabled;

  Future<void> speak(String text) async {
    if (!_enabled) return;
    await VoiceNavigationService().speak(text);
  }

  Future<void> stopSpeaking() async {
    await VoiceNavigationService().stop();
  }

  Future<SafetyReport?> listenForSafetyReport({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    if (!_enabled) {
      onError?.call('Voice assistant is unavailable');
      return null;
    }
    _isListening = true;
    try {
      await SpeechService().init();
      final text = await SpeechService().listen();
      if (text == null || text.isEmpty) {
        onError?.call('No voice input recognized');
        _isListening = false;
        return null;
      }

      onResult(text);

      final type = VoiceService.parseSafetyCommand(text) ?? SafetyType.unknown;
      final rating = type == SafetyType.safe ? 4.5 : (type == SafetyType.moderate ? 3.0 : 2.0);

      final report = SafetyReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        location: LatLng(0, 0),
        type: type,
        description: text,
        rating: rating,
        timestamp: DateTime.now(),
      );

      _isListening = false;
      return report;
    } catch (e) {
      onError?.call(e.toString());
      _isListening = false;
      return null;
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
    try {
      await SpeechService().stop();
    } catch (_) {}
  }

  /// Enable or disable the voice assistant and persist preference.
  Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_assistant', enabled);
    if (enabled) {
      await VoiceNavigationService().init();
    } else {
      await VoiceNavigationService().stop();
    }
  }

  static SafetyType? parseSafetyCommand(String command) {
    final lowerCommand = command.toLowerCase();
    
    if (lowerCommand.contains('safe') && 
        !lowerCommand.contains('not') && 
        !lowerCommand.contains('unsafe')) {
      return SafetyType.safe;
    } else if (lowerCommand.contains('not safe') || 
               lowerCommand.contains('unsafe') ||
               lowerCommand.contains('dangerous')) {
      return SafetyType.unsafe;
    } else if (lowerCommand.contains('moderate') || 
               lowerCommand.contains('okay') ||
               lowerCommand.contains('ok')) {
      return SafetyType.moderate;
    } else if (lowerCommand.contains('traffic') && 
               (lowerCommand.contains('more') || 
                lowerCommand.contains('heavy') || 
                lowerCommand.contains('busy'))) {
      return SafetyType.moderate;
    }
    
    return null;
  }
}
