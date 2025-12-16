import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final double temperature;
  final double humidity;
  final String location;
  final DateTime timestamp;
  final String? windSpeed;
  final String? weatherDescription;
  final bool isFromCache;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.location,
    required this.timestamp,
    this.windSpeed,
    this.weatherDescription,
    this.isFromCache = false,
  });

  // Factory for WeatherAPI data (NEW)
  factory WeatherData.fromWeatherAPI(
      Map<String, dynamic> json, String locationName,
      {bool isFromCache = false}) {
    final current = json['current'];
    if (current == null) {
      throw Exception('No current weather data from WeatherAPI');
    }

    return WeatherData(
      temperature: (current['temp_c'] as num).toDouble(),
      humidity: (current['humidity'] as num).toDouble(),
      location: locationName,
      timestamp: DateTime.now(),
      windSpeed: "${current['wind_kph']} km/h",
      weatherDescription: current['condition']?['text'] ?? "Unknown",
      isFromCache: isFromCache,
    );
  }

  // Keep old factory for backward compatibility (FALLBACK)
  factory WeatherData.fromOpenMeteo(
      Map<String, dynamic> json, String locationName) {
    final current = json['current_weather'];
    if (current == null) {
      throw Exception('No current weather data');
    }

    double humidityValue = 50.0; // default
    try {
      if (json['hourly'] != null &&
          json['hourly']['relativehumidity_2m'] != null &&
          (json['hourly']['relativehumidity_2m'] as List).isNotEmpty) {
        humidityValue =
            (json['hourly']['relativehumidity_2m'][0] as num).toDouble();
      }
    } catch (_) {}

    String windSpeedStr = "";
    try {
      if (current['windspeed'] != null) {
        windSpeedStr = "${current['windspeed']} km/h";
      }
    } catch (_) {}

    return WeatherData(
      temperature: (current['temperature'] as num).toDouble(),
      humidity: humidityValue,
      location: locationName,
      timestamp: DateTime.now(),
      windSpeed: windSpeedStr,
      weatherDescription: _getWeatherDescription(current['weathercode']),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'windSpeed': windSpeed,
      'weatherDescription': weatherDescription,
    };
  }

  // Create from JSON
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature'],
      humidity: json['humidity'],
      location: json['location'],
      timestamp: DateTime.parse(json['timestamp']),
      windSpeed: json['windSpeed'],
      weatherDescription: json['weatherDescription'],
      isFromCache: true,
    );
  }

  static String _getWeatherDescription(dynamic weatherCode) {
    if (weatherCode == null) return "Clear";

    final code = weatherCode as int;
    switch (code) {
      case 0:
        return "Clear sky";
      case 1:
      case 2:
      case 3:
        return "Partly cloudy";
      case 45:
      case 48:
        return "Foggy";
      case 51:
      case 53:
      case 55:
        return "Light rain";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 80:
      case 81:
      case 82:
        return "Heavy rain";
      default:
        return "Variable conditions";
    }
  }

  String get conditionDescription {
    if (temperature > 30 && humidity > 80) return "Hot and humid";
    if (temperature > 30) return "Hot and dry";
    if (temperature < 15 && humidity < 60) return "Cool and dry";
    if (temperature < 15) return "Cool and humid";
    if (humidity > 85) return "Warm and humid";
    if (humidity < 60) return "Warm and dry";
    return "Moderate conditions";
  }

  String get businessImpactSummary {
    String impact = "";

    if (temperature > 28) {
      impact += "HIGH RISK - Hot weather accelerates ripening. ";
    } else if (temperature < 18) {
      impact += "LOW RISK - Cool weather extends shelf life. ";
    }

    if (humidity > 85) {
      impact += "Monitor for mold/spoilage. ";
    } else if (humidity < 60) {
      impact += "Dry conditions may cause skin darkening. ";
    }

    return impact.isEmpty
        ? "Favorable conditions for banana storage."
        : impact.trim();
  }

  // Get time since data was fetched
  String getDataAge() {
    final age = DateTime.now().difference(timestamp);
    if (age.inMinutes < 1) return "Just now";
    if (age.inMinutes < 60) return "${age.inMinutes} min ago";
    if (age.inHours < 24) return "${age.inHours} hr ago";
    return "${age.inDays} days ago";
  }
}

