// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../widgets/start_button.dart';
import '../widgets/bottom_navbar.dart'; // ✅ Import BottomNavBar

class GuestUser extends StatefulWidget {
  const GuestUser({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<GuestUser> {
  int _selectedIndex = 0; // ✅ Set Home as active tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/camera');
    } else if (index == 1) {
      Navigator.pushNamed(
          context, '/guestprofile'); // ✅ Navigate to Profile Page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
