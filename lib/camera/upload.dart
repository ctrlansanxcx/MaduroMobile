// lib/pages/upload_page.dart - ALIGNED AND SIMPLIFIED
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maduro/result/result_screen.dart';
import 'package:maduro/service/banana_detector.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isLoading = false;
  bool _hasError = false;
  String _statusMessage = "Initializing...";

  BananaRipenessDetector? _detector;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _initializeAndPickImage());
  }

  Future<void> _initializeAndPickImage() async {
    try {
      setState(() {
        _statusMessage = "Loading AI model...";
      });

      _detector = BananaRipenessDetector();
      await _detector!.loadModel();

      setState(() {
        _statusMessage = "Opening Gallery...";
      });

      await pickImage();
    } catch (e) {
      showError("Failed to initialize: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // Optimize image size
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      File file = File(image.path);
      await analyzeImage(file);
    } else {
      Navigator.pop(context); // Go back if user cancels
    }
  }

  Future<void> analyzeImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusMessage = "Analyzing image...";
    });

    try {
      final response = await _detector!.predictImage(imageFile);

      if (response['success'] == true) {
        final basicAnalysis = response['basic_analysis'];
        final fruit = basicAnalysis['fruit'];
        final ripeness = basicAnalysis['ripeness_status'];
        final confidence = response['confidence'] ?? 0.0;

        print('Upload Analysis Results:');
        print('  Fruit: $fruit');
        print('  Ripeness: $ripeness');
        print('  Confidence: ${(confidence * 100).toStringAsFixed(1)}%');

        // SIMPLIFIED: Navigate with model's results directly
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                imageFile: imageFile,
                fruit: fruit,
                ripeness: ripeness,
                confidenceScores: Map<String, dynamic>.from(
                    basicAnalysis['confidence_scores']),
                imageDimensions: Map<String, dynamic>.from(
                    basicAnalysis['image_dimensions']),
                imagePath: '',
              ),
            ),
          );
        }
      } else {
        showError(response['error'] ?? 'Analysis failed');
      }
    } catch (e) {
      showError("Analysis error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showError(String message) {
    setState(() {
      _hasError = true;
      _statusMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
    ));

    // Return to previous screen after showing error
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _detector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading && !_hasError) ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Please wait while we process your image...",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ] else if (_hasError) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                Text(
                  "Analysis Failed",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Returning to previous screen...",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
