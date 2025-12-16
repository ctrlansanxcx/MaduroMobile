import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final FirebaseAuth auth = FirebaseAuth.instance;

    Future<void> resetPassword() async {
      String email = emailController.text.trim();
      if (email.isEmpty) {
        showMessage(context, 'Please enter your email.');
        return;
      }

      try {
        await auth.sendPasswordResetEmail(email: email);
        showMessage(context, 'Reset link sent! Check your email.');
      } catch (e) {
        showMessage(context, 'Error: ${e.toString()}');
      }
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/appicon.png', height: 120),
              const SizedBox(height: 16),
              const Text(
                'FORGOT PASSWORD',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email and we will send you a reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(color: Colors.green),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.green),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SEND RESET LINK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
