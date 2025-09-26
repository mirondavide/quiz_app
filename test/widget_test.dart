// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/main.dart';
import 'package:quiz_app/services/language_service.dart';
import 'package:quiz_app/services/ai_service.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Create mock services
    final languageService = LanguageService();
    final aiService = AIService();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(QuizApp(languageService: languageService, aiService: aiService));

    // Verify that the app loads without error
    expect(find.byType(Scaffold), findsWidgets);
  });
}
