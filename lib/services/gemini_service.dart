import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_keys.dart';

class GeminiService {
  static GenerativeModel? _model;
  final String apiKey;
  bool _isInitialized = false;

  GeminiService({String? apiKey}) : apiKey = apiKey ?? ApiKeys.geminiApiKey;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (apiKey.isEmpty) {
        throw Exception("Gemini API key is not set. Please add it to your .env file.");
      }
      
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      debugPrint('Error initializing Gemini: $e');
      rethrow;
    }
  }

  Future<String> sendMessage(String prompt) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      if (_model == null) {
        throw Exception("Gemini model is not initialized");
      }

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      
      // Extract the text response from the generated content
      final responseText = response.text;
      
      if (responseText == null || responseText.isEmpty) {
        return "I'm sorry, I couldn't generate a response. Please try again.";
      }
      
      return responseText;
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');
      return "I encountered an error while processing your request. Please check your API key or try again later. Error: $e";
    }
  }
} 