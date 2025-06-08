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
      title: Text(schedule.title),
      subtitle: Text(
        'Jam: ${schedule.hour}:${schedule.minute.toString().padLeft(2, '0')} ${schedule.zone} | '
        'Hari: ${schedule.repeatDays.join(', ')}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _deleteSchedule,
      ),
    );
  }
}
