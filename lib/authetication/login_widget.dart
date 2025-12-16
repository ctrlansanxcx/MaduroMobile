// File: login_widget.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADDED

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        _showVerificationDialog(userCredential.user!);
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/homescreen');
      }
    } on FirebaseAuthException {
      if (mounted) {
        _showErrorDialog("Incorrect email or password.");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showVerificationDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Email Not Verified", style: TextStyle(fontSize: 18)),
        content: const Text("Please verify your email before logging in.",
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Verification email sent!",
                      style: TextStyle(fontSize: 13)),
                  backgroundColor: const Color(0xFFA0C334),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text("Resend Email", style: TextStyle(fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Login Failed", style: TextStyle(fontSize: 18)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildInputField("Email",
                controller: _emailController, icon: Icons.email_outlined),
            const SizedBox(height: 16),
            _buildInputField(
              "Password",
              controller: _passwordController,
              obscureText: _obscurePassword,
              icon: Icons.lock_outline,
              toggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFA0C334), Color(0xFF7CB342)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA0C334).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "SIGN IN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgotpassword'),
              child: Text(
                "Forgot password?",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "or continue with",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _signInWithGoogle(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA0C334),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/signup'),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Color(0xFFA0C334),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED GOOGLE SIGN-IN (Firestore added)
  Future<void> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.disconnect();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('Google sign-in aborted by user.');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'created_at': FieldValue.serverTimestamp(),
            'uid': user.uid,
            'email': user.email,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').skip(1).join(' ') ?? '',
            'password': null,
          });
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/homescreen');
      }

      print('Signed in as ${userCredential.user?.email}');
    } catch (e) {
      print('Google sign-in error: $e');
      if (mounted) {
        _showErrorDialog("Google Sign-In failed. Please try again.");
      }
    }
  }

  Widget _buildInputField(
    String label, {
    bool obscureText = false,
    required TextEditingController controller,
    required IconData icon,
    VoidCallback? toggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          if (label == "Password" && value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFA0C334),
            size: 20,
          ),
          suffixIcon: toggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
