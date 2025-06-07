import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/test/test.dart';
import 'package:tanamin/test/test_konvert_waktu.dart';
import 'package:tanamin/test/test_notif.dart';

void main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  // Ensure that plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Get the application documents directory
  final appDocumentDir = await getApplicationDocumentsDirectory();
  // Initialize Hive
  Hive.init(appDocumentDir.path);
  // Register adapters
  Hive.registerAdapter(PlantScheduleAdapter());
  // Register MyPlant adapter
  Hive.registerAdapter(MyPlantAdapter());

  // Open boxes
  await Hive.openBox<PlantSchedule>('plant_schedules');
  await Hive.openBox<MyPlant>('my_plants');
  // Initialize NotifiService
  final notifiService = NotifiService();
  // Initialize and check timezone
  await notifiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TestKonvertWaktu(),
    );
  }
}
