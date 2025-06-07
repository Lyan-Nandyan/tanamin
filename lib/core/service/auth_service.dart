import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanamin/data/models/user.dart';
import '../utils/hash_util.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String sessionKey = 'loggedInUserId';

  Future<void> registerUser(
    String nama,
    String email,
    String password,
  ) async {
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
    }
  }

  Future<void> login(String email, String password) async {
    Box<UserModel> box = Hive.box<UserModel>(userBoxName);

    bool loginSuccess = box.values.any((user) =>
        user.email == email && user.password == hashPassword(password));

    if (loginSuccess) {
      UserModel? user = box.values.firstWhere(
        (user) => user.email == email && user.password == hashPassword(password),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(sessionKey, user.id);
      await prefs.setBool('userLoggedIn', true);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionKey);
    await prefs.remove('userLoggedIn');
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
    return prefs.getBool('userLoggedIn') ?? false;
  }
}
