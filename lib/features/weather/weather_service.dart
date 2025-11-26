import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safepath/models/location_model.dart';

class WeatherReport {
  final double temperature;
  final String condition;
  final double precipitationChance;

  WeatherReport({
    required this.temperature,
    required this.condition,
    required this.precipitationChance,
  });
}

class WeatherServiceFeature {
  WeatherServiceFeature._();
  static final WeatherServiceFeature _instance = WeatherServiceFeature._();
  factory WeatherServiceFeature() => _instance;

  // NOTE: In a real app store your API key securely. For demo we read from window.__OPENWEATHER_KEY
  String? _apiKey;

  void setApiKey(String key) => _apiKey = key;

  Future<WeatherReport?> fetchWeather(LocationModel loc) async {
    try {
      final key = _apiKey;
      if (key == null || key.isEmpty) return null;
      final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${loc.latitude}&lon=${loc.longitude}&units=metric&appid=$key');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      final js = json.decode(res.body) as Map<String, dynamic>;
      final temp = (js['main']?['temp'] as num?)?.toDouble() ?? 0.0;
      final condition = (js['weather'] as List<dynamic>?)?.first?['main'] ?? 'Unknown';
      final precipitation = ((js['rain']?['1h'] as num?)?.toDouble() ?? 0.0) + ((js['snow']?['1h'] as num?)?.toDouble() ?? 0.0);
      return WeatherReport(temperature: temp, condition: condition.toString(), precipitationChance: precipitation);
    } catch (e) {
      return null;
    }
  }
}
