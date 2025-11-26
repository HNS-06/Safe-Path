import 'package:flutter/material.dart';
import 'package:safepath/theme/colors.dart';

class SafetyScoreIndicator extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;

  const SafetyScoreIndicator({
    super.key,
    required this.score,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _getScoreColor(score);
    final String label = _getScoreLabel(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.0) return AppColors.safe;
    if (score >= 2.5) return AppColors.moderate;
    return AppColors.unsafe;
  }

  String _getScoreLabel(double score) {
    if (score >= 4.0) return 'Very Safe';
    if (score >= 3.0) return 'Safe';
    if (score >= 2.5) return 'Moderate';
    if (score >= 2.0) return 'Caution';
    return 'Unsafe';
  }
}