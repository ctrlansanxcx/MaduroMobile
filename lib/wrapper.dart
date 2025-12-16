import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:maduro/screens/home_screen.dart';
import 'package:maduro/screens/homepage.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User?>(context); // Firebase User

    if (firebaseUser == null) {
      return HomePage(); // Not logged in
    } else {
      return const HomeScreen(); // Logged in
    }
  }
}
