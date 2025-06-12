import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 5)
class UserModel extends HiveObject {
  @HiveField(0)
  String id; // ID unik (misal: email)

  @HiveField(1)
  String nama;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password; // hashed

  @HiveField(4)
  List<String> tanaman;

  @HiveField(5)
  int config; // default: 0 (IDR)

  @HiveField(6)
  String? profileImage; // Path ke gambar profil, opsional
  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.tanaman,
    required this.config,
    this.profileImage,
  });

  // Helper method untuk mendapatkan inisial nama
  String get nameInitial {
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }

  // Helper method untuk mengecek apakah user memiliki profile image
  bool get hasProfileImage {
    return profileImage != null && profileImage!.isNotEmpty;
  }
}
