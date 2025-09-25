import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_topic_generator.dart';

class QuizAnalytics {
  static const String _keyQuizHistory = 'quiz_history';
  static const String _keyTopicProgress = 'topic_progress';
  static const String _keyLearningInsights = 'learning_insights';

  // Quiz Performance Analysis
  static Future<QuizResult> analyzeQuizPerformance({
    required List<Question> questions,
    required List<int?> userAnswers,
    required List<int> answerTimes,
    required String topic,
  }) async {
    final totalQuestions = questions.length;
    int correctAnswers = 0;
    double totalComprehension = 0.0;
    List<QuestionPerformance> questionPerformances = [];
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = userAnswers[i];
      final timeSpent = answerTimes[i];
      final isCorrect = userAnswer != null && question.isCorrect(userAnswer);
      
      if (isCorrect) correctAnswers++;
      
      final comprehension = question.getComprehensionLevel(isCorrect, timeSpent);
      totalComprehension += comprehension;
      
      questionPerformances.add(QuestionPerformance(
        question: question,
        userAnswer: userAnswer,
        timeSpent: timeSpent,
        isCorrect: isCorrect,
        comprehensionLevel: comprehension,
        feedback: question.getPerformanceFeedback(isCorrect, timeSpent),
      ));
    }
    
    final percentage = (correctAnswers / totalQuestions) * 100;
    final avgComprehension = totalComprehension / totalQuestions;
    final avgTime = answerTimes.reduce((a, b) => a + b) / totalQuestions;
    
    final result = QuizResult(
      topic: topic,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      percentage: percentage,
      averageComprehension: avgComprehension,
      averageTime: avgTime,
      questionPerformances: questionPerformances,
      completedAt: DateTime.now(),
      masteryLevel: _calculateMasteryLevel(percentage, avgComprehension),
      strengthAreas: _identifyStrengths(questionPerformances),
      improvementAreas: _identifyImprovements(questionPerformances),
      personalizedFeedback: _generatePersonalizedFeedback(percentage, avgComprehension, topic),
      learningRecommendations: _generateLearningRecommendations(questionPerformances, topic),
    );
    
    await _saveQuizResult(result);
    await _updateTopicProgress(topic, result);
    
