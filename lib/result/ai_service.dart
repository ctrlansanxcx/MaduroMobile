// ai_service.dart - Enhanced with comprehensive weather-based business insights
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'weather_service.dart';

// Constants for the keys used in the returned map
const String keyEstimatedTime = 'estimatedTime';
const String keyEstimatedSpoil = 'estimatedTimeToSpoil';
const String keyQualityGrade = 'qualityGrade';
const String keyProperStorage = 'properStorage';

const List<String> insightTitles = [
  "Estimated Time to Ripeness:",
  "Estimated Time to Spoil:",
  "Quality Grading:",
  "Storage and Sorting:",
];

class AIInsightsService {
  final String apiKey;
  final String modelName;
  late final GenerativeModel? _model;

  AIInsightsService({
    String? apiKey,
    this.modelName = 'gemini-2.5-flash',
  }) : apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '' {
    if (this.apiKey.isEmpty) {
      _model = null;
      print(
          "Warning: Gemini API Key is not set. AIInsightsService will not function.");
    } else {
      _model = GenerativeModel(model: modelName, apiKey: this.apiKey);
    }
  }

  bool get isConfigured => _model != null;

  Future<Map<String, String>> fetchInsights({
    required File imageFile,
    required String fruit,
    required String ripeness,
    required Map<String, dynamic> confidenceScores,
    required Map<String, dynamic> imageDimensions,
    required List<String> selectedInsightKeys,
    WeatherData? weatherData,
  }) async {
    if (!isConfigured) {
      throw Exception("AIInsightsService is not configured. Missing API Key.");
    }

    if (fruit == 'unknown') {
      throw Exception(
          "Cannot generate insights for unknown objects. Please use a banana image.");
    }

    try {
      final imageBytes = await imageFile.readAsBytes();

      Map<String, dynamic> weatherCalculations = {};
      if (weatherData != null) {
        weatherCalculations =
            _calculateWeatherBasedEstimates(ripeness, weatherData);
      }

      final prompt = _buildPrompt(
        fruit: fruit,
        ripeness: ripeness,
        confidenceScores: confidenceScores,
        imageDimensions: imageDimensions,
        selectedInsightKeys: selectedInsightKeys,
        weatherData: weatherData,
        weatherCalculations: weatherCalculations,
      );

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      final response = await _model!.generateContent(content);
      final fullText = response.text ?? "";

      Map<String, String> insights = _parseResponse(fullText);

      if (weatherData != null && weatherCalculations.isNotEmpty) {
        insights = _enhanceWithWeatherData(
            insights, weatherCalculations, weatherData, selectedInsightKeys);
      }

      return insights;
    } catch (e) {
      print("Error fetching AI insights: $e");
      throw Exception("Failed to fetch AI insights: ${e.toString()}");
    }
  }

  /// IMPROVED: Uses the same calculation logic as BananaRipeningCalculator
  Map<String, dynamic> _calculateWeatherBasedEstimates(
      String ripeness, WeatherData weatherData) {
    // Base days for different ripeness levels (at optimal 22°C, 75% humidity)
    Map<String, Map<String, int>> baseData = {
      'green': {'toRipe': 10, 'toSpoil': 16},
      'unripe': {'toRipe': 7, 'toSpoil': 12},
      'slightly ripe': {'toRipe': 4, 'toSpoil': 8},
      'ripe': {'toRipe': 0, 'toSpoil': 5}, // Changed from shelfLife to toSpoil
      'very ripe': {'toRipe': 0, 'toSpoil': 3},
      'overripe': {'toRipe': 0, 'toSpoil': 2},
      'rotten': {'toRipe': 0, 'toSpoil': 0},
    };

    String normalizedRipeness = ripeness.toLowerCase().replaceAll('_', ' ');
    Map<String, int> base =
        baseData[normalizedRipeness] ?? {'toRipe': 5, 'toSpoil': 8};

    double speedFactor = BananaRipeningCalculator.getRipeningSpeedFactor(
        weatherData.temperature, weatherData.humidity);

    // Calculate days to ripe
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

    // Ensure spoilage is always after ripening
    if (daysToRipe > 0 && daysToSpoil <= daysToRipe) {
      daysToSpoil = daysToRipe + 1;
    }

    return {
      'daysToRipe': daysToRipe,
      'daysToSpoil': daysToSpoil,
      'storageAdvice': BananaRipeningCalculator.getStorageAdvice(
          weatherData.temperature, weatherData.humidity),
      'speedFactor': speedFactor,
      'temperature': weatherData.temperature,
      'humidity': weatherData.humidity,
      'location': weatherData.location,
    };
  }

