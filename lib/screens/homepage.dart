import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../service/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // MARK: - Properties
  final AuthService _auth = AuthService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Carousel content
  final List<String> _imageList = [
    'assets/images/image1.jpg',
    'assets/images/image2.jpg',
    'assets/images/image3.jpg',
  ];

  // Description text rotation
  late Timer _textTimer;
  int _currentTextIndex = 0;
  final List<String> _descriptions = [
    'Your intelligent fruit ripeness detector. Whether you are shopping, harvesting, or sorting fruits for donation.',
    'Maduro helps you determine the optimal ripeness of various fruits using advanced image processing technology.',
    'By analyzing visual cues in real-time, Maduro reduces food waste and helps you choose fruit at its peak.',
    'Discover smarter, fresher decisions with Maduro—because timing is everything when it comes to fruit.'
  ];

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startTextRotation();
  }

  @override
  void dispose() {
    _textTimer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // MARK: - Animation Methods
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  // MARK: - Helper Methods
  void _startTextRotation() {
    _textTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _descriptions.length;
        });
      }
    });
  }

  Future<void> _signInAsGuest(BuildContext context) async {
    final result = await _auth.signInAnon(firstName: '', lastName: '');

    if (!context.mounted) return;

    if (result == null) {
      _showErrorMessage(context, 'Anonymous sign-in failed');
    } else {
      Navigator.pushNamed(context, '/guestuser');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // MARK: - UI Components
  Widget _buildModernLogo(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.yellow.shade300.withOpacity(0.9),
            Colors.lightGreen.shade400.withOpacity(0.9),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(size * 0.15),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/icons/appicon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCard({
    required Widget child,
    // ignore: unused_element_parameter
    double blur = 15.0,
    double opacity = 0.1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(opacity),
            Colors.white.withOpacity(opacity * 0.5),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDescriptionText(String text, double fontSize) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Text(
        text,
        key: ValueKey<int>(_currentTextIndex),
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w300,
          height: 1.5,
          letterSpacing: 0.5,
          shadows: [
            Shadow(
              offset: const Offset(0.0, 2.0),
              blurRadius: 8.0,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String text,
    required VoidCallback onPressed,
    required Gradient gradient,
    required double fontSize,
    required EdgeInsets padding,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: fontSize * 0.9),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Main Build Method
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Enhanced Background Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 8),
              autoPlayAnimationDuration: const Duration(milliseconds: 1200),
              autoPlayCurve: Curves.easeInOutCubic,
            ),
            items: _imageList.map((imagePath) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.35),
                      BlendMode.darken,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Modern Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
            height: height,
            width: width,
          ),

          // Animated App Logo
          Positioned(
            top: height * 0.08,
            left: width * 0.06,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildModernLogo(width * 0.15),
            ),
          ),

          // Main Content
          Positioned(
            bottom: height * 0.08,
            left: width * 0.05,
            right: width * 0.05,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildGlassmorphicCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Modern App Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.yellow.shade300,
                            Colors.lightGreen.shade400,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'MADURO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width * 0.14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            shadows: [
                              Shadow(
                                offset: const Offset(0.0, 4.0),
                                blurRadius: 12.0,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Description Text with Enhanced Animation
                      SizedBox(
                        height: height * 0.12,
                        child: _buildDescriptionText(
                          _descriptions[_currentTextIndex],
                          width * 0.042,
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      // Modern Action Buttons
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernButton(
                                  text: 'Log In',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/login'),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.lightGreen.shade600,
                                      Colors.lightGreen.shade700,
                                    ],
                                  ),
                                  fontSize: width * 0.042,
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.018),
                                  icon: Icons.login_rounded,
                                ),
                              ),
                              SizedBox(width: width * 0.04),
                              Expanded(
                                child: _buildModernButton(
                                  text: 'Sign Up',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/signup'),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.yellow.shade600,
                                      Colors.yellow.shade700,
                                    ],
                                  ),
                                  fontSize: width * 0.042,
                                  padding: EdgeInsets.symmetric(
                                      vertical: height * 0.018),
                                  icon: Icons.person_add_rounded,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: height * 0.015),
                          SizedBox(
                            width: double.infinity,
                            child: _buildModernButton(
                              text: 'Continue as Guest',
                              onPressed: () => _signInAsGuest(context),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade700,
                                  Colors.grey.shade800,
                                ],
                              ),
                              fontSize: width * 0.042,
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.018),
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
