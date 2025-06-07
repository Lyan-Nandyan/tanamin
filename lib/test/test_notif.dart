import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class TestNotif extends StatefulWidget {
  const TestNotif({super.key});

  @override
  State<TestNotif> createState() => _TestNotifState();
}

class _TestNotifState extends State<TestNotif> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
  initializeTimeZones();

  setLocalLocation(
    getLocation('Asia/Jakarta'),
  );

  const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSetting,
  );
  await notificationsPlugin.initialize(initializationSettings);

  // Minta izin notifikasi di Android 13+
  final bool? granted = await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  if (granted != null && granted) {
    print("Izin notifikasi diberikan");
  } else {
    print("Izin notifikasi ditolak atau tidak diminta");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notif'),
      ),
      body: Center(
        child: Text("HEllo World!"),
      ),
    );
  }
}
