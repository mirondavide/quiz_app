import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/ai_topic_generator.dart';
import 'package:quiz_app/services/quiz_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Enhanced Quiz App Basic Tests', () {
    test('AI Topic Generator creates questions with enhanced data', () async {
      final questions = await AITopicGenerator.generateQuestions('Mathematics', count: 3);
      
      expect(questions.length, 3);
      expect(questions.first.text.isNotEmpty, true);
      expect(questions.first.options.length, 4);
      expect(questions.first.explanation.isNotEmpty, true);
      expect(questions.first.learningObjective.isNotEmpty, true);
      expect(questions.first.difficulty.isNotEmpty, true);
      
      // Test that enhanced content is present
      expect(questions.first.realWorldApplication.isNotEmpty, true);
      expect(questions.first.studyTips.isNotEmpty, true);
      expect(questions.first.commonMistakes.isNotEmpty, true);
      expect(questions.first.relatedConcepts.isNotEmpty, true);
      expect(questions.first.topicOverview.description.isNotEmpty, true);
    });

    test('Question performance feedback is generated correctly', () {
      final question = Question(
        id: 1,
        text: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
        topic: 'Mathematics',
        difficulty: 'Easy',
        explanation: 'Simple addition',
      );
      
      final correctFeedback = question.getPerformanceFeedback(true, 10);
      final incorrectFeedback = question.getPerformanceFeedback(false, 10);
      
      expect(correctFeedback.contains('Excellent') || correctFeedback.contains('Great') || correctFeedback.contains('Correct'), true);
      expect(incorrectFeedback.contains('Quick response') || incorrectFeedback.contains('concept needs'), true);
    });

    test('Comprehension level calculation works', () {
      final question = Question(
        id: 1,
        text: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
        topic: 'Mathematics',
        difficulty: 'Medium',
        explanation: 'Simple addition',
      );
      
      final correctComprehension = question.getComprehensionLevel(true, 10);
      final incorrectComprehension = question.getComprehensionLevel(false, 10);
      
      expect(correctComprehension > incorrectComprehension, true);
      expect(correctComprehension >= 0.0 && correctComprehension <= 1.0, true);
      expect(incorrectComprehension >= 0.0 && incorrectComprehension <= 1.0, true);
    });

    test('Topic suggestions are generated', () {
      final popularTopics = AITopicGenerator.getPopularTopics();
      expect(popularTopics.isNotEmpty, true);
      expect(popularTopics.length >= 10, true);
      
      final suggestions = AITopicGenerator.getTopicSuggestions('math');
      expect(suggestions.isNotEmpty, true);
    });

    test('Basic enhanced question properties exist', () {
      final question = Question(
        id: 1,
        text: 'What is 2 + 2?',
        options: ['3', '4', '5', '6'],
        correctIndex: 1,
        topic: 'Mathematics',
        difficulty: 'Easy',
        explanation: 'Simple addition',
        learningObjective: 'Test objective',
        realWorldApplication: 'Test application',
        commonMistakes: 'Test mistakes',
        studyTips: 'Test tips',
        relatedConcepts: ['Addition', 'Numbers'],
      );
      
      expect(question.learningObjective, 'Test objective');
      expect(question.realWorldApplication, 'Test application');
      expect(question.commonMistakes, 'Test mistakes');
      expect(question.studyTips, 'Test tips');
      expect(question.relatedConcepts.length, 2);
    });
  });
}