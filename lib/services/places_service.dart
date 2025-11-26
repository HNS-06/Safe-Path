import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safepath/models/safety_report.dart';

enum PlaceSafetyLevel { safe, moderate, unsafe }

class PlaceItem {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final PlaceSafetyLevel safetyLevel;
  final double safetyScore; // 0.0 to 1.0
  final int reportCount;
  final List<SafetyReport> recentReports;

  PlaceItem({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.safetyLevel = PlaceSafetyLevel.moderate,
    this.safetyScore = 0.5,
    this.reportCount = 0,
    this.recentReports = const [],
  });
}

class PlacesService {
  PlacesService._();
  static final PlacesService _instance = PlacesService._();
  factory PlacesService() => _instance;

  /// Mock safety reports database - in real app would be fetched from backend
  final List<SafetyReport> _allSafetyReports = [
    SafetyReport(
      id: 'sr_1',
      location: const LatLng(28.6149, 77.2190),
      type: SafetyType.safe,
      description: 'Well lit area with good foot traffic',
      rating: 4.5,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SafetyReport(
      id: 'sr_2',
      location: const LatLng(28.6139, 77.2100),
      type: SafetyType.moderate,
      description: 'Moderate crowd during evenings',
      rating: 3.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    SafetyReport(
      id: 'sr_3',
      location: const LatLng(28.6159, 77.2180),
      type: SafetyType.unsafe,
      description: 'Reported incidents in this area',
      rating: 2.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    SafetyReport(
      id: 'sr_4',
      location: const LatLng(28.6140, 77.2095),
      type: SafetyType.safe,
      description: 'Police patrol visible',
      rating: 4.8,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  /// Returns a list of nearby mock places with safety analysis
  Future<List<PlaceItem>> getNearbyPlaces(Position pos, {int count = 6}) async {
    final rng = Random(pos.latitude.hashCode ^ pos.longitude.hashCode);
    final places = <PlaceItem>[];
    final names = ['Cafe', 'ATM', 'Bus Stop', 'Library', 'Shop', 'Park'];
    
    for (int i = 0; i < count; i++) {
      final dLat = (rng.nextDouble() - 0.5) / 1000; // ~0.001 deg ~100m
      final dLng = (rng.nextDouble() - 0.5) / 1000;
      final placeLat = pos.latitude + dLat;
      final placeLng = pos.longitude + dLng;
      final placeLocation = LatLng(placeLat, placeLng);

      // Analyze safety for this place location
      final (safetyLevel, safetyScore, reportCount, recentReports) = 
          _analyzeSafetyForLocation(placeLocation);

      places.add(PlaceItem(
        id: 'p_${i}_${pos.latitude.toStringAsFixed(4)}',
        name: '${names[i % names.length]} ${i + 1}',
        latitude: placeLat,
        longitude: placeLng,
        safetyLevel: safetyLevel,
        safetyScore: safetyScore,
        reportCount: reportCount,
        recentReports: recentReports,
      ));
    }
    return places;
  }

  /// Analyzes safety level for a given location based on nearby reports
  (PlaceSafetyLevel, double, int, List<SafetyReport>) _analyzeSafetyForLocation(LatLng location) {
    const radiusKm = 0.5; // 500 meters
    
    // Find all reports within radius
    final nearbyReports = _allSafetyReports.where((report) {
      final distance = _calculateDistance(location, report.location);
      return distance <= radiusKm;
    }).toList();

    if (nearbyReports.isEmpty) {
      // No reports found - default to moderate safety
      return (PlaceSafetyLevel.moderate, 0.5, 0, []);
    }

    // Sort by recent first
    nearbyReports.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Calculate weighted safety score (recent reports weighted more)
    double totalScore = 0;
    double totalWeight = 0;

    for (final report in nearbyReports) {
      final age = DateTime.now().difference(report.timestamp).inHours;
      final weight = age < 24 ? 1.0 : (age < 72 ? 0.7 : 0.3);
      totalScore += (report.rating / 5.0) * weight; // normalize rating to 0-1
      totalWeight += weight;
    }

    final avgScore = totalWeight > 0 ? totalScore / totalWeight : 0.5;
    
    // Determine safety level based on score
    PlaceSafetyLevel level;
    if (avgScore >= 0.7) {
      level = PlaceSafetyLevel.safe;
    } else if (avgScore >= 0.4) {
      level = PlaceSafetyLevel.moderate;
    } else {
      level = PlaceSafetyLevel.unsafe;
    }

    return (level, avgScore, nearbyReports.length, nearbyReports.take(3).toList());
  }

  /// Calculate distance between two LatLng points in kilometers (Haversine formula)
  double _calculateDistance(LatLng point1, LatLng point2) {
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

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  /// Get safety color for a given safety level
  static Color getSafetyColor(PlaceSafetyLevel level) {
    switch (level) {
      case PlaceSafetyLevel.safe:
        return const Color(0xFF4CAF50); // Green
      case PlaceSafetyLevel.moderate:
        return const Color(0xFFFFC107); // Amber
      case PlaceSafetyLevel.unsafe:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Get safety label
  static String getSafetyLabel(PlaceSafetyLevel level) {
    switch (level) {
      case PlaceSafetyLevel.safe:
        return 'Safe';
      case PlaceSafetyLevel.moderate:
        return 'Moderate';
      case PlaceSafetyLevel.unsafe:
        return 'Unsafe';
    }
  }

  /// Get safety icon
  static IconData getSafetyIcon(PlaceSafetyLevel level) {
    switch (level) {
      case PlaceSafetyLevel.safe:
        return Icons.check_circle;
      case PlaceSafetyLevel.moderate:
        return Icons.info;
      case PlaceSafetyLevel.unsafe:
        return Icons.warning;
    }
  }
}