  Map<String, String> _enhanceWithWeatherData(
    Map<String, String> insights,
    Map<String, dynamic> weatherCalc,
    WeatherData weatherData,
    List<String> selectedKeys,
  ) {
    Map<String, String> enhanced = Map.from(insights);

    if (selectedKeys.contains(keyEstimatedTime)) {
      String baseInsight = insights[keyEstimatedTime] ?? "";
      enhanced[keyEstimatedTime] =
          _enhanceRipenessEstimate(baseInsight, weatherCalc);
    }

    if (selectedKeys.contains(keyEstimatedSpoil)) {
      String baseInsight = insights[keyEstimatedSpoil] ?? "";
      enhanced[keyEstimatedSpoil] =
          _enhanceSpoilageEstimate(baseInsight, weatherCalc);
    }

    if (selectedKeys.contains(keyProperStorage)) {
      String baseInsight = insights[keyProperStorage] ?? "";
      enhanced[keyProperStorage] =
          _enhanceStorageAdvice(baseInsight, weatherCalc);
    }

    return enhanced;
  }

  String _enhanceRipenessEstimate(
      String baseInsight, Map<String, dynamic> weatherCalc) {
    int daysToRipe = weatherCalc['daysToRipe'];
    double temperature = weatherCalc['temperature'];
    String location = weatherCalc['location'];

    List<String> timingAdvice = [];

    if (daysToRipe <= 1) {
      timingAdvice.add("• URGENT: Sell today for premium prices");
      timingAdvice.add("• Monitor hourly for optimal ripeness");
    } else if (daysToRipe <= 3) {
      timingAdvice.add("• Quick sale needed within 3 days");
      timingAdvice.add("• Check daily for ripening progress");
    } else if (daysToRipe <= 7) {
      timingAdvice.add("• Good wholesale timing available");
      timingAdvice.add("• Monitor every 2-3 days");
    } else {
      timingAdvice.add("• Long-term storage possible");
      timingAdvice.add("• Weekly quality checks sufficient");
    }

    String weatherNote = "";
    if (temperature > 28) {
      weatherNote = "• Hot weather - accelerated ripening expected";
    } else if (temperature < 18) {
      weatherNote = "• Cool conditions - slower ripening process";
    }

    String result = "$daysToRipe days in $location conditions";
    for (var advice in timingAdvice) {
      result += "\n$advice";
    }
    if (weatherNote.isNotEmpty) {
      result += "\n$weatherNote";
    }

    return result;
  }

  String _enhanceSpoilageEstimate(
      String baseInsight, Map<String, dynamic> weatherCalc) {
    int daysToSpoil = weatherCalc['daysToSpoil'];
    double speedFactor = weatherCalc['speedFactor'];

    String urgency = "";
    String action = "";

    if (daysToSpoil <= 1) {
      urgency = "• CRITICAL: $daysToSpoil day left";
      action = "• Immediate sale required - consider alternative markets";
    } else if (daysToSpoil <= 3) {
      urgency = "• HIGH PRIORITY: $daysToSpoil days remaining";
      action = "• Quick sale needed - prioritize fast-moving channels";
    } else if (daysToSpoil <= 7) {
      urgency = "• MODERATE: $daysToSpoil days shelf life";
      action = "• Standard retail channels work";
    } else {
      urgency = "• LOW RISK: $daysToSpoil days available";
      action = "• Perfect for export/wholesale";
    }

    String speedNote = "";
    if (speedFactor > 1.5) {
      speedNote = "• Weather accelerating - use fans/AC";
    } else if (speedFactor < 0.8) {
      speedNote = "• Cool conditions extending shelf life";
    }

    String result = "$urgency\n$action";
    if (speedNote.isNotEmpty) {
      result += "\n$speedNote";
    }

    return result;
  }

