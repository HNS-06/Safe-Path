import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  static const double defaultZoom = 14.0;

  static CameraPosition getCameraPosition(LatLng location, {double zoom = defaultZoom}) {
    return CameraPosition(
      target: location,
      zoom: zoom,
    );
  }

  static LatLngBounds getBoundsFromPoints(List<LatLng> points) {
    double? west, north, east, south;
    
    for (LatLng point in points) {
      west = west != null ? (point.longitude < west ? point.longitude : west) : point.longitude;
      north = north != null ? (point.latitude > north ? point.latitude : north) : point.latitude;
      east = east != null ? (point.longitude > east ? point.longitude : east) : point.longitude;
      south = south != null ? (point.latitude < south ? point.latitude : south) : point.latitude;
    }
    
    return LatLngBounds(
      southwest: LatLng(south ?? 0, west ?? 0),
      northeast: LatLng(north ?? 0, east ?? 0),
    );
  }

  static double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // kilometers
    
    double dLat = _toRadians(end.latitude - start.latitude);
    double dLon = _toRadians(end.longitude - start.longitude);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(start.latitude)) *
            cos(_toRadians(end.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}