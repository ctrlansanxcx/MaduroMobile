// File: signup_screen.dart
import 'package:flutter/material.dart';
import 'signup_widget.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FFF4),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0), // Adjusted
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30), // Adjusted

                  // Back button
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10), // Adjusted
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8, // Adjusted
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Color(0xFFA0C334),
                            size: 20, // Adjusted
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), // Adjusted

                  // Logo and Title
                  Container(
                    width: 90, // Adjusted
                    height: 90, // Adjusted
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22), // Adjusted
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA0C334).withOpacity(0.1),
                          blurRadius: 18, // Adjusted
                          offset: const Offset(0, 8), // Adjusted
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22), // Adjusted
                      child: Image.asset(
                        'assets/icons/appicon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Adjusted

                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFA0C334), Color(0xFF7CB342)],
                    ).createShader(bounds),
                    child: const Text(
                      "MADURO",
                      style: TextStyle(
                        fontSize: 26, // Adjusted
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.5, // Adjusted
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Adjusted

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 20, // Adjusted
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 5), // Adjusted
                  Text(
                    "Join us and start your journey",
                    style: TextStyle(
                      fontSize: 14, // Adjusted
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 30), // Adjusted

                  // Signup Form with modern card design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Adjusted
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18, // Adjusted
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(24.0), // Adjusted
                      child: SignUpForm(),
                    ),
                  ),

                  const SizedBox(height: 30), // Adjusted
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
