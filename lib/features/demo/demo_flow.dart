import 'dart:async';
import 'package:flutter/material.dart';
import 'package:safepath/features/voice_navigation/voice_navigation_service.dart';
import 'package:safepath/features/weather/weather_service.dart';
import 'package:safepath/features/weather/weather_safety_integration.dart';
import 'package:safepath/models/location_model.dart';

class DemoFlow {
  DemoFlow._();
  static final DemoFlow _instance = DemoFlow._();
  factory DemoFlow() => _instance;

  Future<void> runDemo(BuildContext context, LocationModel center) async {
    final v = VoiceNavigationService();
    await v.init();

    // Speak an intro
    await v.speak('Welcome to SafePath demo. We will show voice guidance, weather integration and navigation.');

    // Fetch weather
    final weather = await WeatherServiceFeature().fetchWeather(center);
    final suggestion = WeatherSafetyIntegration.suggestionFromReport(weather);
    await v.speak(suggestion);

    // Guidance demo
    await Future.delayed(const Duration(seconds: 1));
    await v.speak('Starting navigation demo. Turn left - safe, well-lit route.');

    // Show a visual cue
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Demo: $suggestion')));
    }

    await Future.delayed(const Duration(seconds: 3));
    await v.speak('Demo complete. Thank you for trying SafePath.');
  }
}
