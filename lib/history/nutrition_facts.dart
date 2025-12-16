// nutrition_facts.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class NutritionFactsScreen extends StatefulWidget {
  final String fruitName;
  final String?
      userId; // Make userId nullable if it might not be immediately available

  const NutritionFactsScreen({super.key, required this.fruitName, this.userId});

  @override
  State<NutritionFactsScreen> createState() => _NutritionFactsScreenState();
}

class _NutritionFactsScreenState extends State<NutritionFactsScreen> {
  Map<String, dynamic>? nutritionData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNutritionFacts(); // Automatically load when the screen opens
  }

  Future<void> _loadNutritionFacts() async {
    setState(() {
      isLoading = true;
    });

    // Get the current authenticated user's UID
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      debugPrint(
          'Error: No authenticated user found. Cannot fetch nutrition facts.');
      setState(() {
        nutritionData = null;
        isLoading = false;
      });
      // You should handle this case, perhaps by navigating to a login screen
      return;
    }

    // Use the authenticated user's UID for the query
    final String authenticatedUserId = currentUser.uid;

    debugPrint('Fetching nutrition for:');
    debugPrint('   Fruit: ${widget.fruitName}');
    debugPrint('   User ID (from auth): $authenticatedUserId');

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('history')
          .where('userId',
              isEqualTo:
                  authenticatedUserId) // <--- CRITICAL FIX: Use authenticatedUserId
          .where('fruit', isEqualTo: widget.fruitName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        debugPrint('Found document data: $data');
        setState(() {
          nutritionData = data['nutritionFacts'] ?? {};
        });
        debugPrint('Nutrition data assigned: $nutritionData');
      } else {
        setState(() {
          nutritionData = null;
        });
        debugPrint(
            'No nutrition facts found for ${widget.fruitName} with userId $authenticatedUserId.');
      }
    } catch (e) {
      debugPrint('Error fetching nutrition facts: $e');
      setState(() {
        nutritionData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildNutrientRow(String nutrient, String value,
      {TextStyle? style, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nutrient,
            style: style ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            value,
            style: style ??
                TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndentedNutrientRow(String nutrient, String value,
      {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 2.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: style ?? const TextStyle(fontSize: 15)),
          Text(value, style: style ?? const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildNutritionFactsLabel() {
    if (nutritionData == null || nutritionData!.isEmpty) {
      return const Center(
          child: Text('No nutrition data available. Please load data.'));
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Facts for ${widget.fruitName}',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          const Divider(color: Colors.black, thickness: 8.0),
          _buildNutrientRow('Serving Size', '100g'),
          const Divider(color: Colors.black, thickness: 1.0),
          const Text('Amount Per Serving',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildNutrientRow('Calories', nutritionData!['Calories'] ?? 'N/A',
              isBold: true),
          const Divider(color: Colors.black, thickness: 5.0),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('% Daily Value*',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.black, thickness: 1.0),
          _buildNutrientRow('Total Fat', nutritionData!['Total Fat'] ?? 'N/A',
              isBold: true),
          _buildIndentedNutrientRow(
              'Saturated Fat', nutritionData!['Saturated Fat'] ?? 'N/A'),
          _buildIndentedNutrientRow(
              'Trans Fat', nutritionData!['Trans Fat'] ?? 'N/A'),
          _buildNutrientRow(
              'Cholesterol', nutritionData!['Cholesterol'] ?? 'N/A',
              isBold: true),
          _buildNutrientRow('Sodium', nutritionData!['Sodium'] ?? 'N/A',
              isBold: true),
          _buildNutrientRow('Total Carbohydrate',
              nutritionData!['Total Carbohydrate'] ?? 'N/A',
              isBold: true),
          _buildIndentedNutrientRow(
              'Dietary Fiber', nutritionData!['Dietary Fiber'] ?? 'N/A'),
          _buildIndentedNutrientRow(
              'Total Sugars', nutritionData!['Total Sugars'] ?? 'N/A'),
          _buildIndentedNutrientRow('Includes Added Sugars',
              nutritionData!['Includes Added Sugars'] ?? 'N/A'),
          _buildNutrientRow('Protein', nutritionData!['Protein'] ?? 'N/A',
              isBold: true),
          const Divider(color: Colors.black, thickness: 5.0),
          _buildNutrientRow('Vitamin D', nutritionData!['Vitamin D'] ?? 'N/A'),
          _buildNutrientRow('Calcium', nutritionData!['Calcium'] ?? 'N/A'),
          _buildNutrientRow('Iron', nutritionData!['Iron'] ?? 'N/A'),
          _buildNutrientRow('Potassium', nutritionData!['Potassium'] ?? 'N/A'),
          const Divider(color: Colors.black, thickness: 1.0),
          const Text(
            '* The % Daily Value (DV) tells you how much a nutrient in a serving of food contributes to a daily diet. 2,000 calories a day is used for general nutrition advice.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : _buildNutritionFactsLabel(),
            ],
          ),
        ),
      ),
    );
  }
}
