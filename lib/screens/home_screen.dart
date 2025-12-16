// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../../widgets/start_button.dart';
import '../../widgets/bottom_navbar.dart'; // ✅ Import BottomNavBar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // ✅ Set Home as active tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/detectionLandingPage');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/history'); // ✅ Navigate to Profile Page
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile'); // ✅ Navigate to Profile Page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // ✅ Handle navigation taps
      ),
      body: SafeArea(
        child: Center(
          // ✅ Ensures centering
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // ✅ Optional padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ Centers content
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'FRUIT DETECTOR',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D5D5D),
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/fruits.png',
                  height: 300,
                  fit: BoxFit.contain, // ✅ Ensures the image fits well
                ),
                const SizedBox(height: 20),
                const StartButton(), // ✅ Start Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