  String _enhanceStorageAdvice(
      String baseInsight, Map<String, dynamic> weatherCalc) {
    double temp = weatherCalc['temperature'];
    double humidity = weatherCalc['humidity'];
    double speedFactor = weatherCalc['speedFactor'];

    List<String> advice = [];

    // Temperature-based storage
    if (temp > 30) {
      advice.add(
          "• URGENT: Move to air-conditioned area immediately (target 18-24°C)");
      advice.add(
          "• Separate ripe bananas to prevent ethylene gas spread to others");
      advice.add(
          "• Check inventory every 4 hours - ripening accelerated by 2-3x");
    } else if (temp > 27) {
      advice.add(
          "• Use electric fans for air circulation, avoid direct sunlight");
      advice.add("• Check twice daily (morning and evening) for color changes");
      advice.add("• Keep 15cm spacing between banana bunches for airflow");
    } else if (temp < 16) {
      advice.add("• Move to warmer storage area (18-24°C optimal range)");
      advice.add("• Group bananas together for collective warmth retention");
      advice.add("• Avoid refrigeration - causes skin blackening below 13°C");
    } else {
      advice.add(
          "• Current temperature is optimal - maintain existing conditions");
      advice.add("• Standard room temperature storage working well");
    }

    // Humidity-based handling
    if (humidity > 90) {
      advice.add(
          "• CRITICAL: High humidity risk - install dehumidifier or increase ventilation");
      advice.add("• Space bananas 20cm apart to prevent moisture accumulation");
      advice.add(
          "• Daily inspection for black spots, mold, or premature softening");
      advice.add(
          "• Use paper towels between stacked layers to absorb excess moisture");
    } else if (humidity > 85) {
      advice.add("• Increase air circulation with fans - avoid dense stacking");
      advice.add(
          "• Don't use plastic covers - traps moisture and accelerates decay");
      advice.add("• Keep away from water sources and damp walls");
    } else if (humidity < 60) {
      advice
          .add("• Dry air detected - protect from direct AC vents and heaters");
      advice.add(
          "• Consider light misting of storage area (not directly on fruit)");
      advice.add("• Monitor for premature skin darkening from dehydration");
    } else {
      advice
          .add("• Humidity levels are ideal for banana storage (60-85% range)");
    }

    // Ripeness-based sorting strategy
    if (speedFactor > 1.5) {
      advice.add("• URGENT SORTING: Separate by ripeness stage immediately");
      advice.add(
          "• Create 3 zones: Ready-to-sell (ripe), Mid-stage (3-5 days), Long-term (unripe)");
      advice.add(
          "• Sell ripest stock first - rotate every 6-12 hours in hot conditions");
      advice.add("• Keep different ripeness stages 1 meter apart minimum");
    } else if (speedFactor < 0.8) {
      advice
          .add("• Slow ripening allows flexible grouping of different stages");
      advice
          .add("• Extended storage possible - plan 7-10 day inventory cycles");
      advice.add("• Can mix slightly ripe and unripe in same display area");
    } else {
      advice.add("• Normal ripening pace - standard sorting by ripeness level");
      advice.add("• Rotate stock every 24-48 hours from back to front");
    }

    // Business optimization based on conditions
    if (temp > 25 && humidity > 75) {
      advice.add(
          "• PRICING TIP: Fast ripening conditions - market as 'ready-to-eat' premium");
      advice
          .add("• Expect 30-40% faster turnover - adjust ordering accordingly");
    } else if (temp < 20) {
      advice.add(
          "• Slower ripening allows inventory buildup and bulk purchasing");
      advice.add("• Good time for wholesale negotiations and volume discounts");
    }

    // Display strategy
    if (speedFactor > 1.3) {
      advice.add(
          "• Display ripe bananas prominently at store entrance for quick sales");
      advice.add("• Keep unripe stock in back storage until needed");
    }

    // Return top 8-10 most relevant pieces of advice
    return advice.take(10).join("\n");
  }

