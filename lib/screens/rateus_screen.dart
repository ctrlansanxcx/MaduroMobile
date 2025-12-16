import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  _RateUsScreenState createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen>
    with TickerProviderStateMixin {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _saveRatingAndReview() async {
    if (_rating == 0) {
      _showCustomSnackBar(
        'Please give a rating before submitting.',
        Colors.orange.shade400,
        Icons.warning_rounded,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> ratingData = {
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (currentUser != null) {
        ratingData['uid'] = currentUser.uid;
        ratingData['email'] = currentUser.email ?? '';
        ratingData['username'] = currentUser.displayName ?? 'Anonymous';
      } else {
        ratingData['uid'] = 'anonymous';
        ratingData['email'] = '';
        ratingData['username'] = 'Anonymous';
      }

      // ignore: unused_local_variable
      DocumentReference docRef =
          await _firestore.collection('ratings').add(ratingData);

      _showCustomSnackBar(
        'Thank you for rating us $_rating stars! ⭐',
        const Color(0xFF4CAF50),
        Icons.check_circle_rounded,
      );

      _reviewController.clear();
      setState(() {
        _rating = 0;
      });
    } catch (e) {
      _showCustomSnackBar(
        'Error: ${e.toString()}',
        Colors.red.shade400,
        Icons.error_rounded,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB5DB49),
              Color(0xFFEAD938),
              Color(0xFFF5EE62),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact Header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 28,
                        color: Color(0xFFFFD54F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Rate Our App",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your feedback helps us improve",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        // Compact Emoji feedback
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildEmojiForRating(_rating),
                        ),

                        const SizedBox(height: 16),

                        // Question
                        const Text(
                          'How was your experience?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Compact Star Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9C4).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFD54F).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 32,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, index) => AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: index < _rating
                                    ? _scaleAnimation.value
                                    : 1.0,
                                child: Icon(
                                  index < _rating
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: const Color(0xFFFFD54F),
                                ),
                              ),
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                              _animationController.forward().then((_) {
                                _animationController.reverse();
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Compact Review Text Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _reviewController,
                            decoration: InputDecoration(
                              hintText: 'Tell us about your experience...',
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: Icon(
                                Icons.edit_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Compact Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveRatingAndReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isLoading
                                  ? Colors.grey.shade300
                                  : const Color(0xFF66BB6A),
                              foregroundColor: Colors.white,
                              elevation: _isLoading ? 0 : 6,
                              shadowColor:
                                  const Color(0xFF66BB6A).withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.grey.shade600,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Submitting...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send_rounded, size: 18),
                                      SizedBox(width: 6),
                                      Text(
                                        'Submit Review',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiForRating(double rating) {
    String emoji;
    Color color;

    if (rating == 0) {
      emoji = '😊';
      color = Colors.grey.shade400;
    } else if (rating <= 2) {
      emoji = '😔';
      color = Colors.red.shade300;
    } else if (rating <= 3) {
      emoji = '😐';
      color = Colors.orange.shade300;
    } else if (rating <= 4) {
      emoji = '😊';
      color = const Color(0xFFFFD54F);
    } else {
      emoji = '🤩';
      color = const Color(0xFF66BB6A);
    }

    return Container(
      key: ValueKey(rating),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}
