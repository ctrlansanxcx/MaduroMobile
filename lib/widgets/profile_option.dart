import 'package:flutter/material.dart';

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap; // ✅ Accepts a function

  const ProfileOption({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ Make it clickable
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Icon(icon, color: Colors.black54),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