  String _buildPrompt({
    required String fruit,
    required String ripeness,
    required Map<String, dynamic> confidenceScores,
    required Map<String, dynamic> imageDimensions,
    required List<String> selectedInsightKeys,
    WeatherData? weatherData,
    Map<String, dynamic>? weatherCalculations,
  }) {
    final confidenceString = confidenceScores.entries
        .map((e) => "${e.key}: ${(e.value * 100).toStringAsFixed(1)}%")
        .join(', ');

    String weatherContext = "";
    if (weatherData != null && weatherCalculations != null) {
      weatherContext = """
CRITICAL WEATHER DATA - MUST BE CONSIDERED IN ALL INSIGHTS:
- Current Location: ${weatherData.location}
- Temperature: ${weatherData.temperature.toStringAsFixed(1)}°C
- Humidity: ${weatherData.humidity.toStringAsFixed(0)}%
- Ripening Speed Factor: ${weatherCalculations['speedFactor'].toStringAsFixed(1)}x normal rate

CALCULATED ESTIMATES (use these exact numbers):
- Days until ripe: ${weatherCalculations['daysToRipe']} days
- Days until spoiled: ${weatherCalculations['daysToSpoil']} days

WEATHER IMPACT REQUIREMENTS:
- ALL timing estimates MUST reference current weather conditions
- ALL storage advice MUST be specific to current temperature and humidity
- If temperature > 28°C, emphasize urgent cooling and fast sales
- If humidity > 85%, emphasize ventilation and mold prevention
- If conditions are extreme, mark recommendations as URGENT/CRITICAL
- ALWAYS ensure spoilage time is LONGER than ripening time
""";
    }

    return """
You are analyzing bananas for a banana store owner. Provide detailed, actionable business insights that DIRECTLY account for current weather conditions.

Detection Results:
- Fruit: $fruit
- Current State: $ripeness  
- Confidence: $confidenceString

$weatherContext

CRITICAL COUNTING INSTRUCTION:
Count ALL individual bananas visible anywhere in the entire image:
1. Scan the ENTIRE image - look at all bananas present, not just the focused one
2. Count each individual banana you can see (front, back, sides, anywhere)
3. Include partially visible bananas if you can tell they're separate bananas
4. The analysis will focus on the main/clearest banana, but COUNT ALL visible
5. Format: "X bananas visible (analyzing focused banana)"
6. Example: If you see 5 bananas total but analyzing the front one, say "5 bananas visible (analyzing focused banana)"

Provide EXACTLY these sections with EXACTLY these titles (including the colon and space).

Estimated Time to Ripeness: 
• [X days WITH weather location mention - e.g., "3 days in Manila conditions (28°C, 75% humidity)"]
• [Specific urgency based on WEATHER - hot weather = more urgent, cool = less urgent]
• [Monitoring frequency adjusted for weather - hot weather = check more often]
• [Sales timing strategy that accounts for accelerated/slowed ripening from weather]
• [Temperature impact note - explicitly mention if hot/cool weather affects timing]

Estimated Time to Spoil: 
• [X days WITH urgency level adjusted for weather conditions]
• [Immediate action based on weather acceleration - faster in hot/humid conditions]
• [Sales channel recommendations considering current weather impact on shelf life]
• [Alternative uses if weather is accelerating spoilage unexpectedly]
• [Warning signs specific to current weather conditions (mold in humid, drying in dry)]

Quality Grading: 
• [Count: Count ALL bananas visible in the entire image - format "X bananas visible (analyzing focused banana)"]
• [Grade level (Premium/Standard/Discount) with brief reasoning]
• [Best use case for this quality (retail/food service/wholesale)]

Storage and Sorting: 
• [URGENT temperature action if needed - reference ACTUAL current temperature and specify exact adjustment needed]
• [URGENT humidity action if needed - reference ACTUAL current humidity and specify ventilation/dehumidifier needs]
• [Sorting strategy adjusted for weather speed factor - faster ripening = more frequent sorting]
• [Physical spacing requirements based on humidity - higher humidity = more spacing needed]
• [Handling precautions specific to current weather - gentle handling in heat, protect from cold]
• [Rotation frequency based on weather - hot weather = rotate every 6-12 hours, cool = every 24-48 hours]
• [Environmental controls needed NOW - fans, AC, dehumidifier based on actual conditions]
• [Ethylene management adjusted for temperature - separation more critical in heat]
• [Display strategy for current weather - shaded areas in heat, warmer spots in cool weather]
• [Monitoring schedule based on ripening speed - hourly in extreme heat, daily in normal conditions]

STRICT RULES:
1. Use EXACTLY the section titles shown above
2. EVERY section must reference or account for current weather conditions
3. Time to Ripeness: 5 bullets - MUST mention temperature/location in first bullet
4. Time to Spoil: 5 bullets - MUST adjust urgency based on weather
5. Quality Grading: 3 bullets - First is count with "(analyzing focused banana)"
6. Storage and Sorting: 10 bullets - MOST DETAILED, all weather-specific
7. Each bullet point uses (•) not dashes
8. Spoilage time MUST be longer than ripening time
9. DO NOT use generic advice - all recommendations must be specific to CURRENT conditions
10. If weather is extreme (temp >30°C or <15°C, humidity >90%), use URGENT/CRITICAL language

Example with weather integration (28°C, 75% humidity in Manila):
Estimated Time to Ripeness: 
• 2 days in Manila conditions (28°C, 75% humidity) - accelerated by warm weather
• MODERATE URGENCY: Hot weather speeding ripeness, prepare for quick sale window
• Check twice daily (morning/evening) due to 1.3x faster ripening from heat
• Position for sale within 48 hours to catch optimal ripeness before over-ripening
• Temperature at 28°C is accelerating process - move to coolest storage area available

Storage and Sorting: 
• URGENT: Current 28°C temperature is above optimal range - move to air-conditioned area (target 20-22°C) or use fans immediately
• Humidity at 75% is acceptable but monitor closely - ensure 15cm spacing between bunches to maintain air circulation
• Due to 1.3x faster ripening rate, separate by ripeness stage NOW - create distinct zones for ripe vs unripe inventory
[Continue with 7 more detailed weather-specific bullets...]

Continue this format for all sections, ensuring EVERY recommendation directly addresses current weather conditions.
""";
  }

