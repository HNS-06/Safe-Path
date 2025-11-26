import 'dart:math';
import 'package:safepath/models/location_model.dart';

class RoutingService {
  RoutingService._();
  static final RoutingService _instance = RoutingService._();
  factory RoutingService() => _instance;

  /// Simple A* or greedy routing stub for offline mode
  /// In production, integrate with real routing engine (OSRM, etc.)
  Future<List<LocationModel>> calculateRoute(
    LocationModel start,
    LocationModel end, {
    bool avoidDangerous = true,
  }) async {
    // Simulate route calculation
    await Future.delayed(const Duration(milliseconds: 500));
    
    final steps = 20;
    final route = <LocationModel>[];
    final now = DateTime.now();
    
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng = start.longitude + (end.longitude - start.longitude) * t;
      route.add(LocationModel(
        latitude: lat,
        longitude: lng,
        timestamp: now.add(Duration(seconds: i * 10)),
      ));
    }
    
    return route;
  }

  /// Calculate straight-line distance (km) for the route and estimate traffic.
  double distanceKm(LocationModel a, LocationModel b) {
    const R = 6371e3; // metres
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;

    final hav = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(hav), sqrt(1 - hav));
    final meters = R * c;
    return meters / 1000.0;
  }

  /// Very simple traffic estimator: returns factor (1.0 = light, >1 slow)
  double estimateTrafficFactor(LocationModel start, LocationModel end) {
    // Mock traffic: heavier during rush hours (7-9am, 5-7pm) based on local time
    final now = DateTime.now();
    final hour = now.hour;
    if (hour >= 7 && hour <= 9) return 1.4;
    if (hour >= 17 && hour <= 19) return 1.5;
    // otherwise, light traffic
    return 1.0 + (Random().nextDouble() * 0.2);
  }

  /// Get alternate safe routes (mock implementation)
  Future<List<List<LocationModel>>> getAlternateSafeRoutes(
    LocationModel start,
    LocationModel end,
  ) async {
    final mainRoute = await calculateRoute(start, end);
    final now = DateTime.now();
    
    // Simulate 2 alternate routes by slightly offsetting
    final alt1 = mainRoute
        .map((loc) => LocationModel(
              latitude: loc.latitude + 0.0005,
              longitude: loc.longitude + 0.0005,
              timestamp: now,
            ))
        .toList();
    final alt2 = mainRoute
        .map((loc) => LocationModel(
              latitude: loc.latitude - 0.0005,
              longitude: loc.longitude - 0.0005,
              timestamp: now,
            ))
        .toList();
    
    return [mainRoute, alt1, alt2];
  }

  /// Cache tiles for offline use (stub)
  Future<void> cacheMapTiles(
    LocationModel center,
    double radiusKm,
  ) async {
    // In production: fetch and cache tiles from Google Maps or OSM
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Check if offline mode is available
  Future<bool> isOfflineModeAvailable() async {
    // Check if cached tiles exist
    return true; // Simplified
  }
}