class BananaRipeningCalculator {
  // Enhanced calculation with more precise business logic
  static double getRipeningSpeedFactor(double temperature, double humidity) {
    double tempFactor = 1.0;
    double humidityFactor = 1.0;

    // More granular temperature factors for business precision
    if (temperature < 13) {
      tempFactor = 0.3; // Very slow - long storage possible
    } else if (temperature < 16) {
      tempFactor = 0.5; // Slow - extended wholesale window
    } else if (temperature < 20) {
      tempFactor = 0.7; // Moderate - normal business cycle
    } else if (temperature >= 20 && temperature <= 24) {
      tempFactor = 1.0; // Optimal - standard timing
    } else if (temperature <= 27) {
      tempFactor = 1.3; // Fast - quick turnover needed
    } else if (temperature <= 30) {
      tempFactor = 1.8; // Very fast - urgent sales
    } else {
      tempFactor = 2.5; // Critical - immediate action required
    }

    // Enhanced humidity factors
    if (humidity < 50) {
      humidityFactor =
          0.6; // Dry conditions slow ripening but may cause skin issues
    } else if (humidity < 70) {
      humidityFactor = 0.8; // Moderate humidity
    } else if (humidity >= 70 && humidity <= 85) {
      humidityFactor = 1.0; // Optimal humidity range
    } else if (humidity <= 95) {
      humidityFactor = 1.3; // High humidity increases spoilage risk
    } else {
      humidityFactor = 1.6; // Very high - mold risk
    }

    return tempFactor * humidityFactor;
  }

