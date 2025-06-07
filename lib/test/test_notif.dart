import 'package:flutter/material.dart';
import 'package:tanamin/core/service/notifi_service.dart';

class TestNotif extends StatefulWidget {
  const TestNotif({super.key});

  @override
  State<TestNotif> createState() => _TestNotifState();
}

class _TestNotifState extends State<TestNotif> {
  NotifiService notifiService = NotifiService();

  @override
  void initState() {
    super.initState();
    notifiService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notif'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await notifiService.showInstantNotification(
                  id: 0,
                  title: 'Instant Notification',
                  body: 'Ini adalah notifikasi instan.',
                );
              },
              child: const Text('Tampilkan Notifikasi Instan'),
            ),
            ElevatedButton(
              onPressed: () async {
                await notifiService.scheduleReminder(
                  id: 1,
                  title: 'Pengingat Harian',
                  body: 'Ini adalah pengingat harian.',
                );
              },
              child: const Text('Jadwalkan Pengingat Harian'),
            ),
          ],
        ),
      ),
    );
  }
}
