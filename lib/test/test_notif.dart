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
                final weekdays = [
                  'Senin',
                  'Selasa',
                  'Rabu',
                  'Kamis',
                  'Jumat',
                  'Sabtu',
                  'Minggu'
                ];
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
              // Ambil data dari form
              final hour = selectedTime.hour;
              final minute = selectedTime.minute;
              final repeatDays = List.generate(7, (i) => i + 1)
                  .where((i) => selectedDays[i - 1])
                  .toList();
              final title = titleController.text;
              final body = bodyController.text;

              // Simpan dulu ke Hive, biar dapat key unik dari Hive
              final key = await scheduleBox.add(
                PlantSchedule(
                  id: -1, // Sementara, akan diupdate setelah dapat key Hive
                  hour: hour,
                  minute: minute,
                  repeatDays: repeatDays,
                  title: title,
                  body: body,
                ),
              );

              // Ambil kembali object-nya
              final savedSchedule = scheduleBox.get(key);

              if (savedSchedule != null) {
                // Buat salinan dengan ID yang diperbarui berdasarkan key Hive
                final updatedSchedule = PlantSchedule(
                  id: key, // Gunakan key Hive sebagai ID notifikasi
                  hour: savedSchedule.hour,
                  minute: savedSchedule.minute,
                  repeatDays: savedSchedule.repeatDays,
                  title: savedSchedule.title,
                  body: savedSchedule.body,
                );

                // Simpan kembali dengan key yang sama (overwrite)
                await scheduleBox.put(key, updatedSchedule);
                debugPrint("Jadwal disimpan dengan ID: $key");
                debugPrint('data jadwal: ${updatedSchedule.id}, '
                    '${updatedSchedule.hour}, ${updatedSchedule.minute}, '
                    '${updatedSchedule.repeatDays}, ${updatedSchedule.title}, '
                    '${updatedSchedule.body}');

                // Jadwalkan notifikasi menggunakan ID dari key Hive
                await notifiService.scheduleRepeatedReminder(updatedSchedule);
              }

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
                debugPrint("Jadwal dengan ID ${schedule.id} dihapus");
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
