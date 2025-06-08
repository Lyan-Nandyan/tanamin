import 'package:flutter/material.dart';
import 'package:tanamin/core/controller/location_weather_controller.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/widgets/location_info.dart';
import 'package:tanamin/widgets/recomend_plant_list.dart';
import 'package:tanamin/widgets/weather_info.dart';

class Recomend extends StatefulWidget {
  const Recomend({super.key});

  @override
  State<Recomend> createState() => _RecomendState();
}

class _RecomendState extends State<Recomend> {
  final controller = LocationWeatherController();
  AuthService authService = AuthService();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    controller.init(() {
      setState(() {});
    });
    _loadUser();
  }

  void _loadUser() async {
    final loadedUser = await authService.getLoggedInUser();
    setState(() {
      user = loadedUser;
    });
    debugPrint('User loaded: ${user?.nama}');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;
    final secondaryColor = Colors.green.shade400;
    final backgroundColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header dengan gradient dan avatar
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    (user?.nama.isNotEmpty ?? false)
                        ? user!.nama[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi untuk,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user?.nama ?? 'Guest',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Konten utama
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LocationInfo(location: controller.location),
                  const SizedBox(height: 12),
                  WeatherInfo(weather: controller.weather),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await controller.fetchData();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      label: const Text('Refresh Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: const Text(
                      'Daftar Tanaman Rekomendasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: user == null
                        ? const Center(child: CircularProgressIndicator())
                        : RecomendPlantList(
                            currentTemp: controller.currentTemp,
                            currentHumidity: controller.currentHumidity,
                            option: user!.config,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
