import 'package:flutter/material.dart';
import 'package:tanamin/core/service/location_service.dart';
import 'package:tanamin/core/service/plant_service.dart';
import 'package:tanamin/core/service/weather_service.dart';
import 'package:tanamin/data/models/plant_model.dart';

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

  Future<List<Plant>> _fetchPlants() async {
    try {
      final plants = await PlantService.getAllPlant('');
      return plants.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data tanaman: $e');
    }
  }

  Widget _buildPlantList() {
    return FutureBuilder<List<Plant>>(
      future: _fetchPlants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('Tidak ada tanaman ditemukan');
        } else {
          final plants = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return Ink(
                child: ListTile(
                  title: Text(plant.name),
                  subtitle: Text(plant.description),
                  leading: SizedBox(
                    width: 60, // lebar tetap
                    height: 60, // tinggi tetap
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          8), // opsional, agar sudut membulat
                      child: Image.network(
                        plant.imageUrl,
                        fit: BoxFit.cover, // isi penuh area tanpa merusak rasio
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  trailing: Text(
                    'IDR ${plant.estimatedCost.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    // Aksi ketika item ditekan, misalnya navigasi ke detail tanaman
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Anda memilih ${plant.name} dengan ID ${plant.id}')),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
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
            SizedBox(height: 20),
            Text('Daftar Tanaman:'),
            SizedBox(height: 10),
            Expanded(
              child: _buildPlantList(),
            ),
          ],
        ),
      ),
    );
  }
}
