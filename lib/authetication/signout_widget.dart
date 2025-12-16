import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  String getFullName() {
    if (firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty) {
      return "${firstNameController.text} ${lastNameController.text}";
    }
    return "User";
  }

  Future<void> fetchUserData(VoidCallback onUpdated) async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (userDoc.exists) {
          firstNameController.text = userDoc['firstName'] ?? '';
          lastNameController.text = userDoc['lastName'] ?? '';
          onUpdated();
        }
      } catch (e) {
        // Handle error silently or log it
      }
    }
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
  }
}

Widget buildModernCard({
  required IconData icon,
  required String label,
  required String value,
  required List<Color> gradient,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildModernProfileHeader(User user, UserProfileController controller) {
  return SizedBox(
    height: 280,
    child: Stack(
      children: [
        // Background gradient
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA0C334).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        // Decorative elements
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 60,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: -20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Profile content
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.displayName ?? controller.getFullName(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 30),
              // Profile avatar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildModernActionButton({
  required IconData icon,
  required String label,
  required List<Color> colors,
  required VoidCallback onPressed,
  bool isLoading = false,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 97),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    ),
  );
}

Widget buildModernInputField(String label, TextEditingController controller) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFA0C334),
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    ),
  );
}

// Additional utility widgets for enhanced functionality
Widget buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.trending_up,
                color: color,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget buildQuickActionTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
  required Color iconColor,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.shade400,
        size: 16,
      ),
    ),
  );
}
