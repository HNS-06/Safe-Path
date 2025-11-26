import 'package:safepath/features/weather/weather_service.dart';

class WeatherSafetyIntegration {
  /// Returns a short safety suggestion based on weather report.
  static String suggestionFromReport(WeatherReport? report) {
    if (report == null) return 'No weather data available.';

    final cond = report.condition.toLowerCase();
    final precip = report.precipitationChance;
    final temp = report.temperature;

    if (precip > 0.5) {
      return 'Rain expected - suggesting covered route.';
    }

    if (cond.contains('rain') || cond.contains('storm')) {
      return 'Rain expected - suggesting covered route.';
    }

    if (cond.contains('fog') || cond.contains('mist')) {
      return 'Low visibility alert - stay in well-lit areas.';
    }

    if (temp < 5) {
      return 'Cold conditions - consider warmer clothing and lit routes.';
    }

    return 'Weather looks clear for travel.';
  }
}
