import 'dart:math';

import 'package:flutter/material.dart';
import 'package:safepath/ai/models/safety_prediction.dart';
import 'package:safepath/models/location_model.dart';

/// Mock AI/ML service that generates predictive safety insights.
///
/// In production this would call a backend/ML model. For the hackathon demo we
/// generate believable, deterministic data based on the location coordinates,
/// current time, and pseudo-random noise so every run feels fresh.
class SafetyPredictionService {
  SafetyPredictionService._();

  static final SafetyPredictionService _instance = SafetyPredictionService._();

  factory SafetyPredictionService() => _instance;

  static const List<Color> _palette = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF06D6A0),
    Color(0xFFFFD166),
    Color(0xFFEF476F),
  ];

  /// Generates a list of safety predictions for the provided location.
  Future<List<SafetyPrediction>> getPredictions({
    required LocationModel location,
    required DateTime time,
    bool demoMode = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 650));
    final seed = _calculateSeed(location, time);
    final random = Random(seed);

    final int clusterCount = 4 + random.nextInt(3); // 4-6 clusters

    return List.generate(clusterCount, (index) {
      final baseScore = 0.35 + (random.nextDouble() * 0.6);
      final timeFactor = _timeOfDayModifier(time, index);
      final weatherFactor = _mockWeatherModifier(random);
      final double finalScore =
          (baseScore * timeFactor * weatherFactor).clamp(0.1, 0.95);

      return SafetyPrediction(
        areaName: _mockAreaName(index, location, random),
        predictedScore: finalScore,
        timeRange: _timeRangeLabel(time, index),
        weatherImpact: _mockWeatherSummary(weatherFactor),
        confidence: 0.55 + random.nextDouble() * 0.4,
        riskFactors: _mockRiskFactors(random),
        recommendations: _mockRecommendations(random),
        accentColor: _palette[index % _palette.length],
      );
    }).toList();
  }

  int _calculateSeed(LocationModel location, DateTime time) {
    return location.latitude.toInt().abs() * 31 +
        location.longitude.toInt().abs() * 17 +
        time.hour * 13 +
        time.minute;
  }

  double _timeOfDayModifier(DateTime time, int index) {
    final hour = (time.hour + index * 2) % 24;
    if (hour >= 22 || hour <= 5) return 0.65;
    if (hour >= 18) return 0.8;
    if (hour >= 12) return 1.0;
    if (hour >= 7) return 0.92;
    return 0.75;
  }

  double _mockWeatherModifier(Random random) {
    const weatherMultipliers = [0.7, 0.85, 0.95, 1.0];
    return weatherMultipliers[random.nextInt(weatherMultipliers.length)];
  }

  String _timeRangeLabel(DateTime time, int index) {
    final start = time.add(Duration(hours: index * 2));
    final end = start.add(const Duration(hours: 2));
    return '${_twoDigit(start.hour)}:00 - ${_twoDigit(end.hour)}:00';
  }

  String _twoDigit(int value) => value.toString().padLeft(2, '0');

  String _mockAreaName(
    int index,
    LocationModel location,
    Random random,
  ) {
    final suffixes = ['Plaza', 'Avenue', 'Corridor', 'Walkway', 'District'];
    final direction = ['North', 'South', 'East', 'West'][random.nextInt(4)];
    return '$direction Sector ${location.latitude.round() + index} '
        '${suffixes[random.nextInt(suffixes.length)]}';
  }

  List<String> _mockRiskFactors(Random random) {
    const options = [
      'Low visibility corridors',
      'Sparse foot traffic',
      'Recent crowd reports',
      'Weather-related slippery zones',
      'Limited surveillance coverage',
      'High vehicular density',
    ];
    options.shuffle(random);
    return options.take(3).toList();
  }

  List<String> _mockRecommendations(Random random) {
    const suggestions = [
      'Enable buddy system before entering the zone',
      'Stay near well-lit storefronts',
      'Switch to Guardian-approved safe route',
      'Share live location with trusted contacts',
      'Avoid entry during low visibility hours',
    ];
    suggestions.shuffle(random);
    return suggestions.take(2).toList();
  }

  String _mockWeatherSummary(double weatherFactor) {
    if (weatherFactor >= 0.95) return 'Clear weather boosting safety';
    if (weatherFactor >= 0.85) return 'Mild weather impact';
    if (weatherFactor >= 0.75) return 'Light rain expected';
    return 'Heavy rain reducing visibility';
  }
}