    return result;
  }

  static MasteryLevel _calculateMasteryLevel(double percentage, double comprehension) {
    final combinedScore = (percentage + comprehension * 100) / 2;
    
    if (combinedScore >= 90) return MasteryLevel.expert;
    if (combinedScore >= 80) return MasteryLevel.advanced;
    if (combinedScore >= 70) return MasteryLevel.intermediate;
    if (combinedScore >= 60) return MasteryLevel.developing;
    return MasteryLevel.beginner;
  }

  static List<String> _identifyStrengths(List<QuestionPerformance> performances) {
    final strengths = <String>[];
    final correctPerformances = performances.where((p) => p.isCorrect).toList();
    
    if (correctPerformances.length >= performances.length * 0.7) {
      strengths.add('Strong overall understanding');
    }
    
    final fastCorrectAnswers = correctPerformances.where((p) => p.timeSpent < 15).length;
    if (fastCorrectAnswers >= correctPerformances.length * 0.6) {
      strengths.add('Quick problem-solving abilities');
    }
    
    final easyQuestions = performances.where((p) => p.question.difficulty == 'Easy' && p.isCorrect).length;
    final mediumQuestions = performances.where((p) => p.question.difficulty == 'Medium' && p.isCorrect).length;
    final hardQuestions = performances.where((p) => p.question.difficulty == 'Hard' && p.isCorrect).length;
    
    if (easyQuestions > 0) strengths.add('Solid foundation knowledge');
    if (mediumQuestions > 0) strengths.add('Good intermediate understanding');
    if (hardQuestions > 0) strengths.add('Advanced problem-solving skills');
    
    return strengths.isEmpty ? ['Participation and effort'] : strengths;
  }

  static List<String> _identifyImprovements(List<QuestionPerformance> performances) {
    final improvements = <String>[];
    final incorrectPerformances = performances.where((p) => !p.isCorrect).toList();
    
    if (incorrectPerformances.length >= performances.length * 0.4) {
      improvements.add('Review fundamental concepts');
    }
    
    final slowAnswers = performances.where((p) => p.timeSpent > 30).length;
    if (slowAnswers >= performances.length * 0.5) {
      improvements.add('Practice for faster recall');
    }
    
    final difficultErrors = incorrectPerformances.where((p) => p.question.difficulty == 'Hard').length;
    if (difficultErrors > 0) {
      improvements.add('Focus on advanced topics');
    }
    
    final basicErrors = incorrectPerformances.where((p) => p.question.difficulty == 'Easy').length;
    if (basicErrors > 0) {
      improvements.add('Strengthen foundational knowledge');
    }
    
    return improvements.isEmpty ? ['Continue practicing regularly'] : improvements;
  }

  static String _generatePersonalizedFeedback(double percentage, double comprehension, String topic) {
    if (percentage >= 90 && comprehension >= 0.9) {
      return '🌟 Outstanding mastery of $topic! You demonstrate exceptional understanding and quick thinking. Consider teaching others or exploring advanced applications.';
    } else if (percentage >= 80 && comprehension >= 0.8) {
      return '🎉 Excellent work on $topic! You have a strong foundation. Focus on challenging yourself with more complex problems to reach expert level.';
    } else if (percentage >= 70 && comprehension >= 0.7) {
      return '👍 Good progress in $topic! You understand the core concepts well. Continue practicing to improve accuracy and speed.';
    } else if (percentage >= 60 && comprehension >= 0.6) {
      return '📚 You\'re developing understanding of $topic. Focus on reviewing key concepts and practicing regularly to build confidence.';
    } else {
      return '💪 $topic requires dedicated study. Don\'t be discouraged! Break down complex concepts, use multiple learning resources, and practice consistently.';
    }
  }

  static List<String> _generateLearningRecommendations(List<QuestionPerformance> performances, String topic) {
    final recommendations = <String>[];
    final incorrectPerformances = performances.where((p) => !p.isCorrect).toList();
    
    // Concept-specific recommendations
    if (incorrectPerformances.isNotEmpty) {
      final conceptGaps = incorrectPerformances
          .expand((p) => p.question.relatedConcepts)
          .toSet()
          .toList();
      
      if (conceptGaps.isNotEmpty) {
        recommendations.add('Review these key concepts: ${conceptGaps.take(3).join(', ')}');
      }
    }
    
    // Study method recommendations
    final avgTime = performances.map((p) => p.timeSpent).reduce((a, b) => a + b) / performances.length;
    if (avgTime > 25) {
      recommendations.add('Practice timed exercises to improve response speed');
    }
    
    // Difficulty-based recommendations
    final hardQuestions = performances.where((p) => p.question.difficulty == 'Hard').toList();
    final hardIncorrect = hardQuestions.where((p) => !p.isCorrect).length;
    if (hardIncorrect > hardQuestions.length * 0.5) {
      recommendations.add('Start with easier problems before tackling advanced topics');
    }
    
    // General recommendations
    recommendations.addAll([
      'Create flashcards for key terms and concepts',
      'Find real-world examples of $topic applications',
      'Join study groups or online communities',
      'Set aside 15-20 minutes daily for $topic practice',
    ]);
    
    return recommendations.take(5).toList();
  }

  static Future<void> _saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getQuizHistory();
    history.add(result);
    
    // Keep only last 50 results to manage storage
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(_keyQuizHistory, jsonEncode(jsonList));
  }

  static Future<void> _updateTopicProgress(String topic, QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString(_keyTopicProgress) ?? '{}';
    final progress = Map<String, dynamic>.from(jsonDecode(progressData));
    
    final topicData = progress[topic] ?? {
      'attempts': 0,
      'bestScore': 0.0,
      'averageScore': 0.0,
      'totalTime': 0,
      'masteryLevel': 'beginner',
      'lastAttempt': null,
    };
    
    topicData['attempts'] = (topicData['attempts'] ?? 0) + 1;
    topicData['bestScore'] = [topicData['bestScore'] ?? 0.0, result.percentage].reduce((a, b) => a > b ? a : b);
    topicData['averageScore'] = ((topicData['averageScore'] ?? 0.0) * (topicData['attempts'] - 1) + result.percentage) / topicData['attempts'];
    topicData['totalTime'] = (topicData['totalTime'] ?? 0) + result.averageTime.round();
    topicData['masteryLevel'] = result.masteryLevel.toString().split('.').last;
    topicData['lastAttempt'] = result.completedAt.toIso8601String();
    
    progress[topic] = topicData;
    await prefs.setString(_keyTopicProgress, jsonEncode(progress));
  }

  static Future<List<QuizResult>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyData = prefs.getString(_keyQuizHistory) ?? '[]';
    final historyList = List<Map<String, dynamic>>.from(jsonDecode(historyData));
    return historyList.map((data) => QuizResult.fromJson(data)).toList();
  }

  static Future<Map<String, TopicProgress>> getTopicProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = prefs.getString(_keyTopicProgress) ?? '{}';
    final progress = Map<String, dynamic>.from(jsonDecode(progressData));
    
    return progress.map((topic, data) => MapEntry(
      topic,
      TopicProgress.fromJson(Map<String, dynamic>.from(data)),
    ));
  }

  static Future<LearningInsights> generateLearningInsights() async {
    final history = await getQuizHistory();
    final topicProgress = await getTopicProgress();
    
    if (history.isEmpty) {
      return LearningInsights.empty();
    }
    
    final totalQuizzes = history.length;
    final averageScore = history.map((r) => r.percentage).reduce((a, b) => a + b) / totalQuizzes;
    final strongestTopics = topicProgress.entries
        .where((e) => e.value.bestScore >= 80)
        .map((e) => e.key)
        .toList()
        ..sort((a, b) => topicProgress[b]!.bestScore.compareTo(topicProgress[a]!.bestScore));
    
    final improvementNeeded = topicProgress.entries
        .where((e) => e.value.bestScore < 70)
        .map((e) => e.key)
        .toList()
        ..sort((a, b) => topicProgress[a]!.bestScore.compareTo(topicProgress[b]!.bestScore));
    
    final recentPerformance = history.length >= 5 
        ? history.skip(history.length - 5).map((r) => r.percentage).reduce((a, b) => a + b) / 5
        : averageScore;
    
    final isImproving = recentPerformance > averageScore;
    
    return LearningInsights(
      totalQuizzes: totalQuizzes,
      averageScore: averageScore,
      strongestTopics: strongestTopics.take(3).toList(),
      improvementNeeded: improvementNeeded.take(3).toList(),
      isImproving: isImproving,
      studyStreak: _calculateStudyStreak(history),
      recommendations: _generateOverallRecommendations(topicProgress, isImproving),
    );
  }

  static int _calculateStudyStreak(List<QuizResult> history) {
    if (history.isEmpty) return 0;
    
    int streak = 0;
    final now = DateTime.now();
    
    for (int i = history.length - 1; i >= 0; i--) {
      final daysDiff = now.difference(history[i].completedAt).inDays;
      if (daysDiff <= streak + 1) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  static List<String> _generateOverallRecommendations(Map<String, TopicProgress> progress, bool isImproving) {
    final recommendations = <String>[];
    
    if (isImproving) {
      recommendations.add('🚀 Great momentum! Keep up the consistent practice');
    } else {
      recommendations.add('📈 Focus on regular study sessions to improve');
    }
    
    final lowPerformanceTopics = progress.entries
        .where((e) => e.value.bestScore < 60)
        .length;
    
    if (lowPerformanceTopics > 3) {
      recommendations.add('Consider focusing on 1-2 topics at a time for deeper understanding');
    }
    
    recommendations.addAll([
      'Set daily learning goals and track progress',
      'Review incorrect answers to understand mistakes',
      'Use spaced repetition for better retention',
    ]);
    
    return recommendations;
  }
}

enum MasteryLevel {
  beginner,
  developing,
  intermediate,
  advanced,
  expert,
}

class QuestionPerformance {
  final Question question;
  final int? userAnswer;
  final int timeSpent;
  final bool isCorrect;
  final double comprehensionLevel;
  final String feedback;

  QuestionPerformance({
    required this.question,
    this.userAnswer,
    required this.timeSpent,
    required this.isCorrect,
    required this.comprehensionLevel,
    required this.feedback,
  });

  Map<String, dynamic> toJson() => {
    'questionId': question.id,
    'questionText': question.text,
    'userAnswer': userAnswer,
    'correctAnswer': question.correctIndex,
    'timeSpent': timeSpent,
    'isCorrect': isCorrect,
    'comprehensionLevel': comprehensionLevel,
    'feedback': feedback,
    'difficulty': question.difficulty,
  };

  factory QuestionPerformance.fromJson(Map<String, dynamic> json) {
    // Note: This is a simplified version as we don't store full question objects
    return QuestionPerformance(
      question: Question(
        id: json['questionId'],
        text: json['questionText'],
        options: ['A', 'B', 'C', 'D'], // Simplified
        correctIndex: json['correctAnswer'],
        topic: '',
        difficulty: json['difficulty'] ?? 'Medium',
        explanation: '',
      ),
      userAnswer: json['userAnswer'],
      timeSpent: json['timeSpent'],
      isCorrect: json['isCorrect'],
      comprehensionLevel: json['comprehensionLevel'].toDouble(),
      feedback: json['feedback'],
    );
  }
}

class QuizResult {
  final String topic;
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final double averageComprehension;
  final double averageTime;
  final List<QuestionPerformance> questionPerformances;
  final DateTime completedAt;
  final MasteryLevel masteryLevel;
  final List<String> strengthAreas;
  final List<String> improvementAreas;
  final String personalizedFeedback;
  final List<String> learningRecommendations;

  QuizResult({
    required this.topic,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.averageComprehension,
    required this.averageTime,
    required this.questionPerformances,
    required this.completedAt,
    required this.masteryLevel,
    required this.strengthAreas,
    required this.improvementAreas,
    required this.personalizedFeedback,
    required this.learningRecommendations,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'totalQuestions': totalQuestions,
    'correctAnswers': correctAnswers,
    'percentage': percentage,
    'averageComprehension': averageComprehension,
    'averageTime': averageTime,
    'questionPerformances': questionPerformances.map((p) => p.toJson()).toList(),
    'completedAt': completedAt.toIso8601String(),
    'masteryLevel': masteryLevel.toString().split('.').last,
    'strengthAreas': strengthAreas,
    'improvementAreas': improvementAreas,
    'personalizedFeedback': personalizedFeedback,
    'learningRecommendations': learningRecommendations,
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      topic: json['topic'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      percentage: json['percentage'].toDouble(),
      averageComprehension: json['averageComprehension'].toDouble(),
      averageTime: json['averageTime'].toDouble(),
      questionPerformances: (json['questionPerformances'] as List)
          .map((p) => QuestionPerformance.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
      completedAt: DateTime.parse(json['completedAt']),
      masteryLevel: MasteryLevel.values.firstWhere(
        (level) => level.toString().split('.').last == json['masteryLevel'],
        orElse: () => MasteryLevel.beginner,
      ),
      strengthAreas: List<String>.from(json['strengthAreas'] ?? []),
      improvementAreas: List<String>.from(json['improvementAreas'] ?? []),
      personalizedFeedback: json['personalizedFeedback'] ?? '',
      learningRecommendations: List<String>.from(json['learningRecommendations'] ?? []),
    );
  }
}

class TopicProgress {
  final int attempts;
  final double bestScore;
  final double averageScore;
  final int totalTime;
  final MasteryLevel masteryLevel;
  final DateTime? lastAttempt;

  TopicProgress({
    required this.attempts,
    required this.bestScore,
    required this.averageScore,
    required this.totalTime,
    required this.masteryLevel,
    this.lastAttempt,
  });

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      attempts: json['attempts'],
      bestScore: json['bestScore'].toDouble(),
      averageScore: json['averageScore'].toDouble(),
      totalTime: json['totalTime'],
      masteryLevel: MasteryLevel.values.firstWhere(
        (level) => level.toString().split('.').last == json['masteryLevel'],
        orElse: () => MasteryLevel.beginner,
      ),
      lastAttempt: json['lastAttempt'] != null 
          ? DateTime.parse(json['lastAttempt'])
          : null,
    );
  }
}

class LearningInsights {
  final int totalQuizzes;
  final double averageScore;
  final List<String> strongestTopics;
  final List<String> improvementNeeded;
  final bool isImproving;
  final int studyStreak;
  final List<String> recommendations;

  LearningInsights({
    required this.totalQuizzes,
    required this.averageScore,
    required this.strongestTopics,
    required this.improvementNeeded,
    required this.isImproving,
    required this.studyStreak,
    required this.recommendations,
  });

  factory LearningInsights.empty() {
    return LearningInsights(
      totalQuizzes: 0,
      averageScore: 0.0,
      strongestTopics: [],
      improvementNeeded: [],
      isImproving: false,
      studyStreak: 0,
      recommendations: ['Start taking quizzes to track your progress!'],
    );
  }
}