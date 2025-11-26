import 'package:flutter/material.dart';

class SafetyPrediction {
  final double score; // 1-5 scale
  final double confidence; // 0-1 scale
  final SafetyFactors factors;
  final List<String> recommendations;
  final DateTime predictedAt;
  final PredictionLocation location;

  SafetyPrediction({
    required this.score,
    required this.confidence,
    required this.factors,
    required this.recommendations,
    required this.predictedAt,
    required this.location,
  });

  String get safetyLevel {
    if (score >= 4.0) return 'Very Safe';
    if (score >= 3.0) return 'Safe';
    if (score >= 2.0) return 'Moderate';
    return 'Unsafe';
  }

  Color get safetyColor {
    if (score >= 4.0) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }
}

class SafetyFactors {
  final double timeOfDay; // 0-1 scale
  final double lighting; // 0-1 scale
  final double crowdDensity; // 0-1 scale
  final double historicalIncidents; // 0-1 scale
  final double accessibility; // 0-1 scale

  SafetyFactors({
    required this.timeOfDay,
    required this.lighting,
    required this.crowdDensity,
    required this.historicalIncidents,
    required this.accessibility,
  });

  Map<String, double> toMap() {
    return {
      'Time of Day': timeOfDay,
      'Lighting': lighting,
      'Crowd Density': crowdDensity,
      'Historical Incidents': historicalIncidents,
      'Accessibility': accessibility,
    };
  }
}

class PredictionLocation {
  final double lat;
  final double lng;

  PredictionLocation({required this.lat, required this.lng});
}