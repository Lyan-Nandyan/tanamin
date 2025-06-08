import 'package:flutter/material.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/widgets/all_plant_list.dart';
import 'package:tanamin/widgets/search_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthService authService = AuthService();
  UserModel? user;

  @override
  void initState() {
    super.initState();
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
                        'Selamat datang,',
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
                  const SizedBox(height: 10),
                  const SearchBarWidget(),
                  const SizedBox(height: 18),
                  Center(
                    child: const Text(
                      'Daftar Tanaman',
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
                        : AllPlantList(option: user!.config),
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
