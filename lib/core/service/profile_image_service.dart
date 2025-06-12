import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tanamin/core/service/auth_service.dart';

class ProfileImageService {
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  /// Ambil File profil dari user yang sedang login
  Future<File?> getProfileImageFile() async {
    final user = await _authService.getLoggedInUser();
    if (user?.hasProfileImage == true) {
      final file = File(user!.profileImage!);
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  /// Pilih gambar dari galeri, simpan ke folder app, dan update user profile
  Future<File?> pickAndSaveImage() async {
    final user = await _authService.getLoggedInUser();
    if (user == null) return null;

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null;

    // Hapus gambar lama jika ada
    await deleteProfileImage();

    // Simpan gambar baru
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    final savedImage = await File(picked.path).copy(savedPath);

    // Update user profile dengan path gambar baru
    user.profileImage = savedImage.path;
    await user.save();

    return savedImage;
  }

  /// Hapus gambar profil dari user yang sedang login
  Future<void> deleteProfileImage() async {
    final user = await _authService.getLoggedInUser();
    if (user?.hasProfileImage == true) {
      final file = File(user!.profileImage!);
      if (await file.exists()) {
        await file.delete();
      }

      // Update user profile
      user.profileImage = null;
      await user.save();
    }
  }

  /// Ambil gambar dari kamera
  Future<File?> takeAndSavePhoto() async {
    final user = await _authService.getLoggedInUser();
    if (user == null) return null;

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return null;

    // Hapus gambar lama jika ada
    await deleteProfileImage();

    // Simpan gambar baru
    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${dir.path}/$fileName';
    final savedImage = await File(picked.path).copy(savedPath);

    // Update user profile dengan path gambar baru
    user.profileImage = savedImage.path;
    await user.save();

    return savedImage;
  }
}
