import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/schedule.dart';

class TestNotif extends StatefulWidget {
  const TestNotif({super.key});

  @override
  State<TestNotif> createState() => _TestNotifState();
}

class _TestNotifState extends State<TestNotif> {
  NotifiService notifiService = NotifiService();
  final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');

  @override
  void initState() {
    super.initState();
    notifiService.init();
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<bool> selectedDays = List.generate(7, (_) => false); // Senin-Minggu

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Jadwal"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Judul"),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: "Deskripsi"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) selectedTime = picked;
                },
                child: Text("Pilih Jam"),
              ),
              SizedBox(height: 8),
              Text("Pilih Hari:"),
              ...List.generate(7, (index) {
                final weekdays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                return CheckboxListTile(
                  title: Text(weekdays[index]),
                  value: selectedDays[index],
                  onChanged: (value) {
                    setState(() => selectedDays[index] = value!);
                  },
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
              final newSchedule = PlantSchedule(
                id: id,
                hour: selectedTime.hour,
                minute: selectedTime.minute,
                repeatDays: List.generate(7, (i) => i + 1).where((i) => selectedDays[i - 1]).toList(),
                title: titleController.text,
                body: bodyController.text,
              );

              await scheduleBox.add(newSchedule);
              await notifiService.scheduleRepeatedReminder(newSchedule);

              Navigator.pop(context);
              setState(() {}); // Refresh UI
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = scheduleBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notif'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddScheduleDialog,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];

          return ListTile(
            title: Text(schedule.title),
            subtitle: Text(
              'Jam: ${schedule.hour}:${schedule.minute.toString().padLeft(2, '0')}, '
              'Hari: ${schedule.repeatDays.join(', ')}',
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await notifiService.deleteScheduleWithNotification(schedule);
                await scheduleBox.deleteAt(index);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Jadwal dihapus')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
