import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/data/models/user.dart';

class AddPlantDialog extends StatefulWidget {
  final VoidCallback onSaved;
  final AuthService authService;
  final UserModel user;

  const AddPlantDialog(
      {required this.onSaved,
      super.key,
      required this.authService,
      required this.user});

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

            final newPlant =
                MyPlant(name: name, scheduleIds: [], addedAt: DateTime.now());
            final key = await plantBox.add(newPlant);

            // Simpan ID ke user yang sedang login
            widget.user.tanaman.add(key.toString());
            await widget.user.save();

            widget.onSaved();
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}
