import 'package:flutter/material.dart';
import 'rides_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class RiderHomeScreen extends StatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  State<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends State<RiderHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    RidesScreen(),
    MessagesScreen(),
    RiderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFA8CABA), // Accent green tint

     backgroundColor: const Color(0xFFFAF9F6),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
  decoration: BoxDecoration(
    color: const Color(0xFFFAF9F6),
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, -1),
      ),
    ],
  ),
  child: BottomNavigationBar(
    
    backgroundColor: Color(0xFFA8CABA).withOpacity(0.15),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    currentIndex: _selectedIndex,
    onTap: (index) => setState(() => _selectedIndex = index),
    selectedItemColor: const Color(0xFF255A45),
    unselectedItemColor: Colors.grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.directions_car),
        label: 'Rides',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: 'Profile',
      ),
    ],
  ),
),
);
}
}