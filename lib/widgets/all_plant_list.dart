import 'package:flutter/material.dart';
import '../../../core/service/plant_service.dart';
import '../../../data/models/plant_model.dart';
import '../../../widgets/converted_price_text.dart';

class AllPlantList extends StatelessWidget {
  final int? option;
  const AllPlantList({super.key, this.option});

  Future<List<Plant>> _fetchPlants() async {
    final plants = await PlantService.getAllPlant('');
    return plants.map((json) => Plant.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                      errorBuilder: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(plant.description,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: plant.suitableSeasons
                              .map((season) => Chip(
                                  label: Text(season),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: Colors.green.shade50,
                                  labelStyle: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  )))
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                        Text('Suhu: ${plant.minTemp}°C – ${plant.maxTemp}°C'),
                        Text(
                            'Kelembapan: ${plant.minHumidity}% – ${plant.maxHumidity}%'),
                        const SizedBox(height: 6),
                        ConvertedPriceText(
                            amount: plant.estimatedCost,
                            currencyOption: option ?? 1),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
