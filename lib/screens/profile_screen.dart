import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/bottom_navbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  static const int _profileTabIndex = 2;
  int _selectedIndex = _profileTabIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Theme colors
  static const Color _primaryColor = Color(0xFFB5DB49);
  static const Color _secondaryColor = Color(0xFFF5EE62);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1A202C);
  static const Color _textSecondary = Color(0xFF718096);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/detectionLandingPage');
        break;
      case 1:
        Navigator.pushNamed(context, '/history');
        break;
      case 2:
        // Already on profile page
        break;
    }
  }

  PreferredSize _buildModernAppBar({required String title}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(180.0),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB5DB49),
              Color(0xFFEAD938),
              Color(0xFFF5EE62),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACCOUNT',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Manage your account settings',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSelectionSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final bool hasUser = snapshot.hasData;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: hasUser
                  ? () {
                      Navigator.pushNamed(context, '/signout');
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          hasUser && snapshot.data?.photoURL != null
                              ? Icons.person
                              : Icons.person_outline,
                          size: 40,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isLoading)
                            _buildShimmerText(width: 120)
                          else if (hasUser)
                            Text(
                              _getUserDisplayText(snapshot.data!),
                              style: const TextStyle(
                                color: _textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: hasUser && !snapshot.data!.isAnonymous
                                      ? Colors.green
                                      : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasUser && !snapshot.data!.isAnonymous
                                    ? "Active User"
                                    : "Signed in as guest",
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerText({required double width}) {
    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  String _getUserDisplayText(User user) {
    if (user.isAnonymous) return "Guest User";
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user.email != null) return user.email!;
    return "User-${user.uid.substring(0, 6)}";
  }

  Widget _buildModernSection(String title, List<ModernSettingItem> items) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 10),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: items
                    .asMap()
                    .entries
                    .map((entry) => _buildModernTile(
                        entry.value, entry.key == items.length - 1))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTile(ModernSettingItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.route == '/signout') {
            _showSignOutDialog();
          } else {
            Navigator.pushNamed(context, item.route);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: item.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: item.gradientColors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      item.icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        if (item.subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            item.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: _textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sign Out Dialog with app gradient
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB5DB49),
                      Color(0xFFEAD938),
                      Color(0xFFF5EE62),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Confirm Sign Out",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Are you sure you want to sign out?",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Sign Out",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final generalSettings = [
      ModernSettingItem(
        icon: Icons.language_rounded,
        gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
        title: "Language",
        subtitle: "Choose your preferred language",
        route: '/language',
      ),
      ModernSettingItem(
        icon: Icons.info_outline_rounded,
        gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
        title: "About",
        subtitle: "Learn more about the app",
        route: '/about',
      ),
      ModernSettingItem(
        icon: Icons.description_outlined,
        gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        title: "Terms & Conditions",
        subtitle: "Read our terms of service",
        route: '/tnc',
      ),
    ];

    final appSettings = [
      ModernSettingItem(
        icon: Icons.lock_outline_rounded,
        gradientColors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
        title: "Privacy Policy",
        subtitle: "How we protect your data",
        route: '/privacypolicy',
      ),
      ModernSettingItem(
        icon: Icons.star_outline_rounded,
        gradientColors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
        title: "Rate This App",
        subtitle: "Share your experience",
        route: '/rateus',
      ),
      ModernSettingItem(
        icon: Icons.share_outlined,
        gradientColors: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
        title: "Share This App",
        subtitle: "Invite your friends",
        route: '/shareapp',
      ),
    ];

    final accountSettings = [
      ModernSettingItem(
        icon: Icons.logout_rounded,
        gradientColors: [const Color(0xFFff6b6b), const Color(0xFFfeca57)],
        title: "Sign Out",
        subtitle: "Logout from your account",
        route: '/signout',
      ),
    ];

    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      appBar: _buildModernAppBar(title: 'PROFILE'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildCurrentSelectionSection(),
                  _buildModernSection("General Settings", generalSettings),
                  _buildModernSection("App Settings", appSettings),
                  _buildModernSection("Account", accountSettings),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data Model
class ModernSettingItem {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String? subtitle;
  final String route;

  const ModernSettingItem({
    required this.icon,
    required this.gradientColors,
    required this.title,
    this.subtitle,
    required this.route,
  });
}
