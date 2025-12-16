// File: login_screen.dart
import 'package:flutter/material.dart';
import 'login_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0), // Adjusted
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Adjusted

                    // App Logo with modern container
                    Container(
                      width: 100, // Adjusted
                      height: 100, // Adjusted
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25), // Adjusted
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA0C334).withOpacity(0.1),
                            blurRadius: 18, // Adjusted
                            offset: const Offset(0, 8), // Adjusted
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25), // Adjusted
                        child: Image.asset(
                          'assets/icons/appicon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Adjusted

                    // App Name with modern typography
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFA0C334), Color(0xFF7CB342)],
                      ).createShader(bounds),
                      child: const Text(
                        "MADURO",
                        style: TextStyle(
                          fontSize: 28, // Adjusted
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.5, // Adjusted
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Adjusted

                    // Welcome text with better spacing
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontSize: 22, // Adjusted
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 8), // Adjusted
                    Text(
                      "Sign in to continue your journey",
                      style: TextStyle(
                        fontSize: 15, // Adjusted
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40), // Adjusted

                    // Login Form with modern card design
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
                        padding: EdgeInsets.all(28.0), // Adjusted
                        child: LoginForm(),
                      ),
                    ),

                    const SizedBox(height: 28), // Adjusted
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
