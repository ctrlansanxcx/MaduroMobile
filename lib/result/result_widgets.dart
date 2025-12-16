import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'weather_service.dart';

// Theme and Constants
class AppTheme {
  static const primaryGreen = Color(0xFFA0C334);
  static const accentYellow = Color(0xFFE5D429);
  static const darkGreen = Color(0xFF799620);

  static const gradient = LinearGradient(
    colors: [primaryGreen, accentYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 1,
        offset: const Offset(0, 2),
      )
    ],
  );
}

class InsightConfig {
  static const insights = {
    // UPDATED: Only 4 business-focused insights for banana store
    'estimatedTime':
        InsightData('Estimated Time to Ripe', Icons.schedule_outlined),
    'estimatedTimeToSpoil':
        InsightData('Estimated Time to Spoil', Icons.visibility_outlined),
    'qualityGrade': InsightData('Quality Grading', Icons.grade_outlined),
    'properStorage': InsightData('Storage and Sorting', Icons.kitchen_outlined),
  };

  static const apiKey = 'CALORIENINJA_API_KEY';
  static const baseUrl = 'CALORIENINJA_BASE_URL';
}

class InsightData {
  final String name;
  final IconData icon;

  const InsightData(this.name, this.icon);
}

// ResultHeader Widget
class ResultHeader extends StatelessWidget {
  final String fruitName;
  final double ripenessPercent;

  const ResultHeader({
    super.key,
    required this.fruitName,
    required this.ripenessPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fruitName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ripenessPercent / 100,
          backgroundColor: Colors.grey[300],
          color: AppTheme.primaryGreen,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
        const SizedBox(height: 8),
        Text(
          '${ripenessPercent.toStringAsFixed(1)}% Ripeness',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Weather Card Widget
class WeatherCard extends StatelessWidget {
  final Future<WeatherData?>? weatherFuture;
  final AnimationController slideController;

  const WeatherCard({
    super.key,
    required this.weatherFuture,
    required this.slideController,
  });

  @override
  Widget build(BuildContext context) {
    if (weatherFuture == null) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FutureBuilder<WeatherData?>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const SizedBox.shrink();
          }

          final weather = snapshot.data!;
          return _buildWeatherCard(weather);
        },
      ),
    );
  }

  Widget _buildWeatherCard(WeatherData weather) {
    return Container(
      decoration: AppTheme.cardDecoration,
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
                    gradient: AppTheme.gradient,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.place, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Current Location & Weather',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildWeatherInfo(
                      'Location', weather.location, Icons.location_on_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeatherInfo(
                      'Temperature',
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      Icons.thermostat_outlined),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 80,
      decoration: AppTheme.cardDecoration,
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Getting location...',
              style: TextStyle(
                color: AppTheme.darkGreen,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ResultDetail Widget
class ResultDetail extends StatelessWidget {
  final Map<String, dynamic> fruitDetails;

  const ResultDetail({
    super.key,
    required this.fruitDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Color:', fruitDetails['color'] ?? 'N/A'),
          _buildDetailRow('Texture:', fruitDetails['texture'] ?? 'N/A'),
          _buildDetailRow('Smell:', fruitDetails['smell'] ?? 'N/A'),
          _buildDetailRow(
              'Optimal Stage:', fruitDetails['optimalStage'] ?? 'N/A'),
          _buildDetailRow(
              'Best Consumption:', fruitDetails['bestConsumption'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.darkGreen,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Main Modern View
class ModernResultView extends StatelessWidget {
  final File imageFile;
  final String fruit;
  final String ripeness;
  final Map<String, dynamic> confidenceScores;
  final Map<String, dynamic> imageDimensions;
  final Future<Map<String, String>>? nutritionFuture;
  final Future<WeatherData?>? weatherFuture;
  final dynamic state;
  final AnimationController slideController;
  final AnimationController fadeController;
  final Function(String, bool) onInsightToggle;
  final VoidCallback onFetchInsights;
  final VoidCallback onCameraPressed;
  final VoidCallback onChatPressed;
  final dynamic aiService;

  const ModernResultView({
    super.key,
    required this.imageFile,
    required this.fruit,
    required this.ripeness,
    required this.confidenceScores,
    required this.imageDimensions,
    required this.nutritionFuture,
    this.weatherFuture,
    required this.state,
    required this.slideController,
    required this.fadeController,
    required this.onInsightToggle,
    required this.onFetchInsights,
    required this.onCameraPressed,
    required this.onChatPressed,
    required this.aiService,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildModernAppBar(
            title: 'DETAILS',
            leadingIcon: _buildAppBarButton(Icons.camera_alt, onCameraPressed),
            trailingIcon:
                _buildAppBarButton(Icons.chat_bubble_outline, onChatPressed),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildAnimatedImage(),
              const SizedBox(height: 20),
              _buildInfoCards(),
              const SizedBox(height: 20),
              _buildWeatherCard(),
              const SizedBox(height: 20),
              _buildNutritionCard(),
              const SizedBox(height: 20),
              _buildAISection(),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  PreferredSize _buildModernAppBar({
    required String title,
    Widget? leadingIcon,
    Widget? trailingIcon,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB5DB49),
              Color(0xFFEAD938),
              Color(0xFFF5EE62),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                if (leadingIcon != null) ...[
                  leadingIcon,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.8,
                    ),
                    textAlign: leadingIcon != null || trailingIcon != null
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  trailingIcon,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildAnimatedImage() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: fadeController,
        child: Hero(
          tag: 'fruit_image',
          child: Container(
            height: 280,
            decoration: AppTheme.cardDecoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImageError(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Image not available',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Row(
        children: [
          Expanded(child: _buildQuickInfoCard('Fruit', fruit, Icons.apple)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildQuickInfoCard('Ripeness', ripeness, Icons.timeline)),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(String title, String value, IconData icon) {
    Color cardColor;
    Color iconColor;

    if (value.toLowerCase() == 'unknown') {
      cardColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade700;
    } else if (value.toLowerCase() == 'rotten') {
      cardColor = Colors.red.shade50;
      iconColor = Colors.red.shade700;
    } else if (value.toLowerCase() == 'ripe') {
      cardColor = Colors.green.shade50;
      iconColor = Colors.green.shade700;
    } else if (value.toLowerCase() == 'unripe') {
      cardColor = Colors.yellow.shade50;
      iconColor = Colors.yellow.shade700;
    } else {
      cardColor = AppTheme.primaryGreen.withOpacity(0.1);
      iconColor = AppTheme.darkGreen;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration.copyWith(
        color: cardColor,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: iconColor.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _capitalizeFirst(value),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildWeatherCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      )),
      child: FutureBuilder<WeatherData?>(
        future: weatherFuture,
        builder: (context, snapshot) {
          return Container(
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: _buildWeatherContent(snapshot),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherContent(AsyncSnapshot<WeatherData?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Column(
        children: [
          _buildWeatherHeader('Fetching weather data...'),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildWeatherInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: 'Getting location...',
                    isLoading: true,
                    isWide: true,
                    isStretch: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      _buildWeatherInfoCard(
                        icon: Icons.thermostat_outlined,
                        label: 'Temperature',
                        value: 'Loading...',
                        isLoading: true,
                        isCompact: true,
                      ),
                      const SizedBox(height: 6),
                      _buildWeatherInfoCard(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: 'Loading...',
                        isLoading: true,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (snapshot.hasError) {
      return Column(
        children: [
          _buildWeatherHeader('Weather data unavailable'),
          const SizedBox(height: 12),
          _buildErrorState('Unable to fetch weather data'),
        ],
      );
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return Column(
        children: [
          _buildWeatherHeader('Using default location'),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildWeatherInfoCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: 'Undetected',
                    isLoading: false,
                    isWide: true,
                    isStretch: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      _buildWeatherInfoCard(
                        icon: Icons.thermostat_outlined,
                        label: 'Temperature',
                        value: 'N/A',
                        isLoading: false,
                        isCompact: true,
                      ),
                      const SizedBox(height: 6),
                      _buildWeatherInfoCard(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: 'N/A',
                        isLoading: false,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final weather = snapshot.data!;
    return Column(
      children: [
        _buildWeatherHeader('Weather Conditions'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildWeatherInfoCard(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: weather.location,
                isLoading: false,
                isWide: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  _buildWeatherInfoCard(
                    icon: Icons.thermostat_outlined,
                    label: 'Temperature',
                    value: '${weather.temperature.toStringAsFixed(1)}°C',
                    isLoading: false,
                    isCompact: true,
                  ),
                  const SizedBox(height: 6),
                  _buildWeatherInfoCard(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${weather.humidity.toStringAsFixed(0)}%',
                    isLoading: false,
                    isCompact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherHeader(String subtitle) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: AppTheme.gradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isLoading,
    bool isWide = false,
    bool isCompact = false,
    bool isStretch = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
        border: Border.all(
          color: Colors.grey.shade200.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.6),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isLoading && isWide
          ? Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 8,
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : isWide && !isLoading
              ? Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.15),
                            AppTheme.primaryGreen.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.darkGreen,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isCompact ? 24 : 28,
                          height: isCompact ? 24 : 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SizedBox(
                            width: isCompact ? 12 : 14,
                            height: isCompact ? 12 : 14,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),
                        Container(
                          height: isCompact ? 8 : 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(height: isCompact ? 4 : 6),
                        Container(
                          height: isCompact ? 6 : 8,
                          width: isCompact ? 25 : 35,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isCompact ? 24 : 28,
                          height: isCompact ? 24 : 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryGreen.withOpacity(0.15),
                                AppTheme.primaryGreen.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: isCompact ? 14 : 16,
                            color: AppTheme.darkGreen,
                          ),
                        ),
                        SizedBox(height: isCompact ? 6 : 10),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: isCompact ? 9 : 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(height: isCompact ? 2 : 4),
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: isCompact ? 10 : 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkGreen,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Container(
        decoration: AppTheme.cardDecoration,
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
                      gradient: AppTheme.gradient,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Nutrition Facts (per 100g)',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            _buildNutritionContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionContent() {
    if (nutritionFuture == null) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text('Nutrition data unavailable'),
      );
    }

    return FutureBuilder<Map<String, String>>(
      future: nutritionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text('Failed to load nutrition data'),
          );
        }

        final nutrition = snapshot.data!;
        final mainNutrients = [
          'Calories',
          'Carbs (total)',
          'Sugar',
          'Protein',
          'Fat (total)',
          'Saturated Fat',
          'Trans Fat',
          'Cholesterol',
          'Sodium',
          'Dietary Fiber',
          'Vitamin D',
          'Calcium',
          'Iron',
          'Potassium',
        ];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: mainNutrients
                .where((key) => nutrition.containsKey(key))
                .map((key) => _buildNutrientRow(key, nutrition[key]!))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildNutrientRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISection() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
      )),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAIHeader(),
            _buildAIContent(),
            _buildInsightChips(),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAIHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppTheme.gradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIContent() {
    // Check if fruit is unknown first
    if (fruit == 'unknown') {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'AI insights are only available for detected bananas. Please capture a banana image to get insights.',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!aiService.isConfigured) {
      return _buildErrorMessage(
          'AI Service not available. Check API key in .env');
    }

    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (state.hasError) {
      return _buildErrorMessage(state.error!);
    }

    if (!state.hasAnalyzed) {
      return _buildWelcomeState();
    }

    return _buildInsightsList();
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Analyzing your fruit for AI Insights...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.business_center,
            size: 50,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          const Text(
            'Get AI Insights',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select the AI insights you want and get AI-powered analysis for your banana wholesale operations',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsList() {
    final selectedInsights = state.selectedInsights
        .where((key) => InsightConfig.insights.containsKey(key))
        .toList();

    final insightsToShow = selectedInsights
        .where((key) =>
            state.insights[key] != "Not analyzed yet" &&
            state.insights[key] != "Analyzing..." &&
            !state.insights[key]!.startsWith("Error:"))
        .toList();

    if (insightsToShow.isEmpty &&
        state.hasAnalyzed &&
        !state.isLoading &&
        !state.hasError) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(
          'No insights available for the selected types, or analysis yielded no content.',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
        ),
      );
    } else if (insightsToShow.isEmpty && !state.hasAnalyzed) {
      return _buildWelcomeState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: insightsToShow
            .map<Widget>(
                (key) => _buildInsightCard(key, state.insights[key] ?? ''))
            .toList(),
      ),
    );
  }

  Widget _buildInsightCard(String key, String content) {
    final insight = InsightConfig.insights[key]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(insight.icon, color: AppTheme.darkGreen, size: 18),
              const SizedBox(width: 6),
              Text(
                insight.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightChips() {
    if (state.isLoading ||
        (state.hasAnalyzed && !state.hasError && !state.isLoading)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: InsightConfig.insights.entries.map((entry) {
          final isSelected = state.selectedInsights.contains(entry.key);

          return FilterChip(
            label: Text(entry.value.name),
            selected: isSelected,
            onSelected: (selected) => onInsightToggle(entry.key, selected),
            avatar: Icon(entry.value.icon, size: 14),
            selectedColor: AppTheme.primaryGreen,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _getButtonGradient(),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _getButtonShadow(),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _getButtonAction(),
              borderRadius: BorderRadius.circular(14),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getButtonIcon(),
                    const SizedBox(width: 10),
                    Text(
                      _getButtonText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Gradient _getButtonGradient() {
    if (_isButtonDisabled()) {
      return LinearGradient(
        colors: [Colors.grey.shade400, Colors.grey.shade300],
      );
    }
    return AppTheme.gradient;
  }

  List<BoxShadow>? _getButtonShadow() {
    if (_isButtonDisabled()) return null;
    return [
      BoxShadow(
        color: AppTheme.primaryGreen.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }

  VoidCallback? _getButtonAction() {
    return _isButtonDisabled() ? null : onFetchInsights;
  }

  Widget _getButtonIcon() {
    if (state.isLoading) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (state.hasSaved && !state.hasError) {
      return const Icon(Icons.check_circle, color: Colors.white, size: 20);
    }

    return const Icon(Icons.auto_awesome, color: Colors.white, size: 20);
  }

  String _getButtonText() {
    if (state.isLoading) {
      return 'Analyzing...';
    }

    if (state.hasSaved && !state.hasError) {
      return 'Analysis Complete';
    }

    if (!aiService.isConfigured) {
      return 'AI Service Unavailable';
    }

    if (state.selectedInsights.isEmpty) {
      return 'Select Insights First';
    }

    return 'Get AI Insights';
  }

  bool _isButtonDisabled() {
    return state.isLoading ||
        (!state.hasError && state.hasSaved) ||
        !aiService.isConfigured ||
        state.selectedInsights.isEmpty;
  }
}

// Utility class for result widgets
class ResultWidgets {
  static Future<Map<String, String>> fetchNutritionFacts(String fruit) async {
    try {
      final apiKey = dotenv.env[InsightConfig.apiKey];
      final baseUrl = dotenv.env[InsightConfig.baseUrl];

      if (apiKey == null || baseUrl == null) {
        throw Exception('Nutrition API not configured');
      }

      final response = await http.get(
        Uri.parse('$baseUrl?query=$fruit'),
        headers: {
          'X-Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final item = items.first;
          return _extractNutritionData(item);
        }
      }

      return _getDefaultNutrition(fruit);
    } catch (e) {
      return _getDefaultNutrition(fruit);
    }
  }

  static Map<String, String> _extractNutritionData(Map<String, dynamic> item) {
    return {
      'Calories': '${item['calories']?.toInt() ?? 0} kcal',
      'Carbs (total)':
          '${item['carbohydrates_total_g']?.toStringAsFixed(1) ?? '0.0'} g',
      'Sugar': '${item['sugar_g']?.toStringAsFixed(1) ?? '0.0'} g',
      'Protein': '${item['protein_g']?.toStringAsFixed(1) ?? '0.0'} g',
      'Fat (total)': '${item['fat_total_g']?.toStringAsFixed(1) ?? '0.0'} g',
      'Fiber': '${item['fiber_g']?.toStringAsFixed(1) ?? '0.0'} g',
      'Sodium': '${item['sodium_mg']?.toInt() ?? 0} mg',
      'Potassium': '${item['potassium_mg']?.toInt() ?? 0} mg',
    };
  }

  static Map<String, String> _getDefaultNutrition(String fruit) {
    final defaults = {
      'apple': {
        'Calories': '52 kcal',
        'Carbs (total)': '14.0 g',
        'Sugar': '10.4 g',
        'Protein': '0.3 g',
        'Fat (total)': '0.2 g',
        'Fiber': '2.4 g',
      },
      'banana': {
        'Calories': '89 kcal',
        'Carbs (total)': '23.0 g',
        'Sugar': '12.2 g',
        'Protein': '1.1 g',
        'Fat (total)': '0.3 g',
        'Fiber': '2.6 g',
      },
      'orange': {
        'Calories': '47 kcal',
        'Carbs (total)': '12.0 g',
        'Sugar': '9.4 g',
        'Protein': '0.9 g',
        'Fat (total)': '0.1 g',
        'Fiber': '2.4 g',
      },
    };

    return defaults[fruit.toLowerCase()] ??
        {
          'Calories': 'N/A',
          'Carbs (total)': 'N/A',
          'Sugar': 'N/A',
          'Protein': 'N/A',
          'Fat (total)': 'N/A',
          'Fiber': 'N/A',
        };
  }
}
