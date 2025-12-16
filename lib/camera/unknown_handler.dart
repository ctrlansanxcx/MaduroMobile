import 'package:flutter/material.dart';

class UnknownFruitPage extends StatelessWidget {
  final String? message; // Optional message to display

  const UnknownFruitPage({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the display message
    final String displayMessage = message ??
        "The detected object could not be identified as a known fruit or item.";

    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background
      appBar: AppBar(
        title: const Text("Detection Result"),
        backgroundColor: const Color(0xFFA0C334), // Theme color from your app
        automaticallyImplyLeading:
            true, // Show back button if part of navigation stack
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons
                    .search_off_rounded, // Icon indicating something was not found
                size: 80,
                color: Colors.orange.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                "Unknown Object",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                displayMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA0C334), // Theme color
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Fallback: if it's the only page in stack, go to a known landing page
                    if (ModalRoute.of(context)?.settings.name !=
                        '/detectionLandingPage') {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/detectionLandingPage', (route) => false);
                    }
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new),
                label: const Text("Try Again or Go Back"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (ModalRoute.of(context)?.settings.name !=
                      '/detectionLandingPage') {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/detectionLandingPage', (route) => false);
                  }
                },
                child: Text(
                  "Return to Home",
                  style: TextStyle(
                    color: Colors.orange.shade300,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
