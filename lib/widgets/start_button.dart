import 'package:flutter/material.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/detectionLandingPage');
      },
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          alignment: Alignment.center,
          child: const Text(
            'START DETECTING',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
