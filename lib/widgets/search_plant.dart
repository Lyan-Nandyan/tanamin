import 'package:flutter/material.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/plant_service.dart';
import 'package:tanamin/data/models/plant_model.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/widgets/converted_price_text.dart';

class SearchPlant extends StatefulWidget {
  const SearchPlant({super.key});

  @override
  State<SearchPlant> createState() => _SearchPlantState();
}

class _SearchPlantState extends State<SearchPlant> {
  List<Plant> searchResults = [];
  String searchQuery = '';
  AuthService authService = AuthService();
  UserModel? user;

  Future<List<Plant>> fetchSearchResults(String search) async {
    final rawList = await PlantService.getAllPlant('?name=$search');
    return rawList.map((e) => Plant.fromJson(e)).toList();
  }

  Widget _searchBar() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Cari tanaman...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
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

  @override
  void initState() {
    super.initState();
    authService.getLoggedInUser().then((loadedUser) {
      setState(() {
        user = loadedUser;
      });
    });
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
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.network(
                      plant.imageUrl,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 80),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plant.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
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
                              backgroundColor: Colors.green.shade50,
                              labelStyle: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 4),
                        Text('Suhu: ${plant.minTemp}°C – ${plant.maxTemp}°C',
                            style: const TextStyle(fontSize: 12)),
                        Text(
                            'Kelembapan: ${plant.minHumidity}% – ${plant.maxHumidity}',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 6),
                        if (user != null)
                          ConvertedPriceText(
                              amount: plant.estimatedCost,
                              currencyOption: user!.config),
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;
    final secondaryColor = Colors.green.shade400;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Cari Tanaman',
                style: TextStyle(color: Colors.white)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _searchBar(),
            const SizedBox(height: 14),
            Expanded(child: _buildPlantList()),
          ],
        ),
      ),
    );
  }
}
