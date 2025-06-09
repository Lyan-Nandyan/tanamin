import 'package:flutter/foundation.dart';
import '../../../core/service/location_service.dart';
import '../../../core/service/weather_service.dart';

class LocationWeatherController {
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  String location = 'Menunggu lokasi...';
  String weather = 'Menunggu cuaca...';

  double? currentTemp;
  int? currentHumidity;

  Future<void> fetchData() async {
    try {
      final position = await _locationService.getCurrentLocation();
      location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';

      final weatherData = await _weatherService.getWeather(
          position.latitude, position.longitude);
      weather = 'Suhu: ${weatherData.temperature}°C, '
          'Kelembapan: ${weatherData.humidity}%, '
          'Tekanan: ${weatherData.pressure} hPa, '
          'Cuaca: ${weatherData.condition}';

      currentTemp = weatherData.temperature;
      currentHumidity = weatherData.humidity;
    } catch (e) {
      location = 'Error: $e';
      weather = 'Error: $e';
    }
  }

  Future<void> init(VoidCallback onUpdated) async {
    await fetchData();
    onUpdated();
  }
}
