class LocationModel {
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address = '',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}