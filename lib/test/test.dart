import 'package:flutter/material.dart';
import 'package:tanamin/core/service/location_service.dart';
import 'package:tanamin/core/service/weather_service.dart';

class TestLocationWeatherPage extends StatefulWidget {
  @override
  _TestLocationWeatherPageState createState() =>
      _TestLocationWeatherPageState();
}

class _TestLocationWeatherPageState extends State<TestLocationWeatherPage> {
  String _location = 'Menunggu lokasi...';
  String _weather = 'Menunggu cuaca...';

  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  Future<void> _fetchData() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });

      final weatherData = await _weatherService.getWeather(
          position.latitude, position.longitude);
      setState(() {
        _weather = 'Suhu: ${weatherData.temperature}°C, '
            'Kelembapan: ${weatherData.humidity}%, '
            'Tekanan: ${weatherData.pressure} hPa, '
            'Cuaca: ${weatherData.condition}';
      });
    } catch (e) {
      setState(() {
        _location = 'Error: $e';
        _weather = 'Error: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Lokasi dan Cuaca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_location),
            SizedBox(height: 20),
            Text(_weather),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _fetchData,
              child: Text('Refresh Data'),
            ),
          ],
        ),
      ),
    );
  }
}
