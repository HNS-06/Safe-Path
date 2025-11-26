import 'package:flutter/material.dart';
import 'package:safepath/models/ai_prediction_model.dart';
import 'package:safepath/widgets/safety_score_indicator.dart';

class SafetyPredictionCard extends StatelessWidget {
  final SafetyPrediction prediction;

  const SafetyPredictionCard({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with score and confidence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SafetyScoreIndicator(score: prediction.score, size: 70),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(
                      label: Text(
                        prediction.safetyLevel,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: prediction.safetyColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(prediction.confidence * 100).toStringAsFixed(0)}% confident',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Safety Factors
            _buildSafetyFactors(),
            const SizedBox(height: 20),
            
            // Recommendations
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyFactors() {
    final factors = prediction.factors.toMap();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Factors',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...factors.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: Colors.grey[200],
                    color: _getFactorColor(entry.value),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(entry.value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...prediction.recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[400],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getFactorColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }
}