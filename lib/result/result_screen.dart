// lib/result/result_screen.dart - Updated without customer targeting
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:maduro/result/ai_service.dart';
import 'package:maduro/result/firestore_service.dart';
import 'package:maduro/result/result_widgets.dart';
import 'package:maduro/result/weather_service.dart';

class ResultPage extends StatefulWidget {
  final File imageFile;
  final String fruit;
  final String ripeness;
  final Map<String, dynamic> confidenceScores;
  final Map<String, dynamic> imageDimensions;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.fruit,
    required this.ripeness,
    required this.confidenceScores,
    required this.imageDimensions,
    required String imagePath,
    Map<String, dynamic>? results,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with TickerProviderStateMixin {
  late final AIInsightsService _aiService;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WeatherService _weatherService = WeatherService();

  late AnimationController _slideController;
  late AnimationController _fadeController;

  late _ResultState _state;
  Future<Map<String, String>>? _nutritionFuture;
  Future<WeatherData?>? _weatherFuture;
  WeatherData? _currentWeatherData;

  @override
  void initState() {
    super.initState();
    _state = _ResultState();
    _initAnimations();
    _initServices();
    _loadNutritionFacts();
    _loadWeatherData();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  void _initServices() {
    _aiService = AIInsightsService(
      apiKey: dotenv.env['GEMINI_API_KEY'],
      modelName: 'gemini-2.5-flash',
    );

    if (!_aiService.isConfigured) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _state.setError("AI Service not configured. Check your .env file.");
      });
    }
  }

  void _loadNutritionFacts() {
    if (widget.fruit != 'unknown') {
      _nutritionFuture =
          ResultWidgets.fetchNutritionFacts(widget.fruit).then((data) {
        _state.nutritionFacts = data;
        return data;
      });
    }
  }

  void _loadWeatherData() {
    _weatherFuture = _weatherService.getCurrentWeather().then((weatherData) {
      _currentWeatherData = weatherData;
      return weatherData;
    });
  }

  Future<void> _fetchAIInsights() async {
    if (!_canFetchInsights()) return;

    if (widget.fruit == 'unknown') {
      _showSnackBar("Cannot analyze unknown objects. Please capture a banana.");
      return;
    }

    _state.setLoading(true);

    try {
      if (_currentWeatherData == null && _weatherFuture != null) {
        try {
          _currentWeatherData = await _weatherFuture;
        } catch (e) {
          print("Weather data not available for AI analysis: $e");
        }
      }

      final insights = await _aiService.fetchInsights(
        imageFile: widget.imageFile,
        fruit: widget.fruit,
        ripeness: widget.ripeness,
        confidenceScores: widget.confidenceScores,
        imageDimensions: widget.imageDimensions,
        selectedInsightKeys: _state.selectedInsights.toList(),
        weatherData: _currentWeatherData,
      );

      if (mounted) {
        _state.updateInsights(insights);
        await _saveToFirestore(saveAI: true);
      }
    } catch (e) {
      if (mounted) {
        _state.setError("Failed to fetch AI insights: $e");
        await _saveToFirestore(saveAI: false);
      }
    }
  }

  bool _canFetchInsights() {
    if (widget.fruit == 'unknown') {
      _showSnackBar(
          "Cannot analyze unknown objects. Please try again with a banana.");
      return false;
    }

    if (!_aiService.isConfigured) {
      _showSnackBar("AI Service not available. Please check configuration.");
      return false;
    }

    if (_state.selectedInsights.isEmpty) {
      _showSnackBar("Please select at least one insight type.");
      return false;
    }

    return true;
  }

  Future<void> _saveToFirestore({required bool saveAI}) async {
    if (_state.hasSaved && saveAI && !_state.hasError) return;

    String? imageUrl;
    try {
      imageUrl = await _firestoreService.uploadImageToStorage(
          widget.imageFile, widget.fruit);
    } catch (e) {
      _showSnackBar("Image upload failed: $e");
    }

    final result = await _firestoreService.saveHistoryRecord(
      fruit: widget.fruit,
      detectedRipeness: widget.ripeness,
      confidenceScores: widget.confidenceScores,
      imageDimensions: widget.imageDimensions,
      saveAiInsights: saveAI,
      aiInsight1: _getInsightValue('estimatedTime', saveAI),
      aiInsight2: _getInsightValue('estimatedTimeToSpoil', saveAI),
      aiInsight3: _getInsightValue('qualityGrade', saveAI),
      aiInsight4: _getInsightValue('properStorage', saveAI),
      aiInsight5: null, // Removed customer targeting
      aiError: _state.error,
      nutritionFacts: _state.nutritionFacts,
      imageUrl: imageUrl,
      weatherData: _currentWeatherData,
    );

    if (mounted) {
      if (result['success'] == true && saveAI && !_state.hasError) {
        _state.setSaved(true);
        _showSnackBar("Analysis saved successfully!");
      } else if (result['success'] != true) {
        _showSnackBar("Failed to save: ${result['error']}");
      }
    }
  }

  String? _getInsightValue(String key, bool saveAI) {
    if (saveAI &&
        _state.insights.containsKey(key) &&
        _state.selectedInsights.contains(key) &&
        _state.hasAnalyzed &&
        !_state.isLoading &&
        !_state.hasError) {
      return _state.insights[key];
    }
    return null;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _navigateToChat() {
    if (_auth.currentUser != null) {
      Navigator.pushNamed(context, '/aichatbot');
    } else {
      _showSnackBar("Please log in to use the Chatbot");
    }
  }

  void _navigateToDetection() {
    if (_auth.currentUser != null) {
      Navigator.pushNamed(context, '/detectionLandingPage');
    } else {
      _showSnackBar("Please log in to continue");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _state,
        builder: (context, child) {
          return ModernResultView(
            imageFile: widget.imageFile,
            fruit: widget.fruit,
            ripeness: widget.ripeness,
            confidenceScores: widget.confidenceScores,
            imageDimensions: widget.imageDimensions,
            nutritionFuture: _nutritionFuture,
            weatherFuture: _weatherFuture,
            state: _state,
            slideController: _slideController,
            fadeController: _fadeController,
            onInsightToggle: (key, selected) {
              _state.toggleInsight(key, selected);
            },
            onFetchInsights: _fetchAIInsights,
            onCameraPressed: _navigateToDetection,
            onChatPressed: _navigateToChat,
            aiService: _aiService,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _state.dispose();
    super.dispose();
  }
}

class _ResultState extends ChangeNotifier {
  bool isLoading = false;
  bool hasAnalyzed = false;
  bool hasSaved = false;
  String? error;
  bool hasWeatherData = false;

  // CHANGED: Removed 'customerTargeting' - only 4 insights now
  final Set<String> selectedInsights = {
    'estimatedTime',
    'estimatedTimeToSpoil',
    'qualityGrade',
    'properStorage',
  };

  final Map<String, String> insights = {
    'estimatedTime': "Not analyzed yet",
    'estimatedTimeToSpoil': "Not analyzed yet",
    'qualityGrade': "Not analyzed yet",
    'properStorage': "Not analyzed yet",
  };

  Map<String, String>? nutritionFacts;

  bool get hasError => error != null;

  void setWeatherAvailable(bool available) {
    hasWeatherData = available;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    if (loading) {
      hasAnalyzed = true;
      error = null;
      _updateInsightsContent(hasWeatherData
          ? "Analyzing with weather conditions..."
          : "Analyzing...");
    }
    notifyListeners();
  }

  void setError(String errorMessage) {
    error = errorMessage;
    isLoading = false;
    hasAnalyzed = true;
    _updateInsightsContent("Error: $errorMessage");
    notifyListeners();
  }

  void setSaved(bool saved) {
    hasSaved = saved;
    notifyListeners();
  }

  void toggleInsight(String key, bool selected) {
    if (selected) {
      selectedInsights.add(key);
    } else {
      selectedInsights.remove(key);
    }
    if (!hasAnalyzed || hasError || isLoading) {
      insights[key] = "Not analyzed yet";
    }
    notifyListeners();
  }

  void updateInsights(Map<String, String> newInsights) {
    newInsights.forEach((key, value) {
      if (selectedInsights.contains(key)) {
        insights[key] = value;
      }
    });
    isLoading = false;
    error = null;
    hasAnalyzed = true;
    notifyListeners();
  }

  void _updateInsightsContent(String message) {
    for (var key in selectedInsights) {
      insights[key] = message;
    }
  }
}
