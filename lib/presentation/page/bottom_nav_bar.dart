import 'package:flutter/material.dart';
import 'package:tanamin/presentation/page/recomend.dart';
import 'package:tanamin/presentation/page/scedule.dart';
import 'package:tanamin/presentation/page/time_convert.dart';
import 'home.dart';
import 'profile.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    Home(),
    Recomend(),
    Scedule(),
    TimeConvert(),
    Profile(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildIconWithBackground(IconData iconData, int itemIndex) {
    bool isActive = _currentIndex == itemIndex;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blueGrey : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          unselectedItemColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.recommend, 1),
              label: 'Rekomendasi',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.schedule, 2),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.access_time, 3),
              label: 'Konversi Waktu',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithBackground(Icons.person, 4),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
