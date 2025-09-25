import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/quiz_page.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AI-Powered Quiz Page Tests', () {
    testWidgets('Quiz page shows topic input screen initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizPage(),
        ),
      );
      
      // Verify the topic input screen is shown
      expect(find.text('AI Quiz Generator'), findsOneWidget);
      expect(find.text('Enter any topic and get instant quiz questions'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Generate Quiz Questions'), findsOneWidget);
    });

    testWidgets('Popular topics are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizPage(),
        ),
      );
      
      // Verify popular topics are shown
      expect(find.text('Popular Topics'), findsOneWidget);
      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Physics'), findsOneWidget);
      expect(find.text('Computer Science'), findsOneWidget);
    });

    testWidgets('Generate button is present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizPage(),
        ),
      );
      
      // Find the generate button
      final generateButton = find.text('Generate Quiz Questions');
      expect(generateButton, findsOneWidget);
      
      // The button should be tappable
      await tester.ensureVisible(generateButton);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton).first).onPressed, isNotNull);
    });
  });
}