import 'package:flutter/material.dart';
import 'package:safepath/services/places_service.dart';

class SafetyBadge extends StatelessWidget {
  final PlaceSafetyLevel safetyLevel;
  final double safetyScore;
  final bool showLabel;
  final bool showPercentage;
  final double size;

  const SafetyBadge({
    Key? key,
    required this.safetyLevel,
    required this.safetyScore,
    this.showLabel = true,
    this.showPercentage = true,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = PlacesService.getSafetyColor(safetyLevel);
    final icon = PlacesService.getSafetyIcon(safetyLevel);
    final label = PlacesService.getSafetyLabel(safetyLevel);
    final percentage = (safetyScore * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: size * 0.8, color: color),
          const SizedBox(width: 4),
          if (showLabel)
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          if (showPercentage) ...[
            const SizedBox(width: 4),
            Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
