import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maduro/history/details_widget.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const HistoryDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final timestamp = data['timestamp']?.toDate();
    final formattedDate = timestamp != null
        ? DateFormat.yMMMd().add_jm().format(timestamp)
        : 'Unknown';

    final weatherData = data['weatherData'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildModernAppBar(title: 'DETAILS'),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernHeaderCard(data: data, formattedDate: formattedDate),
                  const SizedBox(height: 32),
                  ModernDetailsSection(data: data),
                  if (weatherData != null) ...[
                    const SizedBox(height: 32),
                    _buildWeatherSection(weatherData),
                  ],
                  const SizedBox(height: 32),
                  ModernRecommendationsSection(data: data),
                  const SizedBox(height: 32),
                  ModernNutritionButton(fruitName: data['fruit']),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Centered App Bar
  PreferredSize _buildModernAppBar({required String title}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB5DB49), Color(0xFFEAD938), Color(0xFFF5EE62)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.8,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Weather Section
  Widget _buildWeatherSection(Map<String, dynamic> weatherData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Conditions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.cyanAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildWeatherRow(
                Icons.location_on_rounded,
                'Location',
                weatherData['location']?.toString() ?? 'Unknown',
                Colors.blue,
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildWeatherStat(
                      Icons.thermostat_rounded,
                      'Temperature',
                      '${weatherData['temperature']?.toStringAsFixed(1) ?? 'N/A'}°C',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildWeatherStat(
                      Icons.water_drop_rounded,
                      'Humidity',
                      '${weatherData['humidity']?.toStringAsFixed(0) ?? 'N/A'}%',
                      Colors.cyan,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              _buildWeatherRow(
                Icons.wb_sunny_rounded,
                'Conditions',
                weatherData['conditionDescription']?.toString() ?? 'N/A',
                Colors.amber,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherStat(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
