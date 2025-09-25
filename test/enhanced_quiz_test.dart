import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/ai_topic_generator.dart';
import 'package:quiz_app/services/quiz_analytics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    // Mock SharedPreferences for testing
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      } else if (methodCall.method == 'setString') {
        return true;
      }
      return null;
    });
  });
  group('Enhanced Quiz App Tests', () {
    test('AI Topic Generator creates questions with enhanced data', () async {
      final questions = await AITopicGenerator.generateQuestions('Mathematics', count: 3);
      
      expect(questions.length, 3);
      expect(questions.first.text.isNotEmpty, true);
      expect(questions.first.options.length, 4);
      expect(questions.first.explanation.isNotEmpty, true);
      expect(questions.first.learningObjective.isNotEmpty, true);
      expect(questions.first.difficulty.isNotEmpty, true);
    });

    test('Quiz Analytics processes results correctly', () async {
      final questions = await AITopicGenerator.generateQuestions('Mathematics', count: 3);
      final userAnswers = [0, 1, 0];
      final answerTimes = [10, 15, 8];
      
      final result = await QuizAnalytics.analyzeQuizPerformance(
        questions: questions,
        userAnswers: userAnswers,
        answerTimes: answerTimes,
        topic: 'Mathematics',
      );
      
      expect(result.topic, 'Mathematics');
      expect(result.totalQuestions, 3);
      expect(result.percentage >= 0 && result.percentage <= 100, true);
      expect(result.strengthAreas.isNotEmpty, true);
      expect(result.personalizedFeedback.isNotEmpty, true);
      expect(result.learningRecommendations.isNotEmpty, true);
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

    test('Mastery level calculation works correctly', () {
      expect(QuizAnalytics.generateLearningInsights(), completes);
    });

    test('Learning insights are generated for empty data', () async {
      final insights = LearningInsights.empty();
      
      expect(insights.totalQuizzes, 0);
      expect(insights.averageScore, 0.0);
      expect(insights.strongestTopics.isEmpty, true);
      expect(insights.recommendations.isNotEmpty, true);
    });
  });
}