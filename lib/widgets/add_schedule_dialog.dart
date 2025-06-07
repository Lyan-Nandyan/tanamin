import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:timezone/timezone.dart' as tz;

class AddScheduleDialog extends StatefulWidget {
  final MyPlant plant;
  final VoidCallback onSaved;

  const AddScheduleDialog(
      {required this.plant, required this.onSaved, super.key});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final NotifiService notifiService = NotifiService();
  final scheduleBox = Hive.box<PlantSchedule>('plant_schedules');
  final localZone = tz.local;
  TimeOfDay selectedTime = TimeOfDay.now();
  List<bool> selectedDays = List.generate(7, (_) => false);
  String selectedAction = 'Menyiram';

  final weekdays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          "Tambah Jadwal untuk ${widget.plant.name}\n Zona lokal saat ini $localZone"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedAction,
              items: ['Menyiram', 'Memupuk', 'Menyemprot']
                  .map((action) => DropdownMenuItem<String>(
                        value: action,
                        child: Text(action),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedAction = value ?? 'Menyiram');
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
              child: Text("Pilih Jam"),
            ),
            const SizedBox(height: 10),
            const Text("Pilih Hari:"),
            ...List.generate(7, (index) {
              return CheckboxListTile(
                title: Text(weekdays[index]),
                value: selectedDays[index],
                onChanged: (value) {
                  setState(() => selectedDays[index] = value ?? false);
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            final hour = selectedTime.hour;
            final minute = selectedTime.minute;
            final repeatDays = List.generate(7, (i) => i + 1)
                .where((i) => selectedDays[i - 1])
                .toList();

            if (repeatDays.isEmpty) {
              // Minimal 1 hari harus dipilih
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pilih minimal satu hari!")),
              );
              return;
            }

            final title = "$selectedAction ${widget.plant.name}";
            final body =
                "Jangan lupa $selectedAction tanaman ${widget.plant.name} kamu.";

            final key = await scheduleBox.add(
              PlantSchedule(
                id: -1,
                hour: hour,
                minute: minute,
                repeatDays: repeatDays,
                title: title,
                body: body,
                zone: localZone.toString(),
              ),
            );

            final savedSchedule = scheduleBox.get(key);
            if (savedSchedule != null) {
              final updated = PlantSchedule(
                id: key,
                hour: savedSchedule.hour,
                minute: savedSchedule.minute,
                repeatDays: savedSchedule.repeatDays,
                title: savedSchedule.title,
                body: savedSchedule.body,
                zone: savedSchedule.zone,
              );
              await scheduleBox.put(key, updated);
              await notifiService.scheduleRepeatedReminder(updated);

              widget.plant.scheduleIds.add(key);
              await widget.plant.save();

              debugPrint(
                  "Jadwal disimpan dan ditautkan ke ${widget.plant.name}");
            }

            widget.onSaved();
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
