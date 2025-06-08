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
    debugPrint('User loaded: ${user!.nama}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${user?.nama ?? 'Guest'}'),
        actions: [
          IconButton(
              onPressed: () {
                authService.logout(context);
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LocationInfo(location: controller.location),
            const SizedBox(height: 20),
            WeatherInfo(weather: controller.weather),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await controller.fetchData();
                setState(() {});
              },
              child: const Text('Refresh Data'),
            ),
            const SizedBox(height: 20),
            const Text('Daftar Tanaman:'),
            const SizedBox(height: 10),
            Expanded(
              child: RecomendPlantList(
                  currentTemp: controller.currentTemp,
                  currentHumidity: controller.currentHumidity,
                  option: user!.config),
            ),
          ],
        ),
      ),
    );
  }
}
