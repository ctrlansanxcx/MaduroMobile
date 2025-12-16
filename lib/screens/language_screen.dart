import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

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
                        Icons.language, // Keep original icon
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
                            "Language", // Keep original title
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Choose your preferred language", // Keep original subtitle
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
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Align for the 'Current Selection' text
                      children: [
                        // Current selection indicator - Styled to fit
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF90EE90).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF90EE90).withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            "Current Selection",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A7C59),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Language Options
                        _buildLanguageOption(
                          context,
                          icon: "🇺🇸",
                          language: "English",
                          subtitle: "English (US)",
                          isSelected: true,
                          onTap: () {},
                        ),
                        /*
                        const SizedBox(height: 16),
                        _buildLanguageOption(
                          context,
                          icon: "🇵🇭",
                          language: "Filipino",
                          subtitle: "Tagalog (PH)",
                          isSelected: false,
                          onTap: () {},
                        ),
                        */
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

  Widget _buildLanguageOption(
    BuildContext context, {
    required String icon,
    required String language,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0F4C3)
                  .withOpacity(0.6) // Adjusted selected color
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFB5DB49) // Adjusted selected border color
                : Colors.grey.shade200, // Adjusted unselected border color
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFB5DB49)
                      .withOpacity(0.2) // Adjusted selected shadow
                  : Colors.grey.withOpacity(0.08), // Adjusted unselected shadow
              blurRadius: isSelected ? 12 : 15, // Adjusted blur radius
              offset: isSelected
                  ? const Offset(0, 4)
                  : const Offset(0, 5), // Adjusted offset
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag emoji container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  // Added gradient to icon container
                  colors: [Color(0xFF81C784), Color(0xFFB5DB49)],
                ),
                borderRadius: BorderRadius.circular(15),
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
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold, // Bold like privacy policy titles
                      color: const Color(
                          0xFF2E7D32), // Color like privacy policy titles
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15, // Slightly larger
                      color: Colors.grey.shade700, // Darker grey
                      height: 1.5, // Line height
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF81C784),
                      Color(0xFFAED581)
                    ], // Green gradient
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
