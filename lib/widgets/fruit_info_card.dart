import 'package:flutter/material.dart';

class FruitInfoCard extends StatelessWidget {
  const FruitInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fruit Information and Characteristics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Ripeness Status', '85%'),
        _buildInfoRow('Estimated Time to Full Ripeness', '2 Days'),
        _buildInfoRow('Color Assessment', 'Yellow with green patches'),
        _buildInfoRow('Diameter', '10 cm'),
        _buildInfoRow('Shape', 'Round'),
        _buildInfoRow('Texture', 'Smooth'),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
