import 'package:flutter/material.dart';
import 'package:maduro/history/nutrition_facts.dart';

/// Modern header card - reads exactly what was saved from result screen
class ModernHeaderCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String formattedDate;

  const ModernHeaderCard({
    super.key,
    required this.data,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = data['imageUrl']?.toString() ?? '';
    bool hasNetworkImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    // Read the fruit name
    final String fruitName =
        data['fruit']?.toString().toLowerCase() == 'unknown'
            ? 'Unknown Object'
            : (data['fruit']?.toString() ?? 'Banana');

    // FIXED: Use only 'detectedRipeness' from ML model
    final String ripenessLabel =
        data['detectedRipeness']?.toString() ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade300,
                        Colors.pink.shade300,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasNetworkImage
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.image_not_supported_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade300,
                                  Colors.grey.shade400,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.image_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fruitName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getRipenessColor(ripenessLabel),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ripenessLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInfoTag(
                  Icons.person_rounded,
                  data['username'] ?? 'Unknown',
                  Colors.blue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoTag(
                    Icons.schedule_rounded,
                    _formatDateShort(formattedDate),
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRipenessColor(String? ripeness) {
    if (ripeness == null) return Colors.grey;
    final lower = ripeness.toLowerCase();

    if (lower == 'ripe') return Colors.green;
    if (lower == 'unripe') return Colors.orange;
    if (lower == 'overripe' || lower == 'rotten') return Colors.red;
    if (lower == 'unknown') return Colors.grey;

    return Colors.grey;
  }

  String _formatDateShort(String date) {
    if (date.length > 20) {
      return date.substring(0, 20);
    }
    return date;
  }
}

/// Modern details section - shows exactly what was detected
/// REMOVED CONFIDENCE - Only shows Fruit Type, Ripeness, and Analysis Status
class ModernDetailsSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const ModernDetailsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // FIXED: Use only 'detectedRipeness' from ML model
    final String fruitType = data['fruit']?.toString() ?? 'Unknown';
    final String ripenessLevel =
        data['detectedRipeness']?.toString() ?? 'Unknown';
    final String analysisStatus =
        data['aiAnalysisStatus']?.toString() ?? 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detection Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailCard(
          'Fruit Type',
          fruitType.toLowerCase() == 'unknown' ? 'Unknown Object' : fruitType,
          Icons.apple_rounded,
          Colors.red,
        ),
        const SizedBox(height: 10),
        _buildDetailCard(
          'Ripeness Level',
          ripenessLevel,
          Icons.psychology_rounded,
          Colors.green,
        ),
        const SizedBox(height: 10),
        // REMOVED CONFIDENCE CARD
        _buildDetailCard(
          'Analysis Status',
          analysisStatus,
          Icons.verified_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
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

/// Modern recommendations section
class ModernRecommendationsSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const ModernRecommendationsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool hasAiSuccess = data['aiAnalysisStatus'] == 'Success';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Recommendations',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        hasAiSuccess ? _buildRecommendationCards() : _buildNoAiCard(),
      ],
    );
  }

  Widget _buildRecommendationCards() {
    final recommendations = [
      if (data['aiInsight1'] != null)
        _RecommendationData(
          'Estimated Time to Ripeness',
          data['aiInsight1'],
          Icons.timer_rounded,
          Colors.orange,
        ),
      if (data['aiInsight2'] != null)
        _RecommendationData(
          'Estimated Time to Spoil',
          data['aiInsight2'],
          Icons.visibility_rounded,
          Colors.blue,
        ),
      if (data['aiInsight3'] != null)
        _RecommendationData(
          'Quality Grading',
          data['aiInsight3'],
          Icons.people_outlined,
          Colors.amber,
        ),
      if (data['aiInsight4'] != null)
        _RecommendationData(
          'Storage and Sorting ',
          data['aiInsight4'],
          Icons.grade_outlined,
          Colors.teal,
        ),
      if (data['aiInsight5'] != null)
        _RecommendationData(
          'Storage and Sorting',
          data['aiInsight5'],
          Icons.kitchen_rounded,
          Colors.green,
        ),
    ];

    return Column(
      children: recommendations
          .map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ModernInfoCard(
                  icon: rec.icon,
                  title: rec.title,
                  content: rec.content,
                  color: rec.color,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildNoAiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'AI analysis not available for this item.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationData {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  _RecommendationData(this.title, this.content, this.icon, this.color);
}

/// Modern info card with enhanced styling
class ModernInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const ModernInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern nutrition button with gradient
class ModernNutritionButton extends StatelessWidget {
  final String? fruitName;
  final String? username;

  const ModernNutritionButton({
    super.key,
    required this.fruitName,
    this.username,
  });

  @override
  Widget build(BuildContext context) {
    if (fruitName == null ||
        fruitName!.isEmpty ||
        fruitName!.toLowerCase() == 'unknown') {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.teal.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NutritionFactsScreen(
                  fruitName: fruitName!,
                  userId: username ?? '',
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            'Nutrition Facts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }
}
