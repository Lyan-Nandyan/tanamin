import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int humidity;
  final double pressure;
  final String condition;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.condition,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: (json['main']['pressure'] as num).toDouble(),
      condition: json['weather'][0]['description'] as String,
    );
  }
}

class WeatherService {
  final String? apiKey = dotenv.env['API_KEY'];

  Future<WeatherData> getWeather(double lat, double lon) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengambil data cuaca: ${response.statusCode}');
    }
  }
}
