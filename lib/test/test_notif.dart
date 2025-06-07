import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/widgets/add_plant_dialog.dart';
import 'package:tanamin/widgets/add_schedule_dialog.dart';

class TestNotif extends StatefulWidget {
  const TestNotif({super.key});

  @override
  State<TestNotif> createState() => _TestNotifState();
}

class _TestNotifState extends State<TestNotif> {
  final NotifiService notifiService = NotifiService();
  final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');
  final plantBox = Hive.box<MyPlant>('my_plants');

  @override
  void initState() {
    super.initState();
    notifiService.init();
  }

  void _showAddPlantDialog() {
    showDialog(
      context: context,
      builder: (_) => AddPlantDialog(onSaved: () => setState(() {})),
    );
  }

  void _showAddScheduleDialog(MyPlant plant) {
    showDialog(
      context: context,
      builder: (_) => AddScheduleDialog(
        plant: plant,
        onSaved: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plants = plantBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanaman Kamu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPlantDialog,
          )
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

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(plant.name),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Tanaman'),
                                content: Text(
                                    'Apakah kamu yakin ingin menghapus "${plant.name}" beserta semua jadwalnya?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Batal'),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  TextButton(
                                    child: const Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              // Hapus semua jadwal & notifikasi
                              for (var id in plant.scheduleIds) {
                                final schedule = scheduleBox.get(id);
                                if (schedule != null) {
                                  await notifiService
                                      .deleteScheduleWithNotification(schedule);
                                }
                              }
                              await plant.delete();
                              setState(() {});
                            }
                          },
                        )
                      ],
                    ),
                    subtitle: Text('Jadwal: ${schedules.length}'),
                    children: [
                      ...schedules.map((s) => ListTile(
                            title: Text(s.title),
                            subtitle: Text(
                              'Jam: ${s.hour}:${s.minute.toString().padLeft(2, '0')} | '
                              'Hari: ${s.repeatDays.join(', ')}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await notifiService
                                    .deleteScheduleWithNotification(s);
                                plant.scheduleIds.remove(s.id);
                                debugPrint(
                                    "Jadwal dengan ID ${s.id} dihapus dari tanaman ${plant.name}");
                                await plant.save();
                                debugPrint('dan isi tanaman ${plant.name} adalah ${plant.scheduleIds.length}');
                                setState(() {});
                              },
                            ),
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Tambah Jadwal"),
                            onPressed: () => _showAddScheduleDialog(plant),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
