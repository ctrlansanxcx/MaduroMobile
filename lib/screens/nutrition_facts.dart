import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NutritionFactsWidget extends StatefulWidget {
  final String fruitName;

  const NutritionFactsWidget({super.key, required this.fruitName});

  @override
  State<NutritionFactsWidget> createState() => _NutritionFactsWidgetState();
}

class _NutritionFactsWidgetState extends State<NutritionFactsWidget> {
  Map<String, dynamic>? _nutritionData;
  bool _loading = false;

  final String apiKey =
      'YOUR_API_KEY_HERE'; // Replace with your CalorieNinjas API key

  @override
  void initState() {
    super.initState();
    fetchNutritionFacts(widget.fruitName.toLowerCase());
  }

  Future<void> fetchNutritionFacts(String query) async {
    setState(() {
      _loading = true;
      _nutritionData = null;
    });

    final response = await http.get(
      Uri.parse('https://api.calorieninjas.com/v1/nutrition?query=$query'),
      headers: {'X-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'];
      if (items.isNotEmpty) {
        setState(() {
          _nutritionData = items.first;
        });
      } else {
        setState(() {
          _nutritionData = {'name': 'Not Found'};
        });
      }
    } else {
      setState(() {
        _nutritionData = {'name': 'Error fetching data'};
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nutritionData == null) {
      return const Text("No data found.");
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _nutritionData!['name'] ?? 'Food Item',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 3, color: Colors.black),
          const Text('Serving size approx. 100g',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(thickness: 3, color: Colors.black),
          _buildBoldRow('Calories', _nutritionData!['calories'].toString()),
          const Divider(thickness: 1, color: Colors.black),
          _buildInfoRow('Total Fat', '${_nutritionData!['fat_total_g']}g'),
          _buildIndentedRow(
              'Saturated Fat', '${_nutritionData!['fat_saturated_g']}g'),
          _buildInfoRow(
              'Cholesterol', '${_nutritionData!['cholesterol_mg']}mg'),
          _buildInfoRow('Sodium', '${_nutritionData!['sodium_mg']}mg'),
          _buildInfoRow('Total Carbohydrate',
              '${_nutritionData!['carbohydrates_total_g']}g'),
          _buildIndentedRow('Sugar', '${_nutritionData!['sugar_g']}g'),
          _buildInfoRow('Protein', '${_nutritionData!['protein_g']}g'),
          _buildInfoRow('Fiber', '${_nutritionData!['fiber_g']}g'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [String dv = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 14)),
              if (dv.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(dv, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoldRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildIndentedRow(String label, String value, [String dv = '']) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 2.0, bottom: 2.0),
      child: _buildInfoRow(label, value, dv),
    );
  }
}
