import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/models/safety_report.dart';
import 'package:safepath/services/places_service.dart';
import 'dart:math';

class RouteSafetyAnalyzer {
  static const double _checkpointRadiusKm = 0.3; // Check safety every 300m

  /// Analyzes the safety of a route between two points
  /// Returns a RouteAnalysis object with overall safety and checkpoint details
  static RouteAnalysis analyzeRouteSafety(
    LatLng startPoint,
    LatLng endPoint,
    List<SafetyReport> allReports,
  ) {
    final distance = _calculateDistance(startPoint, endPoint);
    final checkpoints = _generateCheckpoints(startPoint, endPoint, distance);
    
    // Analyze safety at each checkpoint
    final checkpointAnalysis = <CheckpointAnalysis>[];
    for (final checkpoint in checkpoints) {
      final level = _analyzeSafetyAtPoint(checkpoint, allReports);
      checkpointAnalysis.add(level);
    }

    // Calculate overall route safety
    final (overallLevel, avgScore) = _calculateOverallSafety(checkpointAnalysis);
    
    // Identify risky zones
    final riskyZones = checkpointAnalysis
        .where((c) => c.safetyLevel == PlaceSafetyLevel.unsafe)
        .toList();

    // Identify moderate zones
    final moderateZones = checkpointAnalysis
        .where((c) => c.safetyLevel == PlaceSafetyLevel.moderate)
        .toList();

    return RouteAnalysis(
      overallSafetyLevel: overallLevel,
      averageSafetyScore: avgScore,
      totalDistance: distance,
      checkpoints: checkpointAnalysis,
      riskyZoneCount: riskyZones.length,
      moderateZoneCount: moderateZones.length,
      recommendation: _getRecommendation(overallLevel, riskyZones.length),
    );
  }

  /// Generates checkpoints along a route
  static List<LatLng> _generateCheckpoints(
    LatLng start,
    LatLng end,
    double distanceKm,
  ) {
    final checkpoints = [start];
    
    // Add checkpoints at regular intervals (every 500m)
    final intervalCount = (distanceKm / 0.5).ceil();
    for (int i = 1; i < intervalCount; i++) {
      final fraction = i / intervalCount;
      final lat = start.latitude + (end.latitude - start.latitude) * fraction;
      final lng = start.longitude + (end.longitude - start.longitude) * fraction;
      checkpoints.add(LatLng(lat, lng));
    }
    
    checkpoints.add(end);
    return checkpoints;
  }

  /// Analyzes safety at a specific point
  static CheckpointAnalysis _analyzeSafetyAtPoint(
    LatLng point,
    List<SafetyReport> allReports,
  ) {
    final nearbyReports = allReports.where((report) {
      final distance = _calculateDistance(point, report.location);
      return distance <= _checkpointRadiusKm;
    }).toList();

    if (nearbyReports.isEmpty) {
      return CheckpointAnalysis(
        location: point,
        safetyLevel: PlaceSafetyLevel.moderate,
        safetyScore: 0.5,
        nearbyReports: [],
        reportCount: 0,
      );
    }

    // Calculate weighted score
    double totalScore = 0;
    double totalWeight = 0;

    for (final report in nearbyReports) {
      final age = DateTime.now().difference(report.timestamp).inHours;
      final weight = age < 24 ? 1.0 : (age < 72 ? 0.7 : 0.3);
      totalScore += (report.rating / 5.0) * weight;
      totalWeight += weight;
    }

    final avgScore = totalWeight > 0 ? totalScore / totalWeight : 0.5;
    
    PlaceSafetyLevel level;
    if (avgScore >= 0.7) {
      level = PlaceSafetyLevel.safe;
    } else if (avgScore >= 0.4) {
      level = PlaceSafetyLevel.moderate;
    } else {
      level = PlaceSafetyLevel.unsafe;
    }

    return CheckpointAnalysis(
      location: point,
      safetyLevel: level,
      safetyScore: avgScore,
      nearbyReports: nearbyReports.take(3).toList(),
      reportCount: nearbyReports.length,
    );
  }

  /// Calculates overall route safety
  static (PlaceSafetyLevel, double) _calculateOverallSafety(
    List<CheckpointAnalysis> checkpoints,
  ) {
    if (checkpoints.isEmpty) {
      return (PlaceSafetyLevel.moderate, 0.5);
    }

    // Weight by severity - unsafe zones drag down the score
    double totalScore = 0;
    for (final checkpoint in checkpoints) {
      totalScore += checkpoint.safetyScore;
    }
    final avgScore = totalScore / checkpoints.length;

    // Count risky zones
    final unsafeCount = checkpoints.where((c) => c.safetyLevel == PlaceSafetyLevel.unsafe).length;
    final totalCheckpoints = checkpoints.length;
    final unsafePercentage = (unsafeCount / totalCheckpoints) * 100;

    // If more than 20% of route is unsafe, mark entire route as unsafe
    if (unsafePercentage > 20) {
      return (PlaceSafetyLevel.unsafe, avgScore.clamp(0.0, 1.0));
    }

    // If more than 40% is moderate or unsafe, mark as moderate
    final moderateAndUnsafeCount = checkpoints
        .where((c) => c.safetyLevel != PlaceSafetyLevel.safe)
        .length;
    if ((moderateAndUnsafeCount / totalCheckpoints) * 100 > 40) {
      return (PlaceSafetyLevel.moderate, avgScore.clamp(0.0, 1.0));
    }

    if (avgScore >= 0.7) {
      return (PlaceSafetyLevel.safe, avgScore.clamp(0.0, 1.0));
    } else if (avgScore >= 0.4) {
      return (PlaceSafetyLevel.moderate, avgScore.clamp(0.0, 1.0));
    } else {
      return (PlaceSafetyLevel.unsafe, avgScore.clamp(0.0, 1.0));
    }
  }

  /// Gets a recommendation based on route safety
  static String _getRecommendation(PlaceSafetyLevel level, int riskyZones) {
    switch (level) {
      case PlaceSafetyLevel.safe:
        return 'This route appears safe. Proceed normally.';
      case PlaceSafetyLevel.moderate:
        return 'This route has moderate risk. Stay alert and avoid solo travel.';
      case PlaceSafetyLevel.unsafe:
        return 'This route has unsafe zones ($riskyZones risky area${riskyZones > 1 ? 's' : ''}). Consider alternative routes or travel with companions.';
    }
  }

  /// Calculate distance between two LatLng points in kilometers (Haversine formula)
  static double _calculateDistance(LatLng point1, LatLng point2) {
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLng = _degreesToRadians(point2.longitude - point1.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;
}

class RouteAnalysis {
  final PlaceSafetyLevel overallSafetyLevel;
  final double averageSafetyScore;
  final double totalDistance;
  final List<CheckpointAnalysis> checkpoints;
  final int riskyZoneCount;
  final int moderateZoneCount;
  final String recommendation;

  RouteAnalysis({
    required this.overallSafetyLevel,
    required this.averageSafetyScore,
    required this.totalDistance,
    required this.checkpoints,
    required this.riskyZoneCount,
    required this.moderateZoneCount,
    required this.recommendation,
  });
}

class CheckpointAnalysis {
  final LatLng location;
  final PlaceSafetyLevel safetyLevel;
  final double safetyScore;
  final List<SafetyReport> nearbyReports;
  final int reportCount;

  CheckpointAnalysis({
    required this.location,
    required this.safetyLevel,
    required this.safetyScore,
    required this.nearbyReports,
    required this.reportCount,
  });
}
