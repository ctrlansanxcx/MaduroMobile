import 'package:flutter/material.dart';

class NutritionButton extends StatelessWidget {
  const NutritionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity, // Makes the button take full width
        height: 50, // Ensures a proper touch area
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/nutrition');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600], // A fresh green color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 14), // Comfortable padding
          ),
          child: const Text(
            'View Nutrition Facts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Ensures text contrast
            ),
          ),
        ),
      ),
    );
  }
}
