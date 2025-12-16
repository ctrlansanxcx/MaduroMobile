import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Launch email client
  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'maduroapp@gmail.com',
      query: 'subject=Support Inquiry&body=Hello Maduro Team,',
    );
    if (!await launchUrl(emailLaunchUri)) {
      // Handle error, maybe show a snackbar or dialog
      debugPrint('Could not launch email client');
    }
  }

  // Launch website URL
  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://maduromobile.web.app/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch website');
    }
  }

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
              // Modern Header with Glass Effect
              Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
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
                        Icons.info_outline_rounded,
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
                            "About Maduro",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "AI-Powered Fruit Detection",
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionCard(
                          icon: Icons.help_outline_rounded,
                          title: "What is Maduro?",
                          content:
                              "Maduro is an advanced fruit detection app that helps users determine the ripeness of fruits using AI and image processing. Whether you're a farmer, seller, or consumer, Maduro provides accurate ripeness detection for a better fruit experience.",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
                          ),
                        ),
                        _buildSectionCard(
                          icon: Icons.psychology_rounded,
                          title: "How Does It Work?",
                          content:
                              "• Capture or upload an image of a fruit\n• Maduro analyzes its ripeness using AI\n• Get instant results on whether it's ripe, overripe, or unripe",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFAED581), Color(0xFF9CCC65)],
                          ),
                        ),
                        _buildSectionCard(
                          icon: Icons.star_rounded,
                          title: "Why Choose Maduro?",
                          content:
                              "• AI-Powered Accuracy – Uses image processing and machine learning for precise ripeness detection\n• Easy to Use – Simple interface for quick scanning and results\n• Saves Money & Reduces Waste – Helps consumers buy ripe fruits and minimizes food waste",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDCE775), Color(0xFFD4E157)],
                          ),
                        ),
                        _buildSectionCard(
                          icon: Icons.rocket_launch_rounded,
                          title: "Our Mission",
                          content:
                              "We aim to revolutionize the way people assess fruit ripeness, ensuring better consumption choices and reducing food wastage globally.",
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F4C3), Color(0xFFE6EE9C)],
                          ),
                        ),
                        _buildContactCard(),
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required Gradient gradient,
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
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
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

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF81C784),
            Color(0xFFAED581),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.contact_support_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Contact Us",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "For support or inquiries, contact us at:\nmaduroapp@gmail.com",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildContactButton(
                icon: Icons.email_rounded,
                label: "Email",
                onTap: _launchEmail,
              ),
              const SizedBox(width: 12),
              _buildContactButton(
                icon: Icons.web_rounded,
                label: "Website",
                onTap: _launchWebsite,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
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
      ),
    );
  }
}
