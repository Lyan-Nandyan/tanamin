import 'package:flutter/material.dart';
import 'package:tanamin/core/service/location_service.dart';
import 'package:tanamin/core/service/plant_recommendation_service.dart';
import 'package:tanamin/core/service/plant_service.dart';
import 'package:tanamin/core/service/weather_service.dart';
import 'package:tanamin/data/models/plant_model.dart';
import 'package:tanamin/widgets/converted_price_text.dart';

class TestLocationWeatherPage extends StatefulWidget {
  const TestLocationWeatherPage({super.key});

  @override
  _TestLocationWeatherPageState createState() =>
      _TestLocationWeatherPageState();
}

class _TestLocationWeatherPageState extends State<TestLocationWeatherPage> {
  String _location = 'Menunggu lokasi...';
  String _weather = 'Menunggu cuaca...';
  String? lat;
  String? lon;
  double? currentTemp;
  int? currentHumidity;
  double? currentPressure;
  String? currentCondition;

  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();

  Future<void> _fetchData() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _location = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
        lat = position.latitude.toString();
        lon = position.longitude.toString();
      });

      final weatherData = await _weatherService.getWeather(
          position.latitude, position.longitude);
      setState(() {
        _weather = 'Suhu: ${weatherData.temperature}°C, '
            'Kelembapan: ${weatherData.humidity}%, '
            'Tekanan: ${weatherData.pressure} hPa, '
            'Cuaca: ${weatherData.condition}';
        currentTemp = weatherData.temperature;
        currentHumidity = weatherData.humidity;
        currentPressure = weatherData.pressure;
        currentCondition = weatherData.condition;
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

  Future<void> testRecommendation() async {
    debugPrint(
        'Memulai rekomendasi tanaman... pada suhu $currentTemp dan kelembapan $currentHumidity');
    final recommendations = await PlantRecommendationService()
        .getRecommendedPlants(currentTemp!, currentHumidity!);
    debugPrint(
        'Rekomendasi tanaman berdasarkan suhu ${currentTemp!}°C dan kelembapan ${currentHumidity!}%:');
    for (var plant in recommendations) {
      debugPrint('Direkomendasikan: ${plant.name}');
    }
  }

  Widget _buildPlantList() {
    return FutureBuilder<List<Plant>>(
      future: _fetchPlants(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada tanaman ditemukan'));
        }

        final plants = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Anda memilih ${plant.name} dengan ID ${plant.id}'),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        plant.imageUrl,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 80),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            plant.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: plant.suitableSeasons.map((season) {
                              return Chip(
                                label: Text(season),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                          Text('Suhu: ${plant.minTemp}°C – ${plant.maxTemp}°C',
                              style: const TextStyle(fontSize: 12)),
                          Text(
                              'Kelembapan: ${plant.minHumidity}% – ${plant.maxHumidity}%',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          ConvertedPriceText(
                              amount: plant.estimatedCost, currencyOption: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _initAsync() async {
    await _fetchData(); // Menunggu _fetchData selesai
    await testRecommendation(); // Baru menjalankan rekomendasi
  }

  @override
  void initState() {
    super.initState();
    _initAsync(); // Memanggil fungsi async di initState
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
