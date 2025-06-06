import 'package:flutter/material.dart';
import 'package:tanamin/data/models/plant_model.dart';
import 'plant_service.dart';
import 'weather_service.dart';
import 'location_service.dart';

class PlantRecommendationService {
  Future<List<Plant>> getRecommendedPlants() async {
    // Step 1: Get user location
    final position = await LocationService().getCurrentLocation();
    final lat = position.latitude;
    final lon = position.longitude;

    // Step 2: Get weather data from API
    final weather = await WeatherService().getWeather(lat, lon);

    final double currentTemp = weather.temperature;
    final int currentHumidity = weather.humidity;
    debugPrint('Suhu saat ini: $currentTemp °C, Kelembapan: $currentHumidity%');

    // Optional: Tentukan musim berdasarkan bulan (manual logic)
    // final String currentSeason = _determineSeason();

    // Step 3: Get all plants from API
    List<Plant> allPlants = await _fetchPlants();

    // Step 4: Filter berdasarkan kondisi
    final recommendedPlants = allPlants.where((plant) {
      return currentTemp >= plant.minTemp &&
          currentTemp <= plant.maxTemp &&
          currentHumidity >= plant.minHumidity &&
          currentHumidity <= plant.maxHumidity;
      // plant.suitableSeasons.contains(currentSeason);
    }).toList();

    return recommendedPlants;
  }

  Future<List<Plant>> _fetchPlants() async {
    try {
      final plants = await PlantService.getAllPlant('');
      return plants.map((json) => Plant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data tanaman: $e');
    }
  }

  // String _determineSeason() {
  //   final month = DateTime.now().month;
  //   if ([11, 12, 1, 2, 3].contains(month)) {
  //     return 'musim hujan';
  //   } else {
  //     return 'musim kemarau';
  //   }
  // }
}
