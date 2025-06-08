import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/notifi_service.dart';
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
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    notifiService.init();
    _loadUser();
  }

  void _loadUser() async {
    final user = await authService.getLoggedInUser();
    setState(() {
      currentUser = user;
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

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: Text('Tanaman Kamu ${currentUser?.nama ?? 'Guest'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPlantDialog,
          ),
          IconButton(
              onPressed: () {
                authService.logout(context);
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: plants.isEmpty
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
    );
  }
}
