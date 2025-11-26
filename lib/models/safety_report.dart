import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SafetyType { safe, moderate, unsafe, unknown }

class SafetyReport {
  final String id;
  final LatLng location;
  final SafetyType type;
  final String description;
  final double rating;
  final DateTime timestamp;
  final String? userId;
  final List<String>? images;

  SafetyReport({
    required this.id,
    required this.location,
    required this.type,
    required this.description,
    required this.rating,
    required this.timestamp,
    this.userId,
    this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'type': type.toString(),
      'description': description,
      'rating': rating,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'images': images,
    };
  }

  factory SafetyReport.fromJson(Map<String, dynamic> json) {
    return SafetyReport(
      id: json['id'],
      location: LatLng(json['latitude'], json['longitude']),
      type: SafetyType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SafetyType.unknown,
      ),
      description: json['description'],
      rating: (json['rating'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}