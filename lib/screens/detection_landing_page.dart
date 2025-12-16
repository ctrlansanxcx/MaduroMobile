import 'package:flutter/material.dart';
import 'package:maduro/widgets/bottom_navbar.dart';

class DetectionLandingPage extends StatefulWidget {
  const DetectionLandingPage({super.key});
  @override
  _DetectionLandingPageState createState() => _DetectionLandingPageState();
}

class _DetectionLandingPageState extends State<DetectionLandingPage> {
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // ✅ Handle navigation taps
      ),
      body: Container(
        width: double.infinity,
        color: Color(0xFFF7F7F7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/camerapage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.photo_library, color: Color(0xFFF7F7F7)),
                      SizedBox(width: 8),
                      Text(
                        'OPEN CAMERA',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFF7F7F7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.photo_library, color: Color(0xFFF7F7F7)),
                      SizedBox(width: 8),
                      Text(
                        'UPLOAD IMAGE',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFF7F7F7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
