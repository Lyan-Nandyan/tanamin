import 'package:flutter/material.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/core/service/notifi_service.dart';

class ScheduleListTile extends StatelessWidget {
  final PlantSchedule schedule;
  final MyPlant plant;
  final NotifiService notifiService;
  final VoidCallback onDeleted;

  const ScheduleListTile({
    super.key,
    required this.schedule,
    required this.plant,
    required this.notifiService,
    required this.onDeleted,
  });

  Future<void> _deleteSchedule() async {
    await notifiService.deleteScheduleWithNotification(schedule);
    plant.scheduleIds.remove(schedule.id);
    await plant.save();
    onDeleted();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      title: Text(
        schedule.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Jam: ${schedule.hour}:${schedule.minute.toString().padLeft(2, '0')} (${schedule.zone})\n'
        'Hari: ${schedule.repeatDays.join(', ')}',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.grey),
        onPressed: _deleteSchedule,
        tooltip: "Hapus Jadwal",
      ),
    );
  }
}
