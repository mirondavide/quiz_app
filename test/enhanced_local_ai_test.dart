import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/services/ai_topic_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Enhanced Local AI Tests', () {
    test('Enhanced local AI generates comprehensive questions', () async {
      final questions = await AITopicGenerator.generateQuestions('Mathematics', count: 3);
      
      expect(questions.length, 3);
      
      // Test enhanced content
      for (final question in questions) {
        expect(question.text.isNotEmpty, true);
        expect(question.options.length, 4);
        expect(question.explanation.isNotEmpty, true);
        expect(question.learningObjective.isNotEmpty, true);
        expect(question.realWorldApplication.isNotEmpty, true);
        expect(question.studyTips.isNotEmpty, true);
        expect(question.commonMistakes.isNotEmpty, true);
        expect(question.relatedConcepts.isNotEmpty, true);
        expect(question.topicOverview.description.isNotEmpty, true);
        
        // Test content quality
        expect(question.explanation.length > 50, true); // Detailed explanations
        expect(question.realWorldApplication.length > 30, true); // Comprehensive applications
        expect(question.studyTips.length > 40, true); // Detailed study tips
      }
    });

    test('Different topics generate relevant content', () async {
      final mathQuestions = await AITopicGenerator.generateQuestions('Mathematics', count: 2);
      final physicsQuestions = await AITopicGenerator.generateQuestions('Physics', count: 2);
      final historyQuestions = await AITopicGenerator.generateQuestions('History', count: 2);
      
      // Verify topic-specific content
      expect(mathQuestions.first.realWorldApplication.toLowerCase().contains('mathematical'), true);
      expect(physicsQuestions.first.realWorldApplication.toLowerCase().contains('physics'), true);
      expect(historyQuestions.first.realWorldApplication.toLowerCase().contains('historical'), true);
      
      // Each should have unique, topic-relevant content
      expect(mathQuestions.first.studyTips != physicsQuestions.first.studyTips, true);
      expect(physicsQuestions.first.commonMistakes != historyQuestions.first.commonMistakes, true);
    });

    test('Questions have sophisticated answer quality', () async {
      final questions = await AITopicGenerator.generateQuestions('Computer Science', count: 2);
      
      for (final question in questions) {
        // First answer should always be correct (our enhanced algorithm)
        expect(question.correctIndex, 0);
        
        // All answers should be substantial and different
        for (int i = 0; i < question.options.length; i++) {
          expect(question.options[i].length > 20, true); // Substantial answers
          for (int j = i + 1; j < question.options.length; j++) {
            expect(question.options[i] != question.options[j], true); // Unique answers
          }
        }
      }
    });

    test('Popular topics are comprehensive', () {
      final popularTopics = AITopicGenerator.getPopularTopics();
      expect(popularTopics.length >= 20, true);
      expect(popularTopics.any((topic) => topic.contains('Mathematics')), true);
      expect(popularTopics.any((topic) => topic.contains('Physics')), true);
      expect(popularTopics.any((topic) => topic.contains('Computer Science')), true);
    });
  });
}