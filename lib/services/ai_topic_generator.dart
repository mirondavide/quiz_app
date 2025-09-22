import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;

class AITopicGenerator {
  // OpenAI API configuration
  static const String _openAIAPIKey = 'YOUR_OPENAI_API_KEY_HERE'; // Replace with actual API key
  static const String _openAIURL = 'https://api.openai.com/v1/chat/completions';
  
  // Fallback local question templates for offline mode
  static const List<String> _questionTemplates = [
    "What is the main characteristic of {topic}?",
    "Which of the following is most closely related to {topic}?",
    "What is the primary function of {topic}?",
    "How does {topic} impact society?",
    "What is the historical significance of {topic}?",
    "Which principle governs {topic}?",
    "What are the key components of {topic}?",
    "How is {topic} measured or evaluated?",
    "What is the relationship between {topic} and its environment?",
    "What are the common misconceptions about {topic}?"
  ];

  static const Map<String, List<String>> _topicAnswers = {
    'mathematics': [
      'Mathematics is the study of numbers, shapes, and patterns',
      'Mathematics involves logical reasoning and problem-solving',
      'Mathematics is used to model real-world phenomena',
      'Mathematics is a universal language'
    ],
    'science': [
      'Science is the systematic study of the natural world',
      'Science uses evidence-based methods to understand reality',
      'Science involves observation, hypothesis, and experimentation',
      'Science builds knowledge through peer review and replication'
    ],
    'history': [
      'History is the study of past events and their causes',
      'History helps us understand patterns in human behavior',
      'History preserves cultural memory and identity',
      'History teaches lessons for future decision-making'
    ],
    'geography': [
      'Geography studies the relationship between people and places',
      'Geography examines physical and human environments',
      'Geography involves spatial analysis and mapping',
      'Geography connects local and global perspectives'
    ],
    'literature': [
      'Literature explores human experiences through written works',
      'Literature reflects and shapes cultural values',
      'Literature develops critical thinking and empathy',
      'Literature preserves linguistic and artistic heritage'
    ],
    'biology': [
      'Biology is the study of living organisms and life processes',
      'Biology examines the structure and function of life',
      'Biology investigates interactions between organisms',
      'Biology applies knowledge to medicine and conservation'
    ],
    'physics': [
      'Physics studies matter, energy, and their interactions',
      'Physics seeks to understand fundamental laws of nature',
      'Physics uses mathematics to describe natural phenomena',
      'Physics drives technological innovation and discovery'
    ],
    'chemistry': [
      'Chemistry studies the composition and properties of matter',
      'Chemistry examines chemical reactions and bonds',
      'Chemistry bridges physics and biology',
      'Chemistry has practical applications in industry and medicine'
    ]
  };

  static Future<List<Question>> generateQuestions(String topic, {int count = 5}) async {
    try {
      // Try to generate questions using OpenAI API first
      if (_openAIAPIKey != 'YOUR_OPENAI_API_KEY_HERE') {
        return await _generateQuestionsWithAI(topic, count);
      }
    } catch (e) {
      print('AI API failed, falling back to local generation: $e');
    }
    
    // Fallback to local question generation
    return _generateQuestionsLocally(topic, count);
  }

