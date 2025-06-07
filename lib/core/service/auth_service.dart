import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanamin/data/models/user.dart';
import '../utils/hash_util.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionKey = 'loggedInUserId';

  Future<void> registerUser({
    required String nama,
    required String email,
    required String password,
  }) async {
    var box = await Hive.openBox<UserModel>(userBoxName);
    bool exists = box.values.any((user) => user.email == email);
    if (exists) {
      throw Exception('Email sudah terdaftar');
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
    
    UserModel newUser = box.getAt(key)!;
    if (newUser.id.isEmpty) {
      newUser.id = key.toString();  // Set the ID to the key
      await newUser.save();
    }
  }

  Future<UserModel?> login(String email, String password) async {
    final box = await Hive.openBox<UserModel>(userBoxName);
    final user = box.get(email);

    if (user == null) return null;

    if (user.password == hashPassword(password)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sessionKey, user.id);
      return user;
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(sessionKey);
    if (id == null) return null;

    final box = await Hive.openBox<UserModel>(userBoxName);
    return box.get(id);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(sessionKey);
  }
}
