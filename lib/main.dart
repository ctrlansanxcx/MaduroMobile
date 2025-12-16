// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Make sure this is imported early
import 'package:maduro/aichatbot/aichatbot.dart';
import 'package:maduro/aichatbot/aichatbot_screen.dart';
import 'package:maduro/authetication/signout_screen.dart';

import 'package:maduro/firebase_options.dart';
import 'package:maduro/guest/guestprofile.dart';
import 'package:maduro/guest/guestuser.dart';
import 'package:maduro/history/history_screen.dart';
import 'package:maduro/screens/about_screen.dart';
import 'package:maduro/screens/detection_landing_page.dart';
import 'package:maduro/screens/forgotpassword_screen.dart';
import 'package:maduro/screens/home_screen.dart';
import 'package:maduro/screens/homepage.dart';
import 'package:maduro/screens/language_screen.dart';
import 'package:maduro/authetication/login_screen.dart';
import 'package:maduro/screens/nutrition_facts.dart';
import 'package:maduro/screens/privacy_policy_screen.dart';
import 'package:maduro/screens/profile_screen.dart';
import 'package:maduro/screens/rateus_screen.dart';
import 'package:maduro/screens/shareapp_screen.dart';
import 'package:maduro/authetication/signup_screen.dart';
import 'package:maduro/screens/termconditon_screen.dart';
import 'package:maduro/service/auth.dart';
import 'package:maduro/wrapper.dart'; // Ensure this file exists
import 'package:provider/provider.dart';
import 'camera/upload.dart';
import 'camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Must be first

  try {
    // Try loading the .env
    await dotenv.load(fileName: ".env");
    print(".env file loaded successfully.");
  } catch (e) {
    // If .env is missing, print a warning but do NOT crash
    print(
        "Warning: .env file not found. Proceeding without environment variables.");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    cameras = await availableCameras();

    runApp(const MyApp());
  } catch (e) {
    print("Initialization Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print("User is signed in: ${user.uid}");
      } else {
        print("User is signed out");
      }
    });

    return StreamProvider<User?>.value(
      value: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Wrapper(),
        routes: {
          '/homescreen': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/detectionLandingPage': (context) => DetectionLandingPage(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
          '/language': (context) => const LanguageScreen(),
          '/about': (context) => const AboutScreen(),
          '/tnc': (context) => const TermConditionScreen(),
          '/privacypolicy': (context) => const PrivacyPolicyScreen(),
          '/rateus': (context) => const RateUsScreen(),
          '/shareapp': (context) => const ShareAppScreen(),
          '/forgotpassword': (context) => const ForgotPasswordScreen(),
          '/guestuser': (context) => const GuestUser(),
          '/guestprofile': (context) => const GuestProfile(),
          '/signout': (context) => const SignOutScreen(),
          '/homepage': (context) => HomePage(),
          '/upload': (context) => UploadPage(),
          '/camerapage': (context) => CameraPage(),
          '/aichatbot': (context) => AIChatBotScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}