  Map<String, String> _parseResponse(String text) {
    final Map<String, String> insights = {
      keyEstimatedTime: "Info not found.",
      keyEstimatedSpoil: "Info not found.",
      keyQualityGrade: "Info not found.",
      keyProperStorage: "Info not found.",
    };

    final lines = text.split('\n');
    String? currentContent;
    String? currentTitleKey;

    final titleToKeyMap = {
      insightTitles[0]: keyEstimatedTime,
      insightTitles[1]: keyEstimatedSpoil,
      insightTitles[2]: keyQualityGrade,
      insightTitles[3]: keyProperStorage,
    };

    for (final line in lines) {
      bool foundTitle = false;
      for (final title in insightTitles) {
        if (line.startsWith(title)) {
          if (currentTitleKey != null && currentContent != null) {
            insights[currentTitleKey] = currentContent.trim();
          }
          currentTitleKey = titleToKeyMap[title];
          currentContent = line.substring(title.length).trimLeft();
          foundTitle = true;
          break;
        }
      }
      if (!foundTitle && currentContent != null) {
        currentContent += "\n$line";
      }
    }

    if (currentTitleKey != null && currentContent != null) {
      insights[currentTitleKey] = currentContent.trim();
    }

    insights.forEach((key, value) {
      if (value == "Info not found." || value.trim().isEmpty) {
        insights[key] = _getFallbackContent(key);
      }
    });

    return insights;
  }

  String _getFallbackContent(String key) {
    switch (key) {
      case keyEstimatedTime:
        return "• Unable to determine from image analysis\n• Recommend visual inspection daily at opening and closing\n• Check for color changes, firmness at stem, and overall appearance\n• Consult with experienced staff for second opinion\n• Consider environmental factors affecting ripening\n• Document observations to track ripening patterns";

      case keyEstimatedSpoil:
        return "• Monitor daily for spoilage signs including dark spots and soft areas\n• Typical shelf life ranges 3-7 days depending on conditions\n• Prioritize sale of ripest stock first\n• Consider bundling with other products to move inventory faster\n• Train staff to identify early spoilage indicators\n• Have backup plan for overripe stock (alternative uses)";

      case keyQualityGrade:
        return "• Count: 1 banana visible (analyzing focused banana)\n• Standard commercial grade suitable for general retail\n• Suitable for everyday consumer market with normal expectations";

      case keyProperStorage:
        return "• Room temperature 18-24°C ideal - measure current temp and adjust with AC or heating as needed\n• Moderate humidity 65-75% preferred - use hygrometer to monitor, add dehumidifier if above 85%\n• Keep away from direct sunlight and heat sources - position storage away from windows and appliances\n• Ensure good air circulation around displays - minimum 10cm spacing between bunches\n• Check daily for quality changes and rotate stock - move older stock to front every morning\n• Separate different ripeness stages by 50cm minimum to control ethylene exposure\n• Adjust storage based on weather - increase monitoring frequency during hot/humid days\n• Create clear labeling system showing arrival date for proper FIFO rotation";

      default:
        return "• Analysis not available - manual inspection required\n• Consult store manager or experienced staff\n• Monitor conditions closely over next 24-48 hours";
    }
  }
}
