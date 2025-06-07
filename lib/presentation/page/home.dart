import 'package:flutter/material.dart';
import 'package:tanamin/core/controller/location_weather_controller.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/widgets/location_info.dart';
import 'package:tanamin/widgets/plant_list.dart';
import 'package:tanamin/widgets/search_bar.dart';
import 'package:tanamin/widgets/weather_info.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.nama ?? 'Guest'),
              accountEmail: Text(user?.email ?? 'Not logged in'),
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () async {
                await authService.logout(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SearchBarWidget(),
            const SizedBox(height: 20),
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
              child: PlantListWidget(option: user!.config),
            ),
          ],
        ),
      ),
    );
  }
}
