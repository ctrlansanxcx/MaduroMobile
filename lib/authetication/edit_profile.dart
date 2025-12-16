import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with TickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _firstNameController.text = userDoc['firstName'] ?? '';
            _lastNameController.text = userDoc['lastName'] ?? '';
          });
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    if (user != null) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFFA0C334),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to update profile'),
                ],
              ),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildModernHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Update your profile details below',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildModernInputField("First Name", _firstNameController,
                          Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildModernInputField("Last Name", _lastNameController,
                          Icons.person_outline),
                      const SizedBox(height: 40),
                      _buildModernSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      height: 140,
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
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 60,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Header content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Customize your information',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInputField(
      String label, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
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
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFA0C334),
            size: 22,
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
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildModernSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA0C334).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
