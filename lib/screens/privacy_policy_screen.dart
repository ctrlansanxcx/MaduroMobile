import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB5DB49),
              Color(0xFFEAD938),
              Color(0xFFF5EE62),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Your privacy matters to us",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildPrivacySection(
                          number: "1",
                          title: "Introduction",
                          content:
                              "Welcome to Maduro. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.",
                          icon: Icons.description_rounded,
                        ),
                        _buildPrivacySection(
                          number: "2",
                          title: "Information We Collect",
                          content:
                              "Maduro does not collect personally identifiable information. However, we may collect anonymized analytics data to improve app performance.",
                          icon: Icons.data_usage_rounded,
                        ),
                        _buildPrivacySection(
                          number: "3",
                          title: "Use of Data",
                          content:
                              "The data collected is used to enhance app functionality, optimize user experience, and analyze performance. We do not sell, trade, or share user data with third parties.",
                          icon: Icons.analytics_rounded,
                        ),
                        _buildPrivacySection(
                          number: "4",
                          title: "Data Storage and Security",
                          content:
                              "All data processing happens locally on your device. We do not store images or personal data on external servers. We take necessary measures to secure the app from unauthorized access.",
                          icon: Icons.lock_rounded,
                        ),
                        _buildPrivacySection(
                          number: "5",
                          title: "Third-Party Services",
                          content:
                              "Our app may include links to third-party services or APIs. We are not responsible for the privacy practices of these external services.",
                          icon: Icons.link_rounded,
                        ),
                        _buildPrivacySection(
                          number: "6",
                          title: "User Rights",
                          content:
                              "Users have the right to request information on how their data is used, and to opt out of any data collection.",
                          icon: Icons.person_outline_rounded,
                        ),
                        _buildPrivacySection(
                          number: "7",
                          title: "Changes to Privacy Policy",
                          content:
                              "We may update this Privacy Policy from time to time. Continued use of the app signifies acceptance of any changes.",
                          icon: Icons.update_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySection({
    required String number,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4C3).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF689F38),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
