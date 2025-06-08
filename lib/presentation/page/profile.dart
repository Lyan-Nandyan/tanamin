import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tanamin/core/service/auth_service.dart';
import 'package:tanamin/core/service/currency_converter_service.dart';
import 'package:tanamin/data/models/user.dart';
import 'package:tanamin/presentation/screens/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _username;
  String? _email;
  UserModel? _user;
  final AuthService _authService = AuthService();
  final CurrencyConverterService _currencyService = CurrencyConverterService();

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp'},
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
  ];

  Future<void> _logout(BuildContext context) async {
    await _authService.logout(context);
  }

  Future<void> _loadUserData() async {
    UserModel? user = await _authService.getLoggedInUser();
    if (user != null) {
      setState(() {
        _user = user;
        _username = user.nama;
        _email = user.email;
      });
    }
  }

  Future<void> _updateCurrencyConfig(int newConfig) async {
    if (_user != null) {
      _user!.config = newConfig;
      await _user!.save();
      setState(() {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency updated to ${_currencies[newConfig]['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _getInitial() {
    if (_username == null || _username!.isEmpty) {
      return '?';
    }
    return _username![0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar
            Container(
              width: double.infinity,
              color: primaryColor,
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar circle with initial
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitial(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Username display
                  Text(
                    _username ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Email display
                  Text(
                    _email ?? 'email@example.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Profile actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings Section
                  Text(
                    "Settings",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Currency Settings
                  Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.monetization_on, color: primaryColor),
                      title: const Text(
                        'Currency',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _user != null 
                          ? '${_currencies[_user!.config]['name']} (${_currencies[_user!.config]['symbol']})'
                          : 'Loading...'
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onTap: () => _showCurrencyDialog(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  Text(
                    "About",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Profile menu items
                  _buildProfileMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),

                  _buildProfileMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Email Developer',
                    subtitle: 'lyannandyan@gmail.com',
                  ),

                  _buildProfileMenuItem(
                    context,
                    icon: Icons.star_outline,
                    title: 'Ratings',
                    subtitle: 'help us improve by rating the app',
                  ),

                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _currencies.length,
              itemBuilder: (context, index) {
                final currency = _currencies[index];
                final isSelected = _user?.config == index;
                
                return ListTile(
                  leading: Text(
                    currency['symbol'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  title: Text(currency['name']),
                  subtitle: Text(currency['code']),
                  trailing: isSelected 
                    ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
                    : null,
                  selected: isSelected,
                  onTap: () {
                    _updateCurrencyConfig(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final cardColor = Theme.of(context).cardColor;
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }
}
