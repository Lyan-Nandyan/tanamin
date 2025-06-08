import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/myplant.dart';
import 'package:tanamin/data/models/schedule.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/presentation/page/bottom_nav_bar.dart';
import 'package:tanamin/presentation/screens/login.dart';

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
  // Register UserModel adapter
  Hive.registerAdapter(UserModelAdapter());

  // Open boxes
  await Hive.openBox<PlantSchedule>('plant_schedules');
  await Hive.openBox<MyPlant>('my_plants');
  await Hive.openBox<UserModel>('users');
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
          appBarTheme: const AppBarTheme(
            backgroundColor:
                Colors.green, // Ganti dengan warna sesuai tema kamu
            scrolledUnderElevation: 0,
            elevation: 0,
            surfaceTintColor: Colors.transparent, // ← INI YANG PALING PENTING
          ),
          scaffoldBackgroundColor: Colors.green[200]),
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return BottomNavbar();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
