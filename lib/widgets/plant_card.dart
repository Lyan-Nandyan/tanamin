import 'package:flutter/material.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/widgets/add_schedule_dialog.dart';
import 'package:tanamin/widgets/schedule_list_tile.dart';

class PlantCard extends StatelessWidget {
  final MyPlant plant;
  final List<PlantSchedule> schedules;
  final VoidCallback onScheduleDeleted;
  final VoidCallback onPlantDeleted;
  final NotifiService notifiService;
  final AuthService authService;

  const PlantCard({
    super.key,
    required this.plant,
    required this.schedules,
    required this.onScheduleDeleted,
    required this.onPlantDeleted,
    required this.notifiService,
    required this.authService,
  });

  void _showAddScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddScheduleDialog(
        plant: plant,
        onSaved: onScheduleDeleted,
      ),
    );
  }

  Future<void> _deletePlant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tanaman'),
        content: Text(
            'Apakah kamu yakin ingin menghapus "${plant.name}" beserta semua jadwalnya?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');

      for (var id in plant.scheduleIds) {
        final schedule = scheduleBox.get(id);
        if (schedule != null) {
          await notifiService.deleteScheduleWithNotification(schedule);
        }
      }

      await plant.delete();

      final user = await authService.getLoggedInUser();
      if (user != null) {
        user.tanaman.remove(plant.key.toString());
        await user.save();
      }

      onPlantDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              plant.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePlant(context),
              tooltip: "Hapus Tanaman",
            )
          ],
        ),
        subtitle: Text('Jadwal: ${schedules.length}'),
        children: [
          ...schedules.map((s) => ScheduleListTile(
                schedule: s,
                plant: plant,
                notifiService: notifiService,
                onDeleted: onScheduleDeleted,
              )),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text("Tambah Jadwal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () => _showAddScheduleDialog(context),
              ),
            ),
          )
        ],
      ),
    );
  }
}
