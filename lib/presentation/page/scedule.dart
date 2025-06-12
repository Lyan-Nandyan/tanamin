import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/core/service/profile_image_service.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/widgets/add_plant_dialog.dart';
import 'package:tanamin/widgets/plant_card.dart';

class Scedule extends StatefulWidget {
  const Scedule({super.key});

  @override
  State<Scedule> createState() => _SceduleState();
}

class _SceduleState extends State<Scedule> {
  final NotifiService notifiService = NotifiService();
  final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');
  final plantBox = Hive.box<MyPlant>('my_plants');
  final AuthService authService = AuthService();
  final ProfileImageService _profileImageService = ProfileImageService();
  UserModel? currentUser;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    notifiService.init();
    _loadUser();
  }

  void _loadUser() async {
    final user = await authService.getLoggedInUser();
    final loadedProfileImage = await _profileImageService.getProfileImageFile();
    setState(() {
      currentUser = user;
      profileImage = loadedProfileImage;
    });
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (_) => AddPlantDialog(
        onSaved: () => setState(() {}),
        user: currentUser!,
        authService: authService,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final primaryColor = Colors.green.shade700;
    const double size = 56;

    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: profileImage != null
            ? Image.file(
                profileImage!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildInitialAvatar(primaryColor),
              )
            : _buildInitialAvatar(primaryColor),
      ),
    );
  }

  Widget _buildInitialAvatar(Color primaryColor) {
    return Text(
      currentUser?.nameInitial ?? '?',
      style: TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;
    final secondaryColor = Colors.green.shade400;
    final backgroundColor = Colors.grey.shade100;

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userPlantIds = currentUser!.tanaman.map(int.parse).toList();
    final plants = plantBox.keys
        .where((key) => userPlantIds.contains(key))
        .map((key) => plantBox.get(key))
        .whereType<MyPlant>()
        .toList();

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
                _buildProfileAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Tanaman',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        currentUser?.nama ?? 'Guest',
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
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: "Tambah Tanaman",
                  onPressed: _showAddPlantDialog,
                ),
              ],
            ),
          ),
          // Konten utama
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 18),
              child: plants.isEmpty
                  ? const Center(child: Text("Belum ada tanaman"))
                  : ListView.builder(
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final plant = plants[index];
                        final schedules = plant.scheduleIds
                            .map((id) => scheduleBox.get(id))
                            .whereType<PlantSchedule>()
                            .toList();

                        return PlantCard(
                          plant: plant,
                          schedules: schedules,
                          onScheduleDeleted: () => setState(() {}),
                          onPlantDeleted: () => setState(() {}),
                          notifiService: notifiService,
                          authService: authService,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
