// business_helper.dart - Simple business decision helper
import 'package:flutter/material.dart';
import 'weather_service.dart';

class BusinessWeatherHelper {
  /// Provides simple, actionable business advice based on weather and ripeness
  static Map<String, dynamic> getBusinessAdvice({
    required String ripeness,
    required WeatherData weather,
  }) {
    final estimates = BananaRipeningCalculator.getDetailedEstimates(
        ripeness, weather.temperature, weather.humidity);

    return {
      'timeToRipe': _formatTimeToRipe(estimates['daysToRipe']),
      'timeToSpoil': _formatTimeToSpoil(
          estimates['daysToSpoil'], estimates['urgencyLevel']),
      'quickAction': _getQuickAction(estimates),
      'priceAdvice': _getPriceAdvice(estimates),
      'storageAdvice': _getSimpleStorageAdvice(weather),
      'customerTarget':
          _getCustomerTarget(estimates['daysToRipe'], estimates['daysToSpoil']),
      'weatherImpact': _getWeatherImpact(weather, estimates['speedFactor']),
    };
  }

  static String _formatTimeToRipe(int days) {
    if (days == 0) return "Already ripe - ready to sell now";
    if (days == 1) return "1 day - will be perfect tomorrow";
    if (days <= 3) return "$days days - ready very soon";
    if (days <= 7) return "$days days - good timing for weekly sales";
    return "$days days - long-term inventory suitable";
  }

  static String _formatTimeToSpoil(int days, String urgency) {
    String timeline = "";
    if (days == 0) {
      timeline = "Critical - spoiling today";
    } else if (days == 1)
      timeline = "1 day left - sell immediately";
    else if (days <= 3)
      timeline = "$days days - quick sale needed";
    else if (days <= 7)
      timeline = "$days days - normal timeline";
    else
      timeline = "$days days - good shelf life";

    String urgencyText = "";
    switch (urgency) {
      case "CRITICAL":
        urgencyText = " ⚠️ URGENT ACTION REQUIRED";
        break;
      case "HIGH":
        urgencyText = " ⚡ High priority";
        break;
      case "MODERATE":
        urgencyText = " 📅 Plan accordingly";
        break;
      default:
        urgencyText = " ✅ No rush";
        break;
    }

    return "$timeline$urgencyText";
  }

  static String _getQuickAction(Map<String, dynamic> estimates) {
    int daysToSpoil = estimates['daysToSpoil'];

    if (daysToSpoil <= 1) {
      return "Sell today at 30-50% discount to juice bars, bakeries, or for smoothies";
    }

    if (daysToSpoil <= 3) {
      return "Quick sale to restaurants, cafes. Offer 15-20% discount";
    }

    if (daysToSpoil <= 7) {
      return "Normal retail sales. Market to grocery stores and consumers";
    }

    return "Perfect for wholesale, export, or bulk orders. Premium quality";
  }

  static String _getPriceAdvice(Map<String, dynamic> estimates) {
    int daysToSpoil = estimates['daysToSpoil'];
    double speedFactor = estimates['speedFactor'];

    if (speedFactor > 2.0) {
      return "Hot weather pricing: Start 10% off, reduce 5% daily";
    }

    if (daysToSpoil <= 3) {
      return "Quick sale pricing: 20-30% below normal rates";
    }

    if (daysToSpoil >= 10) {
      return "Premium pricing: Charge 10-15% extra for extended freshness";
    }

    return "Standard market pricing applies";
  }

  static String _getSimpleStorageAdvice(WeatherData weather) {
    List<String> tips = [];

    if (weather.temperature > 28) {
      tips.add("Too hot! Use AC or fans, avoid sunlight");
    } else if (weather.temperature < 18) {
      tips.add("Too cool - move to warmer area (20-24°C ideal)");
    } else {
      tips.add("Good temperature - maintain current storage");
    }

    if (weather.humidity > 85) {
      tips.add("Too humid - use fans, space out bananas");
    } else if (weather.humidity < 65) {
      tips.add("Dry air - protect from direct AC/heating");
    } else {
      tips.add("Good humidity levels");
    }

    return tips.join(". ");
  }

  static String _getCustomerTarget(int daysToRipe, int daysToSpoil) {
    if (daysToSpoil <= 1) {
      return "Juice bars, smoothie shops, bakeries (for banana bread)";
    }

    if (daysToRipe <= 1) {
      return "Consumers wanting ready-to-eat fruit, fruit stands";
    }

    if (daysToRipe <= 3) {
      return "Restaurants, cafes, grocery stores with quick turnover";
    }

    if (daysToRipe <= 7) {
      return "Supermarkets, retail chains, regular grocery stores";
    }

    return "Wholesalers, distributors, export companies";
  }

  static String _getWeatherImpact(WeatherData weather, double speedFactor) {
    String impact = "";

    if (speedFactor > 1.8) {
      impact = "Weather is making bananas ripen 80% faster than normal";
    } else if (speedFactor > 1.3) {
      impact = "Weather is accelerating ripening - watch closely";
    } else if (speedFactor < 0.8) {
      impact = "Weather is slowing ripening - extended storage possible";
    } else {
      impact = "Weather conditions are normal for banana storage";
    }

    // Add temperature context
    if (weather.temperature > 30) {
      impact += ". Very hot - check twice daily";
    } else if (weather.temperature < 15) {
      impact += ". Cold weather - slower sales cycle expected";
    }

    // Add humidity context
    if (weather.humidity > 90) {
      impact += ". High humidity - watch for mold";
    }

    return impact;
  }
}

// Simple widget to display business advice
class BusinessAdviceCard extends StatelessWidget {
  final String ripeness;
  final WeatherData weather;

  const BusinessAdviceCard({
    super.key,
    required this.ripeness,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final advice = BusinessWeatherHelper.getBusinessAdvice(
      ripeness: ripeness,
      weather: weather,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.business_center,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Business Quick Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdviceItem(
            icon: Icons.schedule,
            title: 'Time to Sell',
            content: advice['timeToSpoil'],
            isUrgent: advice['timeToSpoil'].toString().contains('URGENT') ||
                advice['timeToSpoil'].toString().contains('Critical'),
          ),
          _buildAdviceItem(
            icon: Icons.flash_on,
            title: 'Quick Action',
            content: advice['quickAction'],
          ),
          _buildAdviceItem(
            icon: Icons.attach_money,
            title: 'Pricing Strategy',
            content: advice['priceAdvice'],
          ),
          _buildAdviceItem(
            icon: Icons.people,
            title: 'Target Customers',
            content: advice['customerTarget'],
          ),
          _buildAdviceItem(
            icon: Icons.storage,
            title: 'Storage Tips',
            content: advice['storageAdvice'],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              advice['weatherImpact'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem({
    required IconData icon,
    required String title,
    required String content,
    bool isUrgent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isUrgent ? Colors.red.shade700 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isUrgent ? Colors.red.shade800 : Colors.black87,
                    fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
