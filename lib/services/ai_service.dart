import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();
  
  static const String _defaultApiUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _defaultModel = 'gpt-3.5-turbo';
  
  String? _apiKey;
  String _apiUrl = _defaultApiUrl;
  String _model = _defaultModel;
  
  // Load API configuration from shared preferences
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('ai_api_key');
    _apiUrl = prefs.getString('ai_api_url') ?? _defaultApiUrl;
    _model = prefs.getString('ai_model') ?? _defaultModel;
  }
  
  // Configure AI service with custom settings
  void configure({
    required String apiKey,
    String? apiUrl,
    String? model,
  }) {
    _apiKey = apiKey;
    if (apiUrl != null) _apiUrl = apiUrl;
    if (model != null) _model = model;
  }
  
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
  
  // Generate AI response for text input
  Future<AIResponse> generateTextResponse({
    required String topic,
    required String language,
    String theme = 'light',
  }) async {
    if (!isConfigured) {
      throw AIException('AI service not configured. Please set API key.');
    }
    
    final prompt = _buildTextPrompt(topic, language, theme);
    
    try {
      final response = await _makeAPICall(prompt);
      return AIResponse(
        content: response,
        type: AIResponseType.directAnswer,
        language: language,
        theme: theme,
      );
    } catch (e) {
      throw AIException('Failed to generate text response: $e');
    }
  }
  
  // Generate AI response for file input
  Future<AIResponse> generateFileResponse({
    required String fileContent,
    required String fileName,
    required String language,
    String theme = 'light',
  }) async {
    if (!isConfigured) {
      throw AIException('AI service not configured. Please set API key.');
    }
    
    final prompt = _buildFilePrompt(fileContent, fileName, language, theme);
    
    try {
      final response = await _makeAPICall(prompt);
      return AIResponse(
        content: response,
        type: AIResponseType.questionAnswer,
        language: language,
        theme: theme,
        fileName: fileName,
      );
    } catch (e) {
      throw AIException('Failed to generate file response: $e');
    }
  }
  
  // Build prompt for text input
  String _buildTextPrompt(String topic, String language, String theme) {
    return '''
Language: $language
Theme: $theme
Input: $topic
Task: Provide a comprehensive and helpful answer about the given topic. Be informative, accurate, and engaging. Format your response in a conversational manner.

Please respond in $language language.
''';
  }
  
  // Build prompt for file input
  String _buildFilePrompt(String fileContent, String fileName, String language, String theme) {
    return '''
Language: $language
Theme: $theme
File: $fileName
Content: $fileContent

Task: Based on the provided file content, generate a set of meaningful questions and their corresponding answers. Create 5-8 questions that test understanding of the key concepts, facts, and details from the content. Format the response as a Q&A session.

Please respond in $language language and structure your response as:

Q1: [Question]
A1: [Answer]

Q2: [Question]
A2: [Answer]

[Continue with remaining questions...]
''';
  }
  
  // Make API call to AI service
  Future<String> _makeAPICall(String prompt) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    
    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a helpful AI assistant that provides accurate and comprehensive responses.',
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      'max_tokens': 2000,
      'temperature': 0.7,
    });
    
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw AIException('API Error ${response.statusCode}: ${errorData['error']['message']}');
      }
    } on SocketException catch (e) {
      throw AIException('Network error: $e');
    } on FormatException catch (e) {
      throw AIException('Invalid response format: $e');
    } catch (e) {
      throw AIException('Unexpected error: $e');
    }
  }
  
  // Test API connection
  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    
    try {
      await _makeAPICall('Hello, please respond with "Connection successful"');
      return true;
    } catch (e) {
      debugPrint('AI Service connection test failed: $e');
      return false;
    }
  }
}

// AI Response model
class AIResponse {
  final String content;
  final AIResponseType type;
  final String language;
  final String theme;
  final String? fileName;
  final DateTime timestamp;
  
  AIResponse({
    required this.content,
    required this.type,
    required this.language,
    required this.theme,
    this.fileName,
  }) : timestamp = DateTime.now();
  
  // Parse Q&A format response
  List<QuestionAnswer> get questionAnswers {
    if (type != AIResponseType.questionAnswer) return [];
    
    final lines = content.split('\n');
    final List<QuestionAnswer> qaList = [];
    String? currentQuestion;
    String? currentAnswer;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      if (trimmedLine.startsWith('Q') && trimmedLine.contains(':')) {
        // Save previous Q&A pair if exists
        if (currentQuestion != null && currentAnswer != null) {
          qaList.add(QuestionAnswer(
            question: currentQuestion,
            answer: currentAnswer,
          ));
        }
        currentQuestion = trimmedLine.substring(trimmedLine.indexOf(':') + 1).trim();
        currentAnswer = null;
      } else if (trimmedLine.startsWith('A') && trimmedLine.contains(':')) {
        currentAnswer = trimmedLine.substring(trimmedLine.indexOf(':') + 1).trim();
      } else if (currentAnswer != null) {
        // Continue building the answer
        currentAnswer += ' $trimmedLine';
      }
    }
    
    // Add the last Q&A pair
    if (currentQuestion != null && currentAnswer != null) {
      qaList.add(QuestionAnswer(
        question: currentQuestion,
        answer: currentAnswer,
      ));
    }
    
    return qaList;
  }
}

// Question Answer model
class QuestionAnswer {
  final String question;
  final String answer;
  
  QuestionAnswer({
    required this.question,
    required this.answer,
  });
}

// AI Response types
enum AIResponseType {
  directAnswer,
  questionAnswer,
}

// AI Exception
class AIException implements Exception {
  final String message;
  
  AIException(this.message);
  
  @override
  String toString() => 'AIException: $message';
}