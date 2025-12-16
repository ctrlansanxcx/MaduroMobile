import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signout_widget.dart';
import 'edit_profile.dart';

class SignOutScreen extends StatefulWidget {
  const SignOutScreen({super.key});

  @override
  State<SignOutScreen> createState() => _SignOutScreenState();
}

class _SignOutScreenState extends State<SignOutScreen>
    with TickerProviderStateMixin {
  final _controller = UserProfileController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  // Theme colors
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _surfaceColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1A202C);
  static const Color _textSecondary = Color(0xFF718096);
  static const Color _primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _slideController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _controller.fetchUserData(() => setState(() {}));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  PreferredSize _buildModernAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(160.0),
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
              children: [
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
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

  Widget _buildCurrentUserSection() {
    final user = _controller.user;
    if (user == null) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const EditProfilePage(),
                        transitionsBuilder: (_, anim, __, child) =>
                            SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero)
                              .animate(anim),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
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
                            child: user.photoURL != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.network(
                                      user.photoURL!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: _primaryColor,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? _controller.getFullName(),
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email ?? "No email",
                                style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text("Tap to edit profile",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        // Check mark
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.user;
    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(
          child: Text("No user signed in",
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildModernAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildCurrentUserSection(),
              const SizedBox(height: 40),
              SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Information',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800)),
                      const SizedBox(height: 4),
                      Text('Your personal details and preferences',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600)),
                      const SizedBox(height: 24),
                      buildModernCard(
                        icon: Icons.fingerprint,
                        label: "User ID",
                        value: "${user.uid.substring(0, 8)}...",
                        gradient: const [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                      ),
                      const SizedBox(height: 16),
                      buildModernCard(
                        icon: Icons.alternate_email,
                        label: "Email Address",
                        value: user.email ?? "No email",
                        gradient: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      const SizedBox(height: 16),
                      buildModernCard(
                        icon: Icons.person_4,
                        label: "Full Name",
                        value: _controller.getFullName(),
                        gradient: const [Color(0xFFA0C334), Color(0xFFE5D429)],
                      ),
                      const SizedBox(height: 40),
                      Text('Quick Actions',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800)),
                      const SizedBox(height: 24),
                      // Sign Out button
                      Row(
                        children: [
                          Expanded(
                            child: buildModernActionButton(
                              icon: Icons.logout_rounded,
                              label: "Sign Out",
                              colors: const [
                                Color(0xFFFF6B6B),
                                Color(0xFFEE5A24)
                              ],
                              onPressed: () => _showSignOutDialog(context),
                              isLoading: _isSigningOut,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Delete Account button - now also full width
                      Row(
                        children: [
                          Expanded(
                            child: buildModernActionButton(
                              icon: Icons.delete_forever_rounded,
                              label: "Delete Account",
                              colors: const [
                                Color(0xFFDC3545),
                                Color(0xFFBD2130)
                              ],
                              onPressed: () =>
                                  _showDeleteAccountDialog(context),
                              isLoading: _isDeletingAccount,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialogs & Deletion logic remain exactly the same as your original code
  Future<void> _showSignOutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFFF6B6B)),
            SizedBox(width: 12),
            Text('Sign Out')
          ],
        ),
        content:
            const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600))),
          TextButton(
            style:
                TextButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B)),
            onPressed: () {
              Navigator.of(context).pop();
              _signOut(context);
            },
            child:
                const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    setState(() => _isSigningOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to sign out'), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isSigningOut = false);
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFDC3545)),
            SizedBox(width: 12),
            Text('Delete Account')
          ],
        ),
        content: const Text(
            'Are you sure? This will permanently delete your account and all associated data including ratings, reviews, uploads, and history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600))),
          TextButton(
            style:
                TextButton.styleFrom(backgroundColor: const Color(0xFFDC3545)),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccount(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    setState(() => _isDeletingAccount = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No user signed in to delete.'),
            backgroundColor: Colors.red));
      }
      setState(() => _isDeletingAccount = false);
      return;
    }

    try {
      final userId = user.uid;
      print('Starting account deletion for user: $userId');

      // Delete collections one by one as in original code
      try {
        final ratings = await FirebaseFirestore.instance
            .collection('ratings')
            .where('uid', isEqualTo: userId)
            .get();
        for (var doc in ratings.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        final reviews = await FirebaseFirestore.instance
            .collection('reviews')
            .where('uid', isEqualTo: userId)
            .get();
        for (var doc in reviews.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        final uploads = await FirebaseFirestore.instance
            .collection('uploads')
            .where('userId', isEqualTo: userId)
            .get();
        for (var doc in uploads.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        final historyByUid = await FirebaseFirestore.instance
            .collection('history')
            .where('uid', isEqualTo: userId)
            .get();
        for (var doc in historyByUid.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        final historyByUserId = await FirebaseFirestore.instance
            .collection('history')
            .where('userId', isEqualTo: userId)
            .get();
        for (var doc in historyByUserId.docs) {
          await doc.reference.delete();
        }
      } catch (_) {}
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();
      } catch (_) {}

      await user.delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Account and all data deleted successfully!'),
            backgroundColor: Colors.green));
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.code == 'requires-recent-login'
          ? 'Please sign out and sign in again, then try deleting your account.'
          : 'Authentication error: ${e.message}';
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }
}