  // Generate questions using OpenAI API
  static Future<List<Question>> _generateQuestionsWithAI(String topic, int count) async {
    final prompt = '''
Generate $count multiple-choice questions about "$topic".

For each question, provide:
1. A clear, specific question
2. Four answer options (A, B, C, D)
3. The correct answer letter
4. A brief explanation

Format the response as JSON:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_answer": 0,
      "explanation": "Explanation here",
      "difficulty": "Easy/Medium/Hard"
    }
  ]
}

Make questions educational and engaging about $topic.
''';

    final response = await http.post(
      Uri.parse(_openAIURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openAIAPIKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an educational quiz generator. Create high-quality, accurate multiple-choice questions.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'max_tokens': 2000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      
      // Parse the JSON response
      final questionsData = jsonDecode(content);
      final questions = <Question>[];
      
      for (int i = 0; i < questionsData['questions'].length; i++) {
        final q = questionsData['questions'][i];
        questions.add(Question(
          id: i + 1,
          text: q['question'],
          options: List<String>.from(q['options']),
          correctIndex: q['correct_answer'],
          topic: topic,
          difficulty: q['difficulty'] ?? 'Medium',
          explanation: q['explanation'] ?? 'No explanation provided.',
        ));
      }
      
      return questions;
    } else {
      throw Exception('Failed to generate questions: ${response.statusCode}');
    }
  }

  // Local question generation (fallback)
  static List<Question> _generateQuestionsLocally(String topic, int count) {
    final random = Random();
    final questions = <Question>[];
    final normalizedTopic = topic.toLowerCase().trim();
    
    // Generate questions based on the topic
    for (int i = 0; i < count; i++) {
      final template = _questionTemplates[random.nextInt(_questionTemplates.length)];
      final questionText = template.replaceAll('{topic}', topic);
      
      // Generate answers
      final answers = _generateAnswersForTopic(normalizedTopic, random);
      final correctIndex = random.nextInt(4);
      
      questions.add(Question(
        id: i + 1,
        text: questionText,
        options: answers,
        correctIndex: correctIndex,
        topic: topic,
        difficulty: _getDifficultyForQuestion(i),
        explanation: _generateExplanation(topic, answers[correctIndex]),
      ));
    }
    
    return questions;
  }

  static List<String> _generateAnswersForTopic(String topic, Random random) {
    final answers = <String>[];
    
    // Try to find topic-specific answers
    String? matchedKey;
    for (final key in _topicAnswers.keys) {
      if (topic.contains(key) || key.contains(topic)) {
        matchedKey = key;
        break;
      }
    }
    
    if (matchedKey != null) {
      final topicAnswers = _topicAnswers[matchedKey]!;
      answers.add(topicAnswers[random.nextInt(topicAnswers.length)]);
    } else {
      answers.add(_generateGenericAnswer(topic));
    }
    
    // Add other plausible answers
    final otherKeys = _topicAnswers.keys.where((k) => k != matchedKey).toList();
    while (answers.length < 4) {
      final randomKey = otherKeys[random.nextInt(otherKeys.length)];
      final randomAnswer = _topicAnswers[randomKey]![random.nextInt(_topicAnswers[randomKey]!.length)];
      
      if (!answers.contains(randomAnswer)) {
        answers.add(randomAnswer);
      }
    }
    
    // Shuffle the answers
    answers.shuffle(random);
    return answers;
  }

  static String _generateGenericAnswer(String topic) {
    final templates = [
      "$topic is an important field of study",
      "$topic involves complex processes and principles",
      "$topic has significant real-world applications",
      "$topic requires specialized knowledge and skills"
    ];
    return templates[Random().nextInt(templates.length)];
  }

  static String _getDifficultyForQuestion(int index) {
    if (index < 2) return 'Easy';
    if (index < 4) return 'Medium';
    return 'Hard';
  }

  static String _generateExplanation(String topic, String correctAnswer) {
    return "This question about $topic tests your understanding of fundamental concepts. $correctAnswer represents a key aspect that distinguishes this field of study.";
  }

  static List<String> getPopularTopics() {
    return [
      'Mathematics - Calculus',
      'Physics - Thermodynamics', 
      'History - World War II',
      'Biology - Cell Biology',
      'Chemistry - Organic Chemistry',
      'Computer Science - Algorithms',
      'Literature - Shakespeare',
      'Geography - Climate Change',
      'Economics - Microeconomics',
      'Psychology - Cognitive Psychology',
      'Art History - Renaissance',
      'Philosophy - Ethics',
      'Python Programming',
      'Data Science',
      'Machine Learning',
      'Web Development',
      'Astronomy - Solar System',
      'Medicine - Human Anatomy',
      'Environmental Science',
      'Political Science',
      'Sociology - Social Theory',
      'Anthropology',
      'Linguistics',
      'Statistics',
    ];
  }

  static List<String> getTopicSuggestions(String input) {
    if (input.isEmpty) return getPopularTopics().take(6).toList();
    
    final suggestions = getPopularTopics()
        .where((topic) => topic.toLowerCase().contains(input.toLowerCase()))
        .toList();
    
    if (suggestions.isEmpty) {
      return [input.trim()]; // Allow custom topics
    }
    
    return suggestions.take(6).toList();
  }
}

class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String topic;
  final String difficulty;
  final String explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.difficulty,
    required this.explanation,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
  String get correctAnswer => options[correctIndex];
}