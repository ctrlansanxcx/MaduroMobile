// lib/pages/camera_page.dart - CLEANED UP AND ALIGNED
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:maduro/result/result_screen.dart';
import 'package:maduro/service/banana_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

enum AspectRatioType { ratio2x3, ratio4x5 }

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isDetecting = false;
  bool _isLoading = false;
  bool _hasError = false;
  Timer? _detectionTimer;
  String _statusMessage = "Loading model...";
  AspectRatioType _selectedRatio = AspectRatioType.ratio2x3;

  Map<String, dynamic>? _detectionResults;
  bool _objectDetected = false;

  // TFLite detector instance
  BananaRipenessDetector? _detector;
  bool _modelLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    try {
      _detector = BananaRipenessDetector();
      await _detector!.loadModel();

      setState(() {
        _modelLoaded = true;
        _statusMessage = "Ready - Point camera at fruit";
      });

      initCamera();
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusMessage = "Model loading failed: $e";
      });
    }
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        await showSnackBar("No cameras available.");
        setState(() => _hasError = true);
        return;
      }

      final camera = cameras.first;
      _controller = CameraController(camera, ResolutionPreset.high);
      await _controller!.initialize();

      if (!mounted) return;
      setState(() {});
      _startDetectionLoop();
    } catch (e) {
      await showSnackBar("Camera initialization failed: $e");
      setState(() => _hasError = true);
    }
  }

  void _startDetectionLoop() {
    if (!_modelLoaded) return;

    _detectionTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted && !_isLoading && _modelLoaded && !_isDetecting) {
        detectAndCapture();
      }
    });
  }

  Future<void> detectAndCapture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isDetecting ||
        !_modelLoaded) {
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    try {
      final file = await _takePictureForDetection();
      if (file != null) {
        await performDetection(file);
      }
    } catch (e) {
      print('Detection error: $e');
      setState(() {
        _isDetecting = false;
        _statusMessage = "Detection failed. Trying again...";
      });
    }
  }

  Future<File?> _takePictureForDetection() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path,
        "detection_${DateTime.now().millisecondsSinceEpoch}.jpg");

    try {
      final XFile? file = await _controller?.takePicture();
      if (file == null) return null;
      await file.saveTo(filePath);
      return File(filePath);
    } catch (_) {
      return null;
    }
  }

  // SIMPLIFIED: Clean detection logic aligned with model
  Future<void> performDetection(File imageFile) async {
    try {
      final response = await _detector!.predictImage(imageFile);

      if (response['success'] == true) {
        final basicAnalysis = response['basic_analysis'];
        final fruit = basicAnalysis['fruit'] ?? 'unknown';
        final ripeness = basicAnalysis['ripeness_status'] ?? 'Unknown';
        final confidence = response['confidence'] ?? 0.0;

        print('🔍 Detection Results:');
        print('  Fruit: $fruit');
        print('  Ripeness: $ripeness');
        print('  Confidence: ${(confidence * 100).toStringAsFixed(1)}%');

        // SIMPLIFIED: Use model's decision directly
        // If confidence is good enough, capture
        if (confidence > 0.4) {
          // Lowered threshold for better capture rate
          _detectionResults = response;
          setState(() {
            _objectDetected = true;
            if (fruit == 'unknown') {
              _statusMessage = "Unknown object detected! Capturing...";
            } else {
              _statusMessage = "Banana detected! Capturing...";
            }
          });

          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            _captureAndSave();
          }
        } else {
          setState(() {
            _objectDetected = false;
            _statusMessage = "Looking for objects...";
            _isDetecting = false;
          });
        }
      } else {
        setState(() {
          _statusMessage = "Detection error. Trying again...";
          _isDetecting = false;
        });
      }
    } catch (e) {
      print('Detection error: $e');
      setState(() {
        _statusMessage = "Detection failed. Trying again...";
        _isDetecting = false;
      });
    } finally {
      // Clean up temp file
      try {
        await imageFile.delete();
      } catch (_) {}
    }
  }

  Future<void> _captureAndSave() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Processing...";
    });

    try {
      final file = await _takeFinalPicture();
      if (file != null) {
        // Save to gallery
        await ImageGallerySaverPlus.saveFile(
          file.path,
          name: "Maduro_capture_${DateTime.now().millisecondsSinceEpoch}.jpg",
          isReturnPathOfIOS: true,
        );

        if (_detectionResults != null && mounted) {
          final basicAnalysis = _detectionResults!['basic_analysis'];

          // CLEANED UP: Use model results directly, no overriding
          final fruit = basicAnalysis['fruit'];
          final ripeness = basicAnalysis['ripeness_status'];
          final confidence = _detectionResults!['confidence'] ?? 0.0;

          print('📤 Navigating to results:');
          print('  Final Fruit: $fruit');
          print('  Final Ripeness: $ripeness');
          print('  Confidence: ${(confidence * 100).toStringAsFixed(1)}%');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                imageFile: file,
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
      }
    } catch (e) {
      await showSnackBar("Capture failed: $e");
      setState(() {
        _isLoading = false;
        _statusMessage = "Capture failed. Trying again...";
        _isDetecting = false;
      });
    }
  }

  Future<File?> _takeFinalPicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    final directory = await getTemporaryDirectory();
    final filePath = path.join(
        directory.path, "final_${DateTime.now().millisecondsSinceEpoch}.jpg");

    try {
      final XFile? file = await _controller?.takePicture();
      if (file == null) return null;
      await file.saveTo(filePath);
      return File(filePath);
    } catch (_) {
      return null;
    }
  }

  Future<void> showSnackBar(String message) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains("saved")
              ? Colors.green.withOpacity(0.8)
              : Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color getBorderColor() {
    if (_objectDetected) {
      return Colors.green;
    } else if (_isDetecting) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  Color getStatusColor() {
    if (_objectDetected) {
      return Colors.green;
    } else if (_isDetecting) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  double getAspectRatio() {
    switch (_selectedRatio) {
      case AspectRatioType.ratio2x3:
        return 2.0 / 3.0;
      case AspectRatioType.ratio4x5:
        return 4.0 / 5.0;
    }
  }

  void _toggleAspectRatio() {
    setState(() {
      _selectedRatio = _selectedRatio == AspectRatioType.ratio2x3
          ? AspectRatioType.ratio4x5
          : AspectRatioType.ratio2x3;
    });
  }

  String _getAspectRatioText() {
    switch (_selectedRatio) {
      case AspectRatioType.ratio2x3:
        return "2:3";
      case AspectRatioType.ratio4x5:
        return "4:5";
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detectionTimer?.cancel();
    _detector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading ||
        _controller == null ||
        !_controller!.value.isInitialized ||
        _hasError ||
        !_modelLoaded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: _hasError
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: getAspectRatio(),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: getBorderColor(), width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: CameraPreview(_controller!),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: _toggleAspectRatio,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    _getAspectRatioText(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
