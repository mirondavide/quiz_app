import 'package:flutter/material.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final String category;
  final QuestionDifficulty difficulty;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    this.categoryIcon,
    this.categoryColor,
    this.category = 'General',
    this.difficulty = QuestionDifficulty.medium,
  });

  // Get points based on difficulty
  int get points {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return 10;
      case QuestionDifficulty.medium:
        return 20;
      case QuestionDifficulty.hard:
        return 30;
    }
  }
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

extension QuestionDifficultyExtension on QuestionDifficulty {
  String get name {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Facile';
      case QuestionDifficulty.medium:
        return 'Medio';
      case QuestionDifficulty.hard:
        return 'Difficile';
    }
  }

  Color get color {
    switch (this) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionDifficulty.easy:
        return Icons.sentiment_very_satisfied;
      case QuestionDifficulty.medium:
        return Icons.sentiment_neutral;
      case QuestionDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
