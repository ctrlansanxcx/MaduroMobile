// ai_chatbot.dart

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIChatBotService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  // Make them nullable
  GenerativeModel? _model;
  ChatSession? _chat;

  // Add a flag to check readiness
  bool _isInitialized = false;

  AIChatBotService() {
    if (_apiKey.isEmpty) {
      print(
          "Warning: Gemini API Key is not set. AI Chatbot will not function.");
      _isInitialized = false; // Explicitly mark as not initialized
    } else {
      try {
        _model = GenerativeModel(
          model: 'gemini-2.5-flash', // or 'gemini-pro'
          apiKey: _apiKey,
        );
        _chat = _model!
            .startChat(); // Use the non-null assertion ! here as we are in the else block where _model is not null
        _isInitialized = true; // Mark as initialized
        print("AI Chatbot Service initialized successfully.");
      } catch (e) {
        print("Error initializing AI Chatbot Service: $e");
        _isInitialized =
            false; // Mark as not initialized if initialization fails
      }
    }
  }

  // Optional: Add a getter to check readiness
  bool get isReady => _isInitialized;

  Future<String> sendMessage(String userInput) async {
    // Check if the service is ready BEFORE trying to send
    if (!_isInitialized) {
      return "AI Chatbot Service is not initialized (API Key missing or initialization failed).";
    }

    if (userInput.trim().isEmpty) {
      return "Message cannot be empty.";
    }

    try {
      // Now _chat is guaranteed to be non-null if _isInitialized is true
      final response =
          await _chat!.sendMessage(Content.text(userInput)); // Use ! here
      return response.text ?? 'No response from AI.';
    } catch (e) {
      // Catch potential errors during the API call itself
      print('Error sending message: $e'); // Print the actual error
      return 'Error sending message: $e';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
