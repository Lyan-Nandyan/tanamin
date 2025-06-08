import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanamin/core/service/notifi_service.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/presentation/page/bottom_nav_bar.dart';
import 'package:tanamin/presentation/screens/login.dart';
import '../utils/hash_util.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionKey = 'loggedInUserId';
  NotifiService notifiService = NotifiService();

  Future<void> registerUser(
      String nama, String email, String password, context) async {
    var box = Hive.box<UserModel>(userBoxName);
    bool exists = box.values.any((user) => user.email == email);
    if (exists) {
      throw Exception('User with this email already exists');
    }
    int key = await box.add(
      UserModel(
        id: '', // Use email as unique ID
        nama: nama,
        email: email,
        password: hashPassword(password), // Hash the password
        tanaman: [],
        config: 0, // Default config
      ),
    );

    UserModel? newUser = box.get(key);
    if (newUser != null) {
      newUser.id = key.toString(); // Set the ID to the key
      await newUser.save();
      ScaffoldMessenger.of(
        context, // Ensure you have a valid BuildContext here
      ).showSnackBar(const SnackBar(
        content: Text('Regis Berhasil'),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    Box<UserModel> box = Hive.box<UserModel>(userBoxName);

    bool loginSuccess = box.values.any((user) =>
        user.email == email && user.password == hashPassword(password));

    if (loginSuccess) {
      UserModel? user = box.values.firstWhere(
        (user) =>
            user.email == email && user.password == hashPassword(password),
      );

      debugPrint('User logged in: ${user.nama}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sessionKey, user.id);
      await prefs.setBool('userLoggedIn', true);
      ScaffoldMessenger.of(
        context, // Ensure you have a valid BuildContext here
      ).showSnackBar(const SnackBar(
        content: Text('Login Berhasil'),
        backgroundColor: Colors.green,
      ));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const BottomNavbar()));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
        content: Text('username atau password salah'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> logout(context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
    await prefs.remove('userLoggedIn');
    await notifiService.cancelAllNotifications();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Login()));
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(sessionKey);
    debugPrint('getLoggedInUser: $id');
    if (id == null) return null;

    final box = await Hive.openBox<UserModel>(userBoxName);
    debugPrint('getLoggedInUser: ${box.get(int.parse(id))}');
    return box.get(int.parse(id));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('userLoggedIn') ?? false;
  }
}
