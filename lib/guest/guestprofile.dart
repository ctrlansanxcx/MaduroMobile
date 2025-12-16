// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navbar.dart';

class GuestProfile extends StatefulWidget {
  const GuestProfile({super.key});

  @override
  _GuestProfileScreenState createState() => _GuestProfileScreenState();
}

class _GuestProfileScreenState extends State<GuestProfile> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, '/camera');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle("General Settings"),
                    _buildOptionCard(
                      icon: Icons.language,
                      text: "Language",
                      onTap: () => Navigator.pushNamed(context, '/language'),
                    ),
                    _buildOptionCard(
                      icon: Icons.info,
                      text: "About",
                      onTap: () => Navigator.pushNamed(context, '/about'),
                    ),
                    _buildOptionCard(
                      icon: Icons.description,
                      text: "Terms & Condition",
                      onTap: () => Navigator.pushNamed(context, '/tnc'),
                    ),
                    _buildOptionCard(
                      icon: Icons.lock,
                      text: "Privacy Policy",
                      onTap: () =>
                          Navigator.pushNamed(context, '/privacypolicy'),
                    ),
                    _buildOptionCard(
                      icon: Icons.star,
                      text: "Rate This App",
                      onTap: () => Navigator.pushNamed(context, '/rateus'),
                    ),
                    _buildOptionCard(
                      icon: Icons.share,
                      text: "Share This App",
                      onTap: () => Navigator.pushNamed(context, '/shareapp'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightGreen, Colors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Center(
        child: Text(
          "PROFILE",
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        String displayText = "Login";

        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.isAnonymous) {
            displayText = "${user.uid.substring(0, 10)}...";
          } else if (user.email != null) {
            displayText = user.email!;
          }
        }

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.person, size: 30),
            title: Text(
              displayText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/signout'),
          ),
        );
      },
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(text),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
