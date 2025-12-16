// File: signup_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Slightly faster
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        await _saveUserData(user);

        // ADD THIS LINE TO SIGN THE USER OUT
        await FirebaseAuth.instance.signOut();

        _showVerificationDialog();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveUserData(User user) async {
    final bytes = utf8.encode(_passwordController.text.trim());
    final hashedPassword = sha256.convert(bytes).toString();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'created_at': FieldValue.serverTimestamp(),
      'uid': user.uid,
      'email': _emailController.text.trim(),
      'password': hashedPassword,
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
    });
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Verify Your Email", style: TextStyle(fontSize: 18)),
        content: const Text(
            "A verification link has been sent to your email. Please verify your account and then sign in.",
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              // REPLACE a simple pop with navigation to the login screen
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: const Text(
              "OK",
              style: TextStyle(color: Color(0xFFA0C334), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(FirebaseAuthException e) {
    String errorMsg = "An error occurred";
    if (e.code == 'email-already-in-use') {
      errorMsg = "Email is already registered.";
    } else if (e.code == 'weak-password') {
      errorMsg = "Password is too weak.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg, style: TextStyle(fontSize: 13)), // Adjusted
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Adjusted
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2), // Adjusted
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _slideAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      "First Name",
                      controller: _firstNameController,
                      validator: _validateName,
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12), // Adjusted
                  Expanded(
                    child: _buildInputField(
                      "Last Name",
                      controller: _lastNameController,
                      validator: _validateName,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Adjusted
              _buildInputField(
                "Email",
                controller: _emailController,
                validator: _validateEmail,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16), // Adjusted
              _buildInputField(
                "Password",
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                icon: Icons.lock_outline,
                toggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16), // Adjusted
              _buildInputField(
                "Confirm Password",
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                validator: _validateConfirmPassword,
                icon: Icons.lock_outline,
                toggleObscure: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              const SizedBox(height: 28), // Adjusted

              // Modern Sign up button
              Container(
                width: double.infinity,
                height: 50, // Adjusted
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA0C334), Color(0xFF7CB342)],
                  ),
                  borderRadius: BorderRadius.circular(14), // Adjusted
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA0C334).withOpacity(0.3),
                      blurRadius: 10, // Adjusted
                      offset: const Offset(0, 5), // Adjusted
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // Adjusted
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, // Adjusted
                          height: 22, // Adjusted
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15, // Adjusted
                            letterSpacing: 0.8, // Adjusted
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20), // Adjusted

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14, // Adjusted
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Color(0xFFA0C334),
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Adjusted
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label, {
    bool obscureText = false,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    VoidCallback? toggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14), // Adjusted
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(fontSize: 15), // Adjusted
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 14, // Adjusted
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFA0C334),
            size: 20, // Adjusted
          ),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20, // Adjusted
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, // Adjusted
            vertical: 14, // Adjusted
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 11, // Adjusted
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email cannot be empty";
    if (!RegExp(r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$")
        .hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return "This field cannot be empty";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password cannot be empty";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) return "Passwords do not match";
    if (value == null || value.isEmpty) return "Please confirm your password";
    return null;
  }
}
