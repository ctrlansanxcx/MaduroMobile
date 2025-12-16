import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'weather_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getStorageFolder(String fruit) {
    fruit = fruit.toLowerCase();
    if (fruit.contains("apple")) return "apple";
    if (fruit.contains("banana")) return "banana";
    return "unknown";
  }

  /// Uploads an image file to Firebase Storage and returns its download URL
  Future<String?> uploadImageToStorage(File imageFile, String fruit) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint("No user logged in, cannot upload image.");
        return null;
      }

      final String userId = currentUser.uid;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String safeFolder = _getStorageFolder(fruit);

      if (safeFolder == "unknown") {
        debugPrint("Unsupported fruit type for storage: '$fruit'");
        return null;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child(safeFolder)
          .child(userId)
          .child(fileName);

      debugPrint("Uploading to: ${storageRef.fullPath}");

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e, stack) {
      debugPrint("Error uploading image to Firebase Storage: $e\n$stack");
      return null;
    }
  }

  Future<Map<String, dynamic>> saveHistoryRecord({
    required String fruit,
    required String detectedRipeness,
    required Map<String, dynamic> confidenceScores,
    required Map<String, dynamic> imageDimensions,
    required bool saveAiInsights,
    required String? aiInsight1,
    required String? aiInsight2,
    required String? aiInsight3,
    required String? aiInsight4,
    required String? aiInsight5, // Keep parameter for backward compatibility
    required String? aiError,
    required Map<String, String>? nutritionFacts,
    String? imageUrl,
    WeatherData? weatherData,
  }) async {
    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return {
        'success': false,
        'error': "User not logged in. Cannot save history."
      };
    }

    final String userId = currentUser.uid;
    final String email = currentUser.email ?? "No email";
    final String username = currentUser.displayName ?? "No name";
    final Timestamp timestamp = Timestamp.now();

    // Base data structure
    Map<String, dynamic> data = {
      'timestamp': timestamp,
      'userId': userId,
      'email': email,
      'username': username,
      'imageUrl': imageUrl ?? "",
      'imageDimensions': imageDimensions,
      'fruit': fruit,
      'detectedRipeness': detectedRipeness,
      'confidenceScores': confidenceScores,
      'aiAnalysisStatus': saveAiInsights
          ? (aiError == null ? 'Success' : 'Failed: $aiError')
          : 'Not Attempted',
    };

    // Add weather data if available
    if (weatherData != null) {
      data['weatherData'] = {
        'temperature': weatherData.temperature,
        'humidity': weatherData.humidity,
        'location': weatherData.location,
        'timestamp': Timestamp.fromDate(weatherData.timestamp),
        'windSpeed': weatherData.windSpeed ?? 'N/A',
        'weatherDescription': weatherData.weatherDescription ?? 'N/A',
        'conditionDescription': weatherData.conditionDescription,
      };

      // Calculate and store business estimates
      final estimates = BananaRipeningCalculator.getDetailedEstimates(
        detectedRipeness,
        weatherData.temperature,
        weatherData.humidity,
      );

      data['businessEstimates'] = {
        'daysToRipe': estimates['daysToRipe'],
        'daysToSpoil': estimates['daysToSpoil'],
        'speedFactor': estimates['speedFactor'],
        'urgencyLevel': estimates['urgencyLevel'],
        'businessAction': estimates['businessAction'],
        'priceStrategy': estimates['priceStrategy'],
      };
    }

    // UPDATED: Add AI insights if successfully fetched (only 4 now, not 5)
    // aiInsight1 = Estimated Time to Ripeness
    // aiInsight2 = Estimated Time to Spoil
    // aiInsight3 = Quality Grading
    // aiInsight4 = Storage and Sorting
    // aiInsight5 = REMOVED (was Customer Targeting)
    if (saveAiInsights && aiError == null) {
      data.addAll({
        'aiInsight1': aiInsight1,
        'aiInsight2': aiInsight2,
        'aiInsight3': aiInsight3,
        'aiInsight4': aiInsight4,
        // Note: aiInsight5 is intentionally NOT saved anymore
      });
    }

    // Add nutrition facts if available
    if (nutritionFacts != null && nutritionFacts.isNotEmpty) {
      data['nutritionFacts'] = nutritionFacts;
    }

    try {
      await _firestore.collection('history').add(data);
      debugPrint(
          '✅ History saved successfully with 4 AI insights (removed customer targeting)');
      return {'success': true};
    } catch (e) {
      debugPrint('❌ Error saving to Firestore: $e');
      return {'success': false, 'error': "Error saving to Firestore: $e"};
    }
  }
}
