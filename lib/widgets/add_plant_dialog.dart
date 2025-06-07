import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/data/models/myplant.dart';

class AddPlantDialog extends StatefulWidget {
  final VoidCallback onSaved;

  const AddPlantDialog({required this.onSaved, super.key});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final nameController = TextEditingController();
  final plantBox = Hive.box<MyPlant>('my_plants');

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah Tanaman"),
      content: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: "Nama Tanaman"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;

            final newPlant = MyPlant(name: name, scheduleIds: [], addedAt: DateTime.now());
            await plantBox.add(newPlant);

            widget.onSaved();
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
