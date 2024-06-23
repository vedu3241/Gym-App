import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/Screens/homeScreen.dart';
import 'package:gym_app/Screens/member_profile.dart';
import 'package:gym_app/Screens/membersScreen.dart';

class NavController extends StatefulWidget {
  const NavController({super.key});

  @override
  State<NavController> createState() => _NavControllerState();
}

class _NavControllerState extends State<NavController> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const HomeScreen(),
    const MembersScreen(),
  ];

  void _selectedPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.grey[200] ?? Colors.grey,
        color: const Color.fromARGB(255, 99, 137, 152),
        index: _currentIndex,
        onTap: (index) {
          _selectedPage(index);
        },
        items: const [
          Icon(Icons.home),
          Icon(Icons.people),
          // Icon(Icons.calendar_month), //for any events
          // Icon(Icons.person),
        ],
      ),
      body: _children[_currentIndex],
    );
  }
}
