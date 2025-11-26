import 'dart:math';
import 'package:safepath/models/ai_prediction_model.dart';

class AISafetyPredictor {
  // Mock AI model - in real app, this would call a TensorFlow Lite model or API
  Future<SafetyPrediction> predictSafety(
    double lat, 
    double lng, 
    DateTime time,
  ) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock prediction based on various factors
    final random = Random((lat + lng + time.millisecondsSinceEpoch).toInt());
    
    // Base safety score (0-5)
    double baseScore = 3.0 + random.nextDouble() * 2.0;
    
    // Time-based adjustments
    if (time.hour >= 18 || time.hour <= 6) {
      baseScore -= 1.5; // Night time penalty
    }
    
    // Weather factor (mock)
    double weatherImpact = random.nextDouble() * 0.8 - 0.4;
    baseScore += weatherImpact;
    
    // Historical data factor
    double historicalImpact = random.nextDouble() * 1.0 - 0.3;
    baseScore += historicalImpact;
    
    // Ensure score is within bounds
    baseScore = baseScore.clamp(1.0, 5.0);
    
    // Generate confidence score
    double confidence = 0.7 + random.nextDouble() * 0.25;
    
    // Generate factors breakdown
    final factors = SafetyFactors(
      timeOfDay: _getTimeFactor(time.hour),
      lighting: random.nextDouble() * 0.8 + 0.2,
      crowdDensity: random.nextDouble() * 0.9 + 0.1,
      historicalIncidents: random.nextDouble() * 0.6,
      accessibility: random.nextDouble() * 0.7 + 0.3,
    );
    
    // Generate recommendations
    final recommendations = _generateRecommendations(baseScore, factors, time);
    
    return SafetyPrediction(
      score: baseScore,
      confidence: confidence,
      factors: factors,
      recommendations: recommendations,
      predictedAt: DateTime.now(),
      location: PredictionLocation(lat: lat, lng: lng),
    );
  }
  
  double _getTimeFactor(int hour) {
    if (hour >= 6 && hour <= 18) return 0.8; // Daytime
    if (hour >= 19 && hour <= 21) return 0.5; // Evening
    return 0.2; // Night
  }
  
  List<String> _generateRecommendations(double score, SafetyFactors factors, DateTime time) {
    final recommendations = <String>[];
    
    if (score < 2.5) {
      recommendations.addAll([
        'Avoid this area after dark',
        'Travel in groups if possible',
        'Stay in well-lit areas',
      ]);
    } else if (score < 4.0) {
      recommendations.addAll([
        'Exercise normal caution',
        'Keep valuables secured',
        'Be aware of surroundings',
      ]);
    } else {
      recommendations.addAll([
        'Generally safe area',
        'Good for solo travel',
        'Well-maintained paths',
      ]);
    }
    
    if (factors.lighting < 0.4) {
      recommendations.add('Carry a flashlight');
    }
    
    if (factors.crowdDensity < 0.3) {
      recommendations.add('Low foot traffic - stay alert');
    }
    
    return recommendations;
  }
  
  // Batch prediction for route planning
  Future<List<SafetyPrediction>> predictRouteSafety(List<PredictionLocation> route) async {
    final predictions = <SafetyPrediction>[];
    for (final location in route) {
      final prediction = await predictSafety(
        location.lat, 
        location.lng, 
        DateTime.now(),
      );
      predictions.add(prediction);
    }
    return predictions;
  }
}