import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maduro/history/details_screen.dart';

class HistoryTile extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onDelete;
  final int index;

  const HistoryTile({
    super.key,
    required this.data,
    this.onDelete,
    this.index = 0,
  });

  @override
  State<HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<HistoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.data['timestamp']?.toDate();
    final date = timestamp != null
        ? DateFormat('MMM d, yyyy').format(timestamp)
        : 'Unknown';
    final time =
        timestamp != null ? DateFormat('h:mm a').format(timestamp) : '';

    final fruitImage = widget.data['imageUrl']?.toString() ?? '';

    final ripenessLabel = widget.data['detectedRipeness']?.toString() ??
        widget.data['ripenessLabel']?.toString() ??
        widget.data['calculatedRipenessLabel']?.toString() ??
        'Unknown';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dismissible(
            key: Key(widget.data['timestamp'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.delete_forever,
                  color: Colors.white, size: 36),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    title: Row(
                      children: const [
                        Icon(Icons.warning_rounded,
                            color: Colors.orange, size: 28),
                        SizedBox(width: 12),
                        Text("Confirm Deletion",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: const Text(
                      "Are you sure you want to delete this history item? This action cannot be undone.",
                      style: TextStyle(fontSize: 15),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel",
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          elevation: 4,
                        ),
                        child: const Text("Delete",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            child: AnimatedScale(
              scale: _isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _getRipenessGradient(ripenessLabel)[0]
                          .withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTapDown: (_) => setState(() => _isPressed = true),
                      onTapUp: (_) => setState(() => _isPressed = false),
                      onTapCancel: () => setState(() => _isPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    HistoryDetailsScreen(data: widget.data),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                ),
                              );
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      splashColor: Colors.white.withOpacity(0.2),
                      highlightColor: Colors.white.withOpacity(0.1),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getRipenessGradient(ripenessLabel),
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Animated fruit image
                            Hero(
                              tag: 'fruit_${widget.data['timestamp']}',
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                height: MediaQuery.of(context).size.width * 0.2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: _buildFruitImage(fruitImage),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),

                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ripeness badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      ripenessLabel.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Date and time
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            date,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          if (time.isNotEmpty)
                                            Text(
                                              time,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Animated arrow
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      _isPressed ? -4 : (1 - value) * 10, 0),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Fruit image with fallback
  Widget _buildFruitImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.eco, color: Colors.white, size: 32);
        },
      );
    }
    return const Icon(Icons.eco, color: Colors.white, size: 32);
  }

  /// Get gradient based on ripeness state
  List<Color> _getRipenessGradient(String ripeness) {
    switch (ripeness.toLowerCase()) {
      case 'unripe':
        return [
          const Color(0xFF66BB6A),
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
        ];
      case 'ripe':
        return [
          const Color(0xFFFFD54F),
          const Color(0xFFFFB300),
          const Color(0xFFF57C00),
        ];
      case 'rotten':
        return [
          const Color(0xFF8D6E63),
          const Color(0xFF6D4C41),
          const Color(0xFF4E342E),
        ];
      default:
        return [
          const Color(0xFFAED158),
          const Color(0xFFD4E157),
          const Color(0xFFEEFF41),
        ];
    }
  }
}

// Enhanced History Screen with animated header
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFF8F9FA),
              const Color(0xFFE8F5E9).withOpacity(0.3),
              const Color(0xFFFFFDE7).withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(110.0),
              child: ScaleTransition(
                scale: _headerAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFAED158),
                        Color(0xFFD4E157),
                        Color(0xFFEEFF41),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFAED158).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: const Icon(
                                    Icons.history_rounded,
                                    color: Colors.white,
                                    size: 32,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black26,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "HISTORY",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3.0,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black38,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                itemCount: 2, // Replace with actual data length
                itemBuilder: (context, index) {
                  return HistoryTile(
                    index: index,
                    data: index == 0
                        ? {
                            'timestamp': null,
                            'imageUrl': '',
                            'detectedRipeness': 'Unripe',
                          }
                        : {
                            'timestamp': null,
                            'imageUrl': '',
                            'detectedRipeness': 'Ripe',
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
