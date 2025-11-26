import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Attempts to get the current high-accuracy position. If the attempt
  /// times out, the method will return the last known position if available.
  static Future<Position> getCurrentLocation({Duration timeout = const Duration(seconds: 15)}) async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: timeout,
      );
      return pos;
    } on TimeoutException catch (_) {
      // Fallback to last known position when the live fix times out
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw Exception('Timeout while acquiring location.');
    }
  }

  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters - more frequent updates
      ),
    );
  }

  static Future<Position?> getLastKnownPosition() async {
    return await Geolocator.getLastKnownPosition();
  }
}