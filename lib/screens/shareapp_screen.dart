import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  // App details
  static const String appUrl =
      'https://appdistribution.firebase.dev/i/f9a3539ad09d4e84';
  static const String appName = 'Amazing App';
  static const String shareMessage = 'Check out this amazing app!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
              // Modern Header
              Container(
                margin: const EdgeInsets.all(16),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Share App",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "Spread the love with friends",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFB5DB49),
                                Color(0xFFEAD938),
                                Color(0xFFF5EE62),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF81C784).withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Main message
                        const Text(
                          'Love this app?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Share it with your friends and help us grow our community!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Share buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Primary share button
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _shareApp(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFB5DB49),
                                        Color(0xFFEAD938),
                                        Color(0xFFF5EE62),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF81C784)
                                            .withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.share_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Share Now',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Secondary share options
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSocialButton(
                              icon: Icons.message_rounded,
                              label: "Message",
                              onTap: () => _shareViaMessages(context),
                            ),
                            _buildSocialButton(
                              icon: Icons.email_rounded,
                              label: "Email",
                              onTap: () => _shareViaEmail(context),
                            ),
                            _buildSocialButton(
                              icon: Icons.link_rounded,
                              label: "Copy Link",
                              onTap: () => _copyLink(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Thank you message
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4C3).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF81C784).withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite,
                                color: Color(0xFF689F38),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Thank you for sharing!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4A7C59),
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
            ],
          ),
        ),
      ),
    );
  }

  // Share app with general share sheet
  Future<void> _shareApp(BuildContext context) async {
    try {
      final result = await Share.share(
        '$shareMessage\n\n$appUrl',
        subject: appName,
      );

      if (result.status == ShareResultStatus.success) {
        _showSuccessSnackBar(context, 'Shared successfully!');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to share. Please try again.');
    }
  }

  // Share via messaging apps
  Future<void> _shareViaMessages(BuildContext context) async {
    try {
      final result = await Share.share(
        '$shareMessage\n\n$appUrl',
        subject: appName,
      );

      if (result.status == ShareResultStatus.success) {
        _showSuccessSnackBar(context, 'Shared via message!');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to open messaging app.');
    }
  }

  // Share via email
  Future<void> _shareViaEmail(BuildContext context) async {
    try {
      final result = await Share.share(
        '$shareMessage\n\nDownload here: $appUrl',
        subject: 'Check out $appName!',
      );

      if (result.status == ShareResultStatus.success) {
        _showSuccessSnackBar(context, 'Email draft created!');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to open email app.');
    }
  }

  // Copy link to clipboard
  Future<void> _copyLink(BuildContext context) async {
    try {
      await Clipboard.setData(const ClipboardData(text: appUrl));
      _showSuccessSnackBar(context, 'Link copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to copy link.');
    }
  }

  // Success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF689F38),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
