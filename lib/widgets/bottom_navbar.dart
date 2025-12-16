import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          left: 20, right: 20, bottom: 20), // ✅ Bottom margin for the navbar
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7), // ✅ White background for the navbar
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
            bottom: Radius.circular(20) // ✅ Rounded top corners
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // ✅ Subtle shadow
            blurRadius: 20,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 30), // ✅ Add horizontal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              icon: Icons.camera_alt,
              label: "Camera",
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _buildNavItem(
              icon: Icons.history,
              label: "History",
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _buildNavItem(
              icon: Icons.person,
              label: "Profile",
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 50, // ✅ Large icons
            color: isActive
                ? Color(0xFFA0C334)
                : Color(0xFF5D5D5D), // ✅ Active color
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? Color(0xFFA0C334)
                  : Color(0xFF5D5D5D), // ✅ Active text color
            ),
          ),
        ],
      ),
    );
  }
}