  static Map<String, dynamic> getDetailedEstimates(
      String currentRipeness, double temperature, double humidity) {
    // Base days for different ripeness levels (at optimal 22°C, 75% humidity)
    Map<String, Map<String, int>> baseData = {
      'green': {'toRipe': 10, 'toSpoil': 16},
      'unripe': {'toRipe': 7, 'toSpoil': 12},
      'slightly ripe': {'toRipe': 4, 'toSpoil': 8},
      'ripe': {'toRipe': 0, 'toSpoil': 5}, // Changed from 4 to 5
      'very ripe': {'toRipe': 0, 'toSpoil': 3}, // Added new stage
      'overripe': {'toRipe': 0, 'toSpoil': 2},
      'rotten': {'toRipe': 0, 'toSpoil': 0},
    };

    String normalizedRipeness = currentRipeness.toLowerCase();
    Map<String, int> base =
        baseData[normalizedRipeness] ?? {'toRipe': 5, 'toSpoil': 8};

    double speedFactor = getRipeningSpeedFactor(temperature, humidity);

    int daysToRipe = base['toRipe'] == 0
        ? 0
        : (base['toRipe']! / speedFactor).round().clamp(0, 15);

    // Enhanced spoilage calculation with more sensitivity to conditions
    int daysToSpoil;
    if (base['toSpoil'] == 0) {
      daysToSpoil = 0;
    } else {
      // Apply speed factor more aggressively for ripe bananas
      double spoilageFactor = speedFactor;
      if (normalizedRipeness == 'ripe' || normalizedRipeness == 'very ripe') {
        spoilageFactor *= 1.3; // Ripe bananas are more sensitive
      }
      if (normalizedRipeness == 'overripe') {
        spoilageFactor *= 1.5; // Overripe even more sensitive
      }

      daysToSpoil = (base['toSpoil']! / spoilageFactor).round().clamp(1, 20);
    }

    // Business urgency levels
    String urgencyLevel = _getUrgencyLevel(daysToSpoil);
    String businessAction =
        _getBusinessAction(daysToRipe, daysToSpoil, normalizedRipeness);
    String priceStrategy = _getPriceStrategy(daysToSpoil, speedFactor);
    String storageAdvice =
        _getEnhancedStorageAdvice(temperature, humidity, speedFactor);

    return {
      'daysToRipe': daysToRipe,
      'daysToSpoil': daysToSpoil,
      'speedFactor': speedFactor,
      'urgencyLevel': urgencyLevel,
      'businessAction': businessAction,
      'priceStrategy': priceStrategy,
      'storageAdvice': storageAdvice,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  static String _getUrgencyLevel(int daysToSpoil) {
    if (daysToSpoil <= 1) return "CRITICAL";
    if (daysToSpoil <= 3) return "HIGH";
    if (daysToSpoil <= 7) return "MODERATE";
    return "LOW";
  }

  static String _getBusinessAction(
      int daysToRipe, int daysToSpoil, String ripeness) {
    if (daysToSpoil <= 1) {
      return "IMMEDIATE ACTION: Sell at discount to juice bars, bakeries, or processing facilities. Consider 30-50% discount.";
    }

    if (daysToSpoil <= 3) {
      return "QUICK SALE: Target restaurants, cafes, and ready-to-eat markets. Offer 15-25% discount to move inventory.";
    }

    if (daysToRipe <= 2 && daysToSpoil >= 4) {
      return "PREMIUM PRICING: Perfect for retail customers wanting ready-to-eat fruit. Market as 'ready now' with premium pricing.";
    }

    if (daysToRipe <= 5) {
      return "STANDARD RETAIL: Ideal for grocery stores and supermarkets with normal turnover. Standard pricing applies.";
    }

    return "WHOLESALE OPPORTUNITY: Perfect for distributors, export, or bulk sales. Extended shelf life allows for logistics flexibility.";
  }

  static String _getPriceStrategy(int daysToSpoil, double speedFactor) {
    if (speedFactor > 2.0) {
      return "DYNAMIC PRICING: Reduce prices daily as conditions accelerate ripening. Start with 10% discount, increase 5% per day.";
    }

    if (daysToSpoil <= 3) {
      return "DISCOUNT PRICING: 20-40% below standard rate to ensure quick turnover.";
    }

    if (daysToSpoil >= 10) {
      return "PREMIUM PRICING: Charge 10-15% above standard for extended shelf life value.";
    }

    return "STANDARD PRICING: Normal market rates apply with stable conditions.";
  }

  static String _getEnhancedStorageAdvice(
      double temperature, double humidity, double speedFactor) {
    List<String> advice = [];

    // Temperature advice
    if (temperature > 30) {
      advice.add(
          "URGENT: Use air conditioning or move to coolest area immediately");
      advice.add("Separate ripe bananas to prevent ethylene acceleration");
      advice.add("Increase inspection frequency to twice daily");
    } else if (temperature > 27) {
      advice.add("Use fans for air circulation, avoid direct heat");
      advice
          .add("Monitor ripening acceleration, expect 50% faster than normal");
    } else if (temperature < 16) {
      advice.add("Move to warmer area if possible (18-24°C ideal)");
      advice.add("Group bananas together for warmth, cover during cold nights");
    }

    // Humidity advice
    if (humidity > 90) {
      advice.add(
          "CRITICAL: Install dehumidifier or improve ventilation immediately");
      advice.add("Space bananas apart to prevent moisture buildup and mold");
      advice.add("Check daily for black spots or unusual softening");
    } else if (humidity > 85) {
      advice.add("Increase air circulation with fans");
      advice.add("Avoid stacking bananas densely");
    } else if (humidity < 60) {
      advice.add("Protect from direct AC/heating vents");
      advice.add(
          "Consider light misting of storage area (not directly on fruit)");
    }

    // Speed factor advice
    if (speedFactor > 1.8) {
      advice.add(
          "BUSINESS ALERT: Ripening 80%+ faster than normal - adjust sales strategy");
      advice.add(
          "Consider splitting inventory: sell some now, store rest in cooler conditions");
    } else if (speedFactor < 0.7) {
      advice.add("Extended storage possible - good for inventory buildup");
      advice.add("Monitor for skin darkening in very dry conditions");
    }

    return "${advice.join(". ")}.";
  }

  // Legacy methods for backward compatibility
  static int estimateDaysToRipe(
      String currentRipeness, double temperature, double humidity) {
    final estimates =
        getDetailedEstimates(currentRipeness, temperature, humidity);
    return estimates['daysToRipe'];
  }

  static int estimateDaysToSpoil(
      String currentRipeness, double temperature, double humidity) {
    final estimates =
        getDetailedEstimates(currentRipeness, temperature, humidity);
    return estimates['daysToSpoil'];
  }

  static String getStorageAdvice(double temperature, double humidity) {
    double speedFactor = getRipeningSpeedFactor(temperature, humidity);
    return _getEnhancedStorageAdvice(temperature, humidity, speedFactor);
  }
}

class WeatherService {
  // WeatherAPI configuration
  static const String _weatherApiKey = '49e960c9ae524e96896140516250910';
  static const String _weatherApiBaseUrl = 'https://api.weatherapi.com/v1';

  // Cache keys for SharedPreferences
  static const String _lastWeatherDataKey = 'last_weather_data';
  static const String _lastLocationKey = 'last_location_name';

  // Memory cache for location names
  final Map<String, String> _locationCache = {};
  DateTime? _lastLocationFetch;
  static const Duration _cacheExpiry = Duration(hours: 6);

  /// Main method to get current weather with fallback to cached data
  Future<WeatherData?> getCurrentWeather() async {
    try {
      // Get current position using Geolocator
      Position position = await _getCurrentPosition();

      // Create cache key from rounded coordinates (to ~1km precision)
      String cacheKey =
          '${position.latitude.toStringAsFixed(2)},${position.longitude.toStringAsFixed(2)}';

      // Check if we have a cached location name
      String locationName;
      if (_locationCache.containsKey(cacheKey) &&
          _lastLocationFetch != null &&
          DateTime.now().difference(_lastLocationFetch!) < _cacheExpiry) {
        locationName = _locationCache[cacheKey]!;
        debugPrint('Using cached location: $locationName');
      } else {
        // Fetch new location name
        locationName =
            await _getLocationName(position.latitude, position.longitude);
        _locationCache[cacheKey] = locationName;
        _lastLocationFetch = DateTime.now();

        // Save location to persistent storage
        await _saveLocationToDisk(locationName);
        debugPrint('Fetched new location: $locationName');
      }

      // Get accurate temperature and humidity from WeatherAPI
      final url =
          '$_weatherApiBaseUrl/current.json?key=$_weatherApiKey&q=${position.latitude},${position.longitude}&aqi=no';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherData = WeatherData.fromWeatherAPI(data, locationName);

        // Save successful weather data to disk
        await _saveWeatherDataToDisk(weatherData);

        return weatherData;
      } else {
        debugPrint('WeatherAPI error: ${response.statusCode}');
        // Try to load cached data on API error
        return await _loadCachedWeatherData();
      }
    } catch (e) {
      debugPrint('Weather fetch error: $e');
      // Try to load cached data on any error
      return await _loadCachedWeatherData();
    }
  }

  /// Save weather data to persistent storage
  Future<void> _saveWeatherDataToDisk(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data.toJson());
      await prefs.setString(_lastWeatherDataKey, jsonString);
      debugPrint('Weather data saved to disk');
    } catch (e) {
      debugPrint('Error saving weather data: $e');
    }
  }

  /// Save location name to persistent storage
  Future<void> _saveLocationToDisk(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLocationKey, location);
      debugPrint('Location saved to disk: $location');
    } catch (e) {
      debugPrint('Error saving location: $e');
    }
  }

  /// Load cached weather data from persistent storage
  Future<WeatherData?> _loadCachedWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_lastWeatherDataKey);

      if (jsonString != null) {
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final cachedData = WeatherData.fromJson(jsonData);

        // Check if cached data is not too old (e.g., less than 24 hours)
        final age = DateTime.now().difference(cachedData.timestamp);
        if (age.inHours < 24) {
          debugPrint(
              'Loaded cached weather data from ${cachedData.getDataAge()}');
          return cachedData;
        } else {
          debugPrint('Cached data too old (${age.inHours} hours), not using');
        }
      }
    } catch (e) {
      debugPrint('Error loading cached weather data: $e');
    }
    return null;
  }

  /// Load last known location from persistent storage
  Future<String?> _loadCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLocationKey);
    } catch (e) {
      debugPrint('Error loading cached location: $e');
      return null;
    }
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services disabled');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      timeLimit: const Duration(seconds: 10),
    );
  }

  Future<String> _getLocationName(double lat, double lon) async {
    try {
      // Add a small delay to respect Nominatim's rate limit (1 req/sec)
      await Future.delayed(const Duration(milliseconds: 1100));

      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=10&accept-language=en'),
        headers: {
          'User-Agent': 'BananaRipenessApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if we got valid address data
        if (data['address'] != null) {
          final address = data['address'];

          // Try multiple location name combinations
          String? city = address['city'] ??
              address['municipality'] ??
              address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['district'] ??
              address['county'];

          String? state =
              address['state'] ?? address['province'] ?? address['region'];

          String? country = address['country'];

          // Build location name with available parts
          List<String> parts = [];
          if (city != null && city.isNotEmpty) parts.add(city);
          if (state != null && state.isNotEmpty && state != city)
            parts.add(state);
          if (country != null && country.isNotEmpty) parts.add(country);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        // Fallback to display_name if address parsing fails
        if (data['display_name'] != null &&
            data['display_name'].toString().isNotEmpty) {
          List<String> parts = data['display_name'].toString().split(', ');
          // Take up to 3 meaningful parts, avoiding overly long names
          return parts.take(3).where((s) => s.isNotEmpty).join(', ');
        }
      } else {
        debugPrint('Nominatim returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');

      // Try to load last known location from disk
      final cachedLocation = await _loadCachedLocation();
      if (cachedLocation != null) {
        debugPrint('Using last known location from cache: $cachedLocation');
        return cachedLocation;
      }
    }

    // Final fallback: formatted coordinates with region hint
    return _formatCoordinatesWithRegion(lat, lon);
  }

  // Helper method to format coordinates with regional context
  String _formatCoordinatesWithRegion(double lat, double lon) {
    String region = _getGeneralRegion(lat, lon);
    return '$region (${lat.toStringAsFixed(2)}°, ${lon.toStringAsFixed(2)}°)';
  }

  // Helper to give users context even when exact location fails
  String _getGeneralRegion(double lat, double lon) {
    // Philippines region
    if (lat >= 4.5 && lat <= 21.5 && lon >= 116 && lon <= 127) {
      if (lat >= 14 && lat <= 15 && lon >= 120.5 && lon <= 121.5) {
        return 'Metro Manila Area';
      }
      return 'Philippines';
    }

    // Southeast Asia
    if (lat >= -10 && lat <= 28 && lon >= 92 && lon <= 141) {
      return 'Southeast Asia';
    }

    // General hemispheres
    String ns = lat >= 0 ? 'Northern' : 'Southern';
    String ew = lon >= 0 ? 'Eastern' : 'Western';

    return '$ns $ew Region';
  }

  // Enhanced business insight generation
  String generateComprehensiveBusinessInsight(
      String ripeness, WeatherData weather) {
    final estimates = BananaRipeningCalculator.getDetailedEstimates(
        ripeness, weather.temperature, weather.humidity);

    String insight = "";

    // Add cache indicator if data is from cache
    if (weather.isFromCache) {
      insight += "⚠️ Using cached data (${weather.getDataAge()})\n\n";
    }

    insight +=
        "📍 ${weather.location}: ${weather.temperature.toStringAsFixed(1)}°C, "
        "${weather.humidity.toStringAsFixed(0)}% humidity\n\n";

    insight += "⏱️ TIMING ESTIMATES:\n";
    if (estimates['daysToRipe'] > 0) {
      insight += "• Ripeness: ${estimates['daysToRipe']} days\n";
    }
    insight +=
        "• Shelf life: ${estimates['daysToSpoil']} days (${estimates['urgencyLevel']} priority)\n\n";

    insight += "💼 BUSINESS STRATEGY:\n";
    insight += "• ${estimates['businessAction']}\n";
    insight += "• ${estimates['priceStrategy']}\n\n";

    insight += "🏪 STORAGE REQUIREMENTS:\n";
    insight += "• ${estimates['storageAdvice']}\n\n";

    insight += "📈 CONDITIONS IMPACT:\n";
    insight +=
        "• Ripening speed: ${estimates['speedFactor'].toStringAsFixed(1)}x normal rate\n";
    insight += "• ${weather.businessImpactSummary}";

    return insight;
  }
}
