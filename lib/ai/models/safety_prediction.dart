import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents an AI predicted safety snapshot for a given area.
class SafetyPrediction extends Equatable {
  const SafetyPrediction({
    required this.areaName,
    required this.predictedScore,
    required this.timeRange,
    required this.weatherImpact,
    required this.confidence,
    required this.riskFactors,
    required this.recommendations,
    required this.accentColor,
  });

  /// Name of the predicted area/segment (e.g., street or block).
  final String areaName;

  /// Predicted safety score between 0-1 (converted to 0-100 in UI).
  final double predictedScore;

  /// Time range for which this prediction is applicable.
  final String timeRange;

  /// Weather impact summary describing how weather modifies safety.
  final String weatherImpact;

  /// ML model confidence between 0-1.
  final double confidence;

  /// Top risk factors identified by the model.
  final List<String> riskFactors;

  /// Actionable recommendations for the user.
  final List<String> recommendations;

  /// Accent color used to visually differentiate the card.
  final Color accentColor;

  /// Converts the normalized predicted score into a 0-100 scale.
  int get scorePercent => (predictedScore.clamp(0, 1) * 100).round();

  /// Returns a short descriptor that the UI can show.
  String get safetyLabel {
    if (predictedScore >= 0.75) return 'Very Safe';
    if (predictedScore >= 0.6) return 'Safe';
    if (predictedScore >= 0.45) return 'Caution';
    if (predictedScore >= 0.3) return 'Alert';
    return 'Critical';
  }

  @override
  List<Object?> get props => [
        areaName,
        predictedScore,
        timeRange,
        weatherImpact,
        confidence,
        riskFactors,
        recommendations,
        accentColor,
      ];
}

