import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/profile_image_service.dart';
import 'package:tanamin/data/models/user.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  UserModel? _user;
  File? _profileImage;
  final ProfileImageService _profileImageService = ProfileImageService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService().getLoggedInUser();
    final profileImage = await _profileImageService.getProfileImageFile();
    setState(() {
      _user = user;
      _profileImage = profileImage;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout(context);
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Ambil Foto'),
              onTap: () async {
                Navigator.pop(context);
                await _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageFromGallery();
              },
            ),
            if (_user?.hasProfileImage == true)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Foto'),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await _profileImageService.pickAndSaveImage();
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
        await _loadUserData(); // Refresh user data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final image = await _profileImageService.takeAndSavePhoto();
      if (image != null) {
        setState(() {
          _profileImage = image;
        });
        await _loadUserData(); // Refresh user data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteProfileImage() async {
    try {
      await _profileImageService.deleteProfileImage();
      setState(() {
        _profileImage = null;
      });
      await _loadUserData(); // Refresh user data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildProfileAvatar() {
    const double avatarSize = 110;

    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Stack(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(avatarSize / 2),
              child: _profileImage != null
                  ? Image.file(
                      _profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitialAvatar(),
                    )
                  : _buildInitialAvatar(),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar() {
    final primaryColor = Colors.green.shade700;
    return Center(
      child: Text(
        _user?.nameInitial ?? '?',
        style: TextStyle(
          color: primaryColor,
          fontSize: 54,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green.shade700;
    final secondaryColor = Colors.green.shade400;
    final backgroundColor = Colors.grey.shade100;

    // List mata uang
    final currencyOptions = const [
      'Rupiah (IDR)',
      'Dollar Amerika (USD)',
      'Euro (EUR)',
      'Poundsterling (GBP)',
      'Yen Jepang (JPY)',
      'Dollar Singapura (SGD)',
      'Dollar Australia (AUD)',
    ];

    // List logo/icon untuk setiap mata uang
    final currencyIcons = const [
      Icons.payments, // IDR
      Icons.attach_money, // USD
      Icons.euro, // EUR
      Icons.currency_pound, // GBP
      Icons.currency_yen, // JPY
      Icons.currency_exchange, // SGD
      Icons.currency_exchange, // AUD
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  const Text('Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 28),
                  // Avatar with shadow and border
                  _buildProfileAvatar(),
                  const SizedBox(height: 18),
                  Text(
                    _user?.nama ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'email@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Profile actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Setting Mata Uang ---
                  const Text(
                    "Setting",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      child: DropdownButton<int>(
                        value: _user?.config ?? 0,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: List.generate(currencyOptions.length, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Row(
                              children: [
                                Icon(currencyIcons[i],
                                    color: Colors.green.shade700, size: 20),
                                const SizedBox(width: 8),
                                Text(currencyOptions[i]),
                              ],
                            ),
                          );
                        }),
                        onChanged: (val) async {
                          if (_user != null && val != null) {
                            setState(() {
                              _user!.config = val;
                            });
                            await _user!.save();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mata uang berhasil diubah!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // --- Tentang Aplikasi ---
                  const Text(
                    "Tentang Aplikasi",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _profileMenuItem(Icons.info_outline, 'Versi', '1.0.0'),
                  _profileMenuItem(Icons.person_outline, 'Email Developer',
                      'lyannandyan@gmail.com'),
                  _profileMenuItem(Icons.star_outline, 'Rating',
                      'Bantu kami berkembang dengan memberi rating aplikasi'),
                  const SizedBox(height: 28),
                  const Text(
                    "Pesan & Kesan",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _profileMenuItem(Icons.message, 'Pesan & Kesan Mata Kuliah',
                      'Mata kuliah Teknologi Pemrograman Mobile sangat menyenangkan dan menantang. Tugas akhir yang memiliki kriteria unik memacu kreativitas, meskipun beberapa fitur seperti notifikasi harus dipelajari secara mandiri di luar materi praktikum maupun teori. Pengalaman ini memperluas wawasan dan melatih kemandirian dalam pengembangan aplikasi mobile.'),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: Colors.red.shade100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String title, String subtitle) => Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade50,
            child: Icon(icon, color: Colors.green.shade700),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 13),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
      );
}
