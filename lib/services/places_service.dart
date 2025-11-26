import 'dart:math';
import 'package:geolocator/geolocator.dart';
// no local model required

class PlaceItem {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  PlaceItem({required this.id, required this.name, required this.latitude, required this.longitude});
}

class PlacesService {
  PlacesService._();
  static final PlacesService _instance = PlacesService._();
  factory PlacesService() => _instance;

  /// Returns a list of nearby mock places around the provided position.
  Future<List<PlaceItem>> getNearbyPlaces(Position pos, {int count = 6}) async {
    // Generate deterministic nearby points using small offsets
    final rng = Random(pos.latitude.hashCode ^ pos.longitude.hashCode);
    final places = <PlaceItem>[];
    final names = ['Cafe', 'ATM', 'Bus Stop', 'Library', 'Shop', 'Park', 'Mall', 'Restaurant'];
    for (int i = 0; i < count; i++) {
      final dLat = (rng.nextDouble() - 0.5) / 1000; // ~0.001 deg ~100m
      final dLng = (rng.nextDouble() - 0.5) / 1000;
      places.add(PlaceItem(
        id: 'p_${i}_${pos.latitude.toStringAsFixed(4)}',
        name: '${names[i % names.length]} ${i + 1}',
        latitude: pos.latitude + dLat,
        longitude: pos.longitude + dLng,
      ));
    }
    return places;
  }
}
