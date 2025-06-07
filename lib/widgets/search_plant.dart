import 'package:flutter/material.dart';
import 'package:tanamin/core/service/plant_service.dart';
import 'package:tanamin/data/models/plant_model.dart';
import 'package:tanamin/widgets/converted_price_text.dart';

class SearchPlant extends StatefulWidget {
  const SearchPlant({super.key});

  @override
  State<SearchPlant> createState() => _SearchPlantState();
}

class _SearchPlantState extends State<SearchPlant> {
  List<Plant> searchResults = [];
  String searchQuery = '';

  Future<List<Plant>> fetchSearchResults(String search) async {
    final rawList = await PlantService.getAllPlant('?name=$search');
    return rawList.map((e) => Plant.fromJson(e)).toList();
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search Plants...',
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.black,
              width: 2,
            ),
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.black),
        ),
        style: const TextStyle(color: Colors.black),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
          if (value.isNotEmpty) {
            fetchSearchResults(value).then((results) {
              setState(() {
                searchResults = results;
              });
            });
          } else {
            setState(() {
              searchResults = [];
            });
          }
        },
      ),
    );
  }

  Widget _buildPlantList() {
    return FutureBuilder<List<Plant>>(
      future: fetchSearchResults(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          if (snapshot.error.toString() ==
              'Exception: Error fetching data: 404') {
            return const Center(child: Text('Tidak ada tanaman ditemukan'));
          } else {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Tanaman'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildPlantList()),
          ],
        ),
      ),
    );
  }
}
