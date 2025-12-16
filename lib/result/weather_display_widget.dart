import 'package:flutter/material.dart';
import 'weather_service.dart';

class WeatherDisplayCard extends StatelessWidget {
  final Future<WeatherData?> weatherFuture;

  const WeatherDisplayCard({super.key, required this.weatherFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData?>(
      future: weatherFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return _buildErrorCard('Weather unavailable');
        }

        final weather = snapshot.data!;
        return _buildWeatherCard(weather);
      },
    );
  }

  Widget _buildWeatherCard(WeatherData weather) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFA0C334), Color(0xFFE5D429)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.place, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Current Location',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF799620))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(weather.location,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF799620))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Temperature',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('${weather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF799620))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 2))
        ],
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Color(0xFFA0C334), strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Getting location...',
                style: TextStyle(
                    color: Color(0xFF799620),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(message,
            style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
