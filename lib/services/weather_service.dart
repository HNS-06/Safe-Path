import 'package:safepath/models/location_model.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final int visibility;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
  });
}

class WeatherService {
  WeatherService._();
  static final WeatherService _instance = WeatherService._();
  factory WeatherService() => _instance;

  Future<WeatherData?> getWeather(LocationModel location) async {
    // Simulate API call to OpenWeatherMap
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data based on temperature patterns
    final hour = DateTime.now().hour;
    final temp = 15 + (8 * (hour / 24)).toInt();

    return WeatherData(
      temperature: temp.toDouble(),
      condition: temp < 12 ? 'Rainy' : temp < 18 ? 'Cloudy' : 'Sunny',
      humidity: 60 + (temp % 20),
      windSpeed: 5 + (temp % 8),
      visibility: 2000 + (temp % 5000).toInt(),
    );
  }

  /// Get safety heat map data (crowd density, incidents, etc.)
  Future<Map<String, dynamic>> getSafetyHeatMap(
    LocationModel center,
    double radiusKm,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate heat map zones
    return {
      'zones': [
        {
          'lat': center.latitude,
          'lng': center.longitude,
          'intensity': 7,
          'type': 'crowd_density',
        },
        {
          'lat': center.latitude + 0.002,
          'lng': center.longitude + 0.002,
          'intensity': 3,
          'type': 'incident_history',
        },
        {
          'lat': center.latitude - 0.002,
          'lng': center.longitude - 0.002,
          'intensity': 2,
          'type': 'lighting_issue',
        },
      ],
    };
  }

  /// Sync weather and safety data (for offline cache)
  Future<void> syncDataForOffline(LocationModel location) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production: download tiles, cache weather for next 3 hours, etc.
  }
}
