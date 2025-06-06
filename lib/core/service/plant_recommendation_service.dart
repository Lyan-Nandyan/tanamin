import 'package:flutter/material.dart';
import 'package:tanamin/data/models/plant_model.dart';
import 'plant_service.dart';

class PlantRecommendationService {
  Future<List<Plant>> getRecommendedPlants(double currentTemp, int currentHumidity) async {
    debugPrint('Suhu saat ini: $currentTemp °C, Kelembapan: $currentHumidity%');

    // Optional: Tentukan musim berdasarkan bulan (manual logic)
    // final String currentSeason = _determineSeason();

    // Step 1: Get all plants from API
    List<Plant> allPlants = await _fetchPlants();

    // Step 2: Filter berdasarkan kondisi
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
