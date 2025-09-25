import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AITopicGenerator {
  // OpenAI API configuration
  static const String _openAIURL = 'https://api.openai.com/v1/chat/completions';
  
  static Future<String?> _getAPIKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('openai_api_key');
  }
  
  // Advanced local question templates for premium experience
  static const List<String> _questionTemplates = [
    "What is the fundamental principle underlying {topic}?",
    "Which of the following best demonstrates the application of {topic}?",
    "What is the most significant advantage of understanding {topic}?",
    "How does {topic} fundamentally differ from related concepts?",
    "What historical development most influenced modern {topic}?",
    "Which theoretical framework best explains {topic}?",
    "What are the essential components that define {topic}?",
    "How is proficiency in {topic} best measured and evaluated?",
    "What is the most important relationship between {topic} and its applications?",
    "Which common misconception about {topic} can lead to errors?",
    "What breakthrough discovery revolutionized our understanding of {topic}?",
    "Which practical skill is most enhanced by mastering {topic}?",
    "What ethical consideration is most relevant when applying {topic}?",
    "How does modern technology change the traditional approach to {topic}?",
    "What interdisciplinary connection makes {topic} particularly valuable?",
    "Which problem-solving strategy is most effective for {topic}-related challenges?",
    "What future development in {topic} is most anticipated by experts?",
    "How does cultural context influence the understanding of {topic}?",
    "What prerequisite knowledge is absolutely essential for {topic}?",
    "Which real-world scenario best illustrates the importance of {topic}?"
  ];

  // Get localized question templates based on language
  static List<String> _getLocalizedQuestionTemplates(String language) {
    const templates = {
      'es': [ // Spanish
        "¿Cuál es el principio fundamental que subyace a {topic}?",
        "¿Cuál de las siguientes opciones demuestra mejor la aplicación de {topic}?",
        "¿Cuál es la ventaja más significativa de entender {topic}?",
        "¿En qué se diferencia fundamentalmente {topic} de conceptos relacionados?",
        "¿Qué desarrollo histórico influyó más en el {topic} moderno?",
      ],
      'fr': [ // French
        "Quel est le principe fondamental sous-jacent à {topic}?",
        "Lequel des éléments suivants démontre le mieux l'application de {topic}?",
        "Quel est l'avantage le plus significatif de comprendre {topic}?",
        "En quoi {topic} diffère-t-il fondamentalement des concepts apparentés?",
        "Quel développement historique a le plus influencé {topic} moderne?",
      ],
      'de': [ // German
        "Was ist das grundlegende Prinzip, das {topic} zugrunde liegt?",
        "Welches der folgenden Beispiele demonstriert am besten die Anwendung von {topic}?",
        "Was ist der bedeutendste Vorteil des Verstehens von {topic}?",
        "Wie unterscheidet sich {topic} grundlegend von verwandten Konzepten?",
        "Welche historische Entwicklung beeinflusste das moderne {topic} am meisten?",
      ],
      'it': [ // Italian
        "Qual è il principio fondamentale che sta alla base di {topic}?",
        "Quale delle seguenti opzioni dimostra meglio l'applicazione di {topic}?",
        "Qual è il vantaggio più significativo nel comprendere {topic}?",
        "Come si differenzia fondamentalmente {topic} da concetti correlati?",
        "Quale sviluppo storico ha influenzato maggiormente {topic} moderno?",
      ],
      'pt': [ // Portuguese
        "Qual é o princípio fundamental subjacente a {topic}?",
        "Qual das seguintes opções melhor demonstra a aplicação de {topic}?",
        "Qual é a vantagem mais significativa de entender {topic}?",
        "Como {topic} difere fundamentalmente de conceitos relacionados?",
        "Que desenvolvimento histórico mais influenciou {topic} moderno?",
      ],
      'ru': [ // Russian
        "В чём заключается основополагающий принцип {topic}?",
        "Что из перечисленного лучше всего демонстрирует применение {topic}?",
        "В чём наиболее значительное преимущество понимания {topic}?",
        "Чем {topic} принципиально отличается от связанных концепций?",
        "Какое историческое развитие больше всего повлияло на современный {topic}?",
      ],
      'ja': [ // Japanese
        "{topic}の根本的な原理は何ですか？",
        "以下のうち、{topic}の応用を最もよく示しているのはどれですか？",
        "{topic}を理解することの最も重要な利点は何ですか？",
        "{topic}は関連する概念とどのように根本的に異なりますか？",
        "現代の{topic}に最も影響を与えた歴史的発展は何ですか？",
      ],
      'ko': [ // Korean
        "{topic}의 기본 원리는 무엇입니까?",
        "다음 중 {topic}의 적용을 가장 잘 보여주는 것은 무엇입니까?",
        "{topic}를 이해하는 것의 가장 중요한 장점은 무엇입니까?",
        "{topic}는 관련 개념과 어떻게 근본적으로 다릅니까?",
        "현대 {topic}에 가장 영향을 준 역사적 발전은 무엇입니까?",
      ],
      'zh': [ // Chinese
        "{topic}的基本原理是什么？",
        "以下哪项最好地展示了{topic}的应用？",
        "理解{topic}最重要的优势是什么？",
        "{topic}与相关概念有什么根本区别？",
        "什么历史发展对现代{topic}影响最大？",
      ],
      'ar': [ // Arabic
        "ما هو المبدأ الأساسي الكامن وراء {topic}؟",
        "أي مما يلي يوضح بشكل أفضل تطبيق {topic}؟",
        "ما هي أهم ميزة لفهم {topic}؟",
        "كيف يختلف {topic} جوهريا عن المفاهيم ذات الصلة؟",
        "ما التطور التاريخي الذي أثر أكثر على {topic} الحديث؟",
      ],
      'hi': [ // Hindi
        "{topic} के अंतर्निहित मौलिक सिद्धांत क्या हैं?",
        "निम्नलिखित में से कौन सा {topic} के अनुप्रयोग को सबसे अच्छा दर्शाता है?",
        "{topic} को समझने का सबसे महत्वपूर्ण लाभ क्या है?",
        "{topic} संबंधित अवधारणाओं से मौलिक रूप से कैसे अलग है?",
        "किस ऐतिहासिक विकास ने आधुनिक {topic} को सबसे अधिक प्रभावित किया है?",
      ],
      'tr': [ // Turkish
        "{topic}'in temelindeki ana ilke nedir?",
        "Aşağıdakilerden hangisi {topic}'in uygulamasını en iyi şekilde gösterir?",
        "{topic}'i anlamanın en önemli avantajı nedir?",
        "{topic} ilgili kavramlardan temel olarak nasıl farklıdır?",
        "Modern {topic}'i en çok hangi tarihsel gelişme etkilemiştir?",
      ],
      'sv': [ // Swedish
        "Vad är den grundläggande principen bakom {topic}?",
        "Vilket av följande demonstrerar bäst tillämpningen av {topic}?",
        "Vad är den mest betydande fördelen med att förstå {topic}?",
        "Hur skiljer sig {topic} fundamentalt från relaterade begrepp?",
        "Vilken historisk utveckling påverkade modern {topic} mest?",
      ],
      'pl': [ // Polish
        "Jaka jest podstawowa zasada leżąca u podstaw {topic}?",
        "Które z poniższych najlepiej demonstruje zastosowanie {topic}?",
        "Jaka jest najważniejsza korzyść z zrozumienia {topic}?",
        "Czym {topic} różni się zasadniczo od powiązanych koncepcji?",
        "Jaki rozwój historyczny najbardziej wpłynął na nowoczesny {topic}?",
      ],
      'no': [ // Norwegian
        "Hva er det grunnleggende prinsippet som ligger til grunn for {topic}?",
        "Hvilket av følgende demonstrerer best anvendelsen av {topic}?",
        "Hva er den mest betydningsfulle fordelen ved å forstå {topic}?",
        "Hvordan skiller {topic} seg fundamentalt fra relaterte konsepter?",
        "Hvilken historisk utvikling påvirket moderne {topic} mest?",
      ],
      'nl': [ // Dutch
        "Wat is het fundamentele principe dat ten grondslag ligt aan {topic}?",
        "Welke van de volgende toont het beste de toepassing van {topic}?",
        "Wat is het belangrijkste voordeel van het begrijpen van {topic}?",
        "Hoe verschilt {topic} fundamenteel van gerelateerde concepten?",
        "Welke historische ontwikkeling beïnvloedde moderne {topic} het meest?",
      ],
    };
    
    return templates[language] ?? _questionTemplates;
  }

  static const Map<String, List<String>> _topicAnswers = {
    // Mathematics & Science
    'mathematics': [
      'Mathematics provides logical frameworks for problem-solving and abstract reasoning',
      'Mathematical concepts model real-world phenomena with precision and predictability',
      'Mathematics develops critical thinking through rigorous proof and verification',
      'Mathematical literacy enables informed decision-making in data-driven society'
    ],
    'algebra': [
      'Algebra uses symbols to represent unknown quantities and relationships',
      'Algebraic thinking enables pattern recognition and logical reasoning',
      'Algebra provides tools for solving real-world optimization problems',
      'Algebraic concepts form the foundation for advanced mathematical study'
    ],
    'calculus': [
      'Calculus studies rates of change and accumulation of quantities',
      'Calculus enables modeling of dynamic systems and continuous processes',
      'Calculus provides mathematical tools for optimization and analysis',
      'Calculus bridges discrete mathematics with continuous phenomena'
    ],
    'physics': [
      'Physics seeks to understand fundamental laws governing the universe',
      'Physics applies mathematical models to explain natural phenomena',
      'Physics drives technological innovation through theoretical discoveries',
      'Physics develops logical reasoning through experimental verification'
    ],
    'chemistry': [
      'Chemistry studies matter composition, properties, and transformations',
      'Chemistry bridges atomic-level behavior with macroscopic properties',
      'Chemistry enables design of new materials and pharmaceutical compounds',
      'Chemistry provides molecular understanding of biological processes'
    ],
    'biology': [
      'Biology examines living systems from molecular to ecosystem levels',
      'Biology applies evolutionary principles to understand life diversity',
      'Biology integrates chemistry and physics to explain life processes',
      'Biology informs medicine, agriculture, and environmental conservation'
    ],
    
    // Social Sciences & Humanities
    'history': [
      'History analyzes past events to understand present circumstances',
      'History reveals patterns in human behavior across cultures and time',
      'History develops critical thinking through evidence evaluation',
      'History provides context for contemporary political and social issues'
    ],
    'geography': [
      'Geography studies spatial relationships between people and environments',
      'Geography integrates physical and human systems analysis',
      'Geography develops spatial thinking and environmental awareness',
      'Geography addresses global challenges through spatial analysis'
    ],
    'psychology': [
      'Psychology studies human behavior, cognition, and mental processes',
      'Psychology applies scientific methods to understand mind and behavior',
      'Psychology informs education, therapy, and organizational management',
      'Psychology bridges biological and social explanations of behavior'
    ],
    'economics': [
      'Economics studies resource allocation and decision-making under scarcity',
      'Economics analyzes market behavior and government policy impacts',
      'Economics provides frameworks for understanding global trade and finance',
      'Economics applies mathematical models to predict economic outcomes'
    ],
    
    // Technology & Engineering
    'computer science': [
      'Computer science develops computational solutions to complex problems',
      'Computer science combines mathematical theory with practical implementation',
      'Computer science enables automation and digital transformation',
      'Computer science creates tools that augment human cognitive abilities'
    ],
    'programming': [
      'Programming translates human logic into machine-executable instructions',
      'Programming develops systematic problem-solving and logical thinking',
      'Programming enables creation of software tools and applications',
      'Programming requires precision, creativity, and analytical skills'
    ],
    'engineering': [
      'Engineering applies scientific principles to design practical solutions',
      'Engineering balances theoretical knowledge with real-world constraints',
      'Engineering creates infrastructure supporting modern civilization',
      'Engineering requires interdisciplinary collaboration and systems thinking'
    ],
    
    // Arts & Literature
    'literature': [
      'Literature explores human experiences through artistic expression',
      'Literature develops empathy and cultural understanding',
      'Literature preserves and transmits cultural values across generations',
      'Literature enhances communication skills and creative thinking'
    ],
    'art': [
      'Art expresses human creativity and cultural perspectives',
      'Art develops visual literacy and aesthetic appreciation',
      'Art serves as historical documentation and social commentary',
      'Art enhances cognitive development and emotional expression'
    ],
    'music': [
      'Music combines mathematical patterns with emotional expression',
      'Music develops auditory processing and cognitive abilities',
      'Music serves as universal language transcending cultural barriers',
      'Music enhances memory, focus, and creative thinking skills'
    ],
    
    // Philosophy & Ethics
    'philosophy': [
      'Philosophy examines fundamental questions about existence and knowledge',
      'Philosophy develops critical thinking and logical reasoning skills',
      'Philosophy addresses ethical dilemmas and moral decision-making',
      'Philosophy provides frameworks for understanding reality and consciousness'
    ],
    'ethics': [
      'Ethics studies moral principles guiding human behavior',
      'Ethics provides frameworks for resolving moral conflicts',
      'Ethics addresses responsibility in professional and personal contexts',
      'Ethics examines consequences of actions on individuals and society'
    ]
  };

  static Future<List<Question>> generateQuestions(String topic, {int count = 5, String language = 'en'}) async {
    try {
      // Try to generate questions using OpenAI API first
      final apiKey = await _getAPIKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        return await _generateQuestionsWithAI(topic, count, apiKey, language);
      }
    } catch (e) {
      print('AI API failed, falling back to local generation: $e');
    }
    
    // Fallback to local question generation
    return _generateQuestionsLocally(topic, count, language);
  }

  // Generate questions using OpenAI API
  static Future<List<Question>> _generateQuestionsWithAI(String topic, int count, String apiKey, String language) async {
    // Map language codes to language names for AI prompts
    final languageNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ja': 'Japanese',
      'ko': 'Korean',
      'nl': 'Dutch',
      'zh': 'Chinese',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'tr': 'Turkish',
      'sv': 'Swedish',
      'pl': 'Polish',
      'no': 'Norwegian',
    };
    
    final targetLanguage = languageNames[language] ?? 'English';
    
    final prompt = '''
You are an expert educational quiz generator. Create $count high-quality, interactive multiple-choice questions about "$topic".

**IMPORTANT: Generate ALL content (questions, answers, explanations, etc.) in $targetLanguage language. The user has selected $targetLanguage as their preferred language.**

For each question, provide:
1. A clear, specific, and engaging question that tests understanding
2. Four plausible answer options (A, B, C, D)
3. The correct answer index (0-3)
4. A detailed explanation of why the answer is correct
5. Educational insights about the topic
6. Learning recommendations for improvement
7. Real-world applications or examples
8. Common misconceptions to avoid

Format the response as JSON:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_answer": 0,
      "explanation": "Detailed explanation of the correct answer",
      "difficulty": "Easy/Medium/Hard",
      "learning_objective": "What this question teaches",
      "real_world_application": "How this applies in real life",
      "common_mistakes": "Common errors students make",
      "study_tips": "How to better understand this concept",
      "related_concepts": ["concept1", "concept2"]
    }
  ],
  "topic_overview": {
    "description": "Brief overview of the topic",
    "key_concepts": ["concept1", "concept2", "concept3"],
    "difficulty_level": "Overall difficulty assessment",
    "learning_resources": ["resource1", "resource2"]
  }
}

Make questions educational, engaging, and comprehensive about $topic. Ensure questions test different aspects and skill levels.

**Remember: ALL content must be in $targetLanguage language to match the user's language preference.**
''';

    final response = await http.post(
      Uri.parse(_openAIURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
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
      
      final topicOverview = questionsData['topic_overview'] ?? {};
      
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
          learningObjective: q['learning_objective'] ?? '',
          realWorldApplication: q['real_world_application'] ?? '',
          commonMistakes: q['common_mistakes'] ?? '',
          studyTips: q['study_tips'] ?? '',
          relatedConcepts: List<String>.from(q['related_concepts'] ?? []),
          topicOverview: TopicOverview(
            description: topicOverview['description'] ?? '',
            keyConcepts: List<String>.from(topicOverview['key_concepts'] ?? []),
            difficultyLevel: topicOverview['difficulty_level'] ?? 'Medium',
            learningResources: List<String>.from(topicOverview['learning_resources'] ?? []),
          ),
        ));
      }
      
      return questions;
    } else {
      throw Exception('Failed to generate questions: ${response.statusCode}');
    }
  }

  // Enhanced local question generation with premium quality
  static List<Question> _generateQuestionsLocally(String topic, int count, String language) {
    final random = Random();
    final questions = <Question>[];
    final normalizedTopic = topic.toLowerCase().trim();
    
    // Get localized templates for the specified language
    final localizedTemplates = _getLocalizedQuestionTemplates(language);
    
    // Advanced topic matching with intelligent content generation
    for (int i = 0; i < count; i++) {
      final template = localizedTemplates[random.nextInt(localizedTemplates.length)];
      final questionText = template.replaceAll('{topic}', topic);
      
      // Generate sophisticated answers with educational depth
      final answers = _generateAdvancedAnswersForTopic(normalizedTopic, random, i, language);
      final correctIndex = 0; // First answer is always correct for quality
      
      questions.add(Question(
        id: i + 1,
        text: questionText,
        options: answers,
        correctIndex: correctIndex,
        topic: topic,
        difficulty: _getDifficultyForQuestion(i),
        explanation: _generateDetailedExplanation(topic, answers[correctIndex], normalizedTopic, language),
        learningObjective: _generateLearningObjective(topic, normalizedTopic, language),
        realWorldApplication: _generateRealWorldApplication(topic, normalizedTopic, language),
        commonMistakes: _generateCommonMistakes(topic, normalizedTopic, language),
        studyTips: _generateAdvancedStudyTips(topic, normalizedTopic, language),
        relatedConcepts: _generateRelatedConcepts(topic, normalizedTopic, language),
        topicOverview: TopicOverview(
          description: _generateTopicDescription(topic, normalizedTopic, language),
          keyConcepts: _generateKeyConcepts(topic, normalizedTopic, language),
          difficultyLevel: _assessTopicDifficulty(normalizedTopic),
          learningResources: _generateLearningResources(topic, normalizedTopic, language),
        ),
      ));
    }
    
    return questions;
  }

  static List<String> _generateAdvancedAnswersForTopic(String topic, Random random, int questionIndex, String language) {
    final answers = <String>[];
    
    // Find the best matching topic category
    String? matchedKey = _findBestTopicMatch(topic);
    
    if (matchedKey != null) {
      // Get localized answers for the matched topic
      final topicAnswers = _getLocalizedTopicAnswers(matchedKey, language);
      // Select correct answer based on question complexity
      final correctAnswer = topicAnswers[questionIndex % topicAnswers.length];
      answers.add(correctAnswer);
      
      // Generate sophisticated distractors in the selected language
      answers.addAll(_generateEducationalDistractors(matchedKey, correctAnswer, topic, language));
    } else {
      // Generate comprehensive generic answers for unknown topics
      answers.add(_generateContextualAnswer(topic, questionIndex, language));
      answers.addAll(_generateGenericDistractors(topic, language));
    }
    
    // Ensure we have exactly 4 options
    while (answers.length < 4) {
      answers.add(_generatePlausibleDistractor(topic, answers, language));
    }
    
    return answers.take(4).toList();
  }
  
  // Get localized topic answers based on language
  static List<String> _getLocalizedTopicAnswers(String topicKey, String language) {
    final localizedAnswers = {
      'mathematics': {
        'en': [
          'Mathematics provides logical frameworks for problem-solving and abstract reasoning',
          'Mathematical concepts model real-world phenomena with precision and predictability',
          'Mathematics develops critical thinking through rigorous proof and verification',
          'Mathematical literacy enables informed decision-making in data-driven society'
        ],
        'es': [
          'Las matemáticas proporcionan marcos lógicos para la resolución de problemas y el razonamiento abstracto',
          'Los conceptos matemáticos modelan fenómenos del mundo real con precisión y predictibilidad',
          'Las matemáticas desarrollan el pensamiento crítico a través de pruebas rigurosas y verificación',
          'La alfabetización matemática permite la toma de decisiones informadas en la sociedad basada en datos'
        ],
        'fr': [
          'Les mathématiques fournissent des cadres logiques pour la résolution de problèmes et le raisonnement abstrait',
          'Les concepts mathématiques modélisent les phénomènes du monde réel avec précision et prévisibilité',
          'Les mathématiques développent la pensée critique grâce à des preuves rigoureuses et la vérification',
          'La littératie mathématique permet une prise de décision éclairée dans une société axée sur les données'
        ],
        'de': [
          'Mathematik bietet logische Rahmen für Problemlösung und abstraktes Denken',
          'Mathematische Konzepte modellieren reale Phänomene mit Präzision und Vorhersagbarkeit',
          'Mathematik entwickelt kritisches Denken durch rigorose Beweise und Verifikation',
          'Mathematische Kompetenz ermöglicht informierte Entscheidungsfindung in der datengetriebenen Gesellschaft'
        ],
        'it': [
          'La matematica fornisce framework logici per la risoluzione di problemi e il ragionamento astratto',
          'I concetti matematici modellano i fenomeni del mondo reale con precisione e prevedibilità',
          'La matematica sviluppa il pensiero critico attraverso prove rigorose e verifica',
          'L\'alfabetizzazione matematica consente decisioni informate nella società basata sui dati'
        ],
        'pt': [
          'A matemática fornece estruturas lógicas para resolução de problemas e raciocínio abstrato',
          'Conceitos matemáticos modelam fenômenos do mundo real com precisão e previsibilidade',
          'A matemática desenvolve pensamento crítico através de provas rigorosas e verificação',
          'A literacia matemática permite tomada de decisões informadas na sociedade baseada em dados'
        ],
        'ru': [
          'Математика предоставляет логические рамки для решения проблем и абстрактного мышления',
          'Математические концепции моделируют реальные явления с точностью и предсказуемостью',
          'Математика развивает критическое мышление через строгие доказательства и верификацию',
          'Математическая грамотность позволяет принимать обоснованные решения в обществе, основанном на данных'
        ],
      },
      'physics': {
        'en': [
          'Physics seeks to understand fundamental laws governing the universe',
          'Physics applies mathematical models to explain natural phenomena',
          'Physics drives technological innovation through theoretical discoveries',
          'Physics develops logical reasoning through experimental verification'
        ],
        'es': [
          'La física busca entender las leyes fundamentales que gobiernan el universo',
          'La física aplica modelos matemáticos para explicar fenómenos naturales',
          'La física impulsa la innovación tecnológica a través de descubrimientos teóricos',
          'La física desarrolla el razonamiento lógico a través de la verificación experimental'
        ],
        'fr': [
          'La physique cherche à comprendre les lois fondamentales qui régissent l\'univers',
          'La physique applique des modèles mathématiques pour expliquer les phénomènes naturels',
          'La physique stimule l\'innovation technologique grâce aux découvertes théoriques',
          'La physique développe le raisonnement logique par la vérification expérimentale'
        ],
        'de': [
          'Physik versucht die fundamentalen Gesetze zu verstehen, die das Universum regieren',
          'Physik wendet mathematische Modelle an, um natürliche Phänomene zu erklären',
          'Physik treibt technologische Innovation durch theoretische Entdeckungen voran',
          'Physik entwickelt logisches Denken durch experimentelle Verifikation'
        ],
      },
      // Add more localized topics as needed
    };
    
    // Return localized answers for the topic and language, fallback to English
    if (localizedAnswers.containsKey(topicKey)) {
      final topicData = localizedAnswers[topicKey]!;
      return topicData[language] ?? topicData['en'] ?? _topicAnswers[topicKey] ?? [];
    }
    
    // Fallback to original English answers if no localized version exists
    return _topicAnswers[topicKey] ?? [];
  }
  
  static String? _findBestTopicMatch(String topic) {
    final topicLower = topic.toLowerCase();
    
    // Direct matches first
    for (final key in _topicAnswers.keys) {
      if (topicLower.contains(key) || key.contains(topicLower.split(' ').first)) {
        return key;
      }
    }
    
    // Partial matches for compound topics
    for (final key in _topicAnswers.keys) {
      final topicWords = topicLower.split(RegExp(r'[\s-]'));
      for (final word in topicWords) {
        if (word.length > 3 && (key.contains(word) || word.contains(key))) {
          return key;
        }
      }
    }
    
    return null;
  }
  
  static List<String> _generateEducationalDistractors(String matchedKey, String correctAnswer, String topic, String language) {
    final distractors = <String>[];
    // Get localized answers for this topic and language
    final allAnswers = _getLocalizedTopicAnswers(matchedKey, language);
    
    // Use other answers from the same category as sophisticated distractors
    for (final answer in allAnswers) {
      if (answer != correctAnswer && distractors.length < 3) {
        distractors.add(answer);
      }
    }
    
    // If we need more distractors, use related field answers in the same language
    if (distractors.length < 3) {
      final relatedFields = _getRelatedFields(matchedKey);
      for (final field in relatedFields) {
        if (distractors.length < 3) {
          final relatedAnswers = _getLocalizedTopicAnswers(field, language);
          if (relatedAnswers.isNotEmpty) {
            distractors.add(relatedAnswers.first);
          }
        }
      }
    }
    
    return distractors;
  }
  
  static List<String> _getRelatedFields(String field) {
    const fieldRelations = {
      'mathematics': ['physics', 'computer science', 'engineering'],
      'physics': ['mathematics', 'chemistry', 'engineering'],
      'chemistry': ['physics', 'biology', 'mathematics'],
      'biology': ['chemistry', 'psychology', 'geography'],
      'history': ['geography', 'literature', 'philosophy'],
      'literature': ['history', 'philosophy', 'art'],
      'computer science': ['mathematics', 'engineering', 'physics'],
      'psychology': ['biology', 'philosophy', 'economics'],
      'economics': ['psychology', 'history', 'geography'],
    };
    
    return fieldRelations[field] ?? [];
  }
  
  static String _generateContextualAnswer(String topic, int questionIndex, String language) {
    final templates = {
      'en': [
        "$topic requires systematic study and deep understanding of core principles",
        "$topic involves complex relationships between theoretical concepts and practical applications",
        "$topic demonstrates the importance of evidence-based reasoning and critical analysis",
        "$topic connects fundamental theories with real-world problem-solving strategies",
        "$topic emphasizes the integration of knowledge across multiple related disciplines"
      ],
      'es': [
        "$topic requiere estudio sistemático y comprensión profunda de los principios fundamentales",
        "$topic involucra relaciones complejas entre conceptos teóricos y aplicaciones prácticas",
        "$topic demuestra la importancia del razonamiento basado en evidencia y análisis crítico",
        "$topic conecta teorías fundamentales con estrategias de resolución de problemas del mundo real",
        "$topic enfatiza la integración del conocimiento a través de múltiples disciplinas relacionadas"
      ],
      'fr': [
        "$topic nécessite une étude systématique et une compréhension approfondie des principes fondamentaux",
        "$topic implique des relations complexes entre les concepts théoriques et les applications pratiques",
        "$topic démontre l'importance du raisonnement basé sur les preuves et de l'analyse critique",
        "$topic relie les théories fondamentales aux stratégies de résolution de problèmes du monde réel",
        "$topic met l'accent sur l'intégration des connaissances à travers plusieurs disciplines connexes"
      ],
      'de': [
        "$topic erfordert systematisches Studium und tiefes Verständnis der Grundprinzipien",
        "$topic umfasst komplexe Beziehungen zwischen theoretischen Konzepten und praktischen Anwendungen",
        "$topic demonstriert die Wichtigkeit evidenzbasierter Argumentation und kritischer Analyse",
        "$topic verbindet fundamentale Theorien mit realen Problemlösungsstrategien",
        "$topic betont die Integration von Wissen über mehrere verwandte Disziplinen hinweg"
      ],
      // Add more languages as needed...
    };
    
    final languageTemplates = templates[language] ?? templates['en']!;
    return languageTemplates[questionIndex % languageTemplates.length];
  }
  
  static List<String> _generateGenericDistractors(String topic, String language) {
    final templates = {
      'en': [
        "$topic is primarily memorization-based with limited practical applications",
        "$topic can be fully understood through casual observation without systematic study",
        "$topic is an outdated field with little relevance to modern society"
      ],
      'es': [
        "$topic se basa principalmente en la memorización con aplicaciones prácticas limitadas",
        "$topic puede entenderse completamente a través de la observación casual sin estudio sistemático",
        "$topic es un campo obsoleto con poca relevancia para la sociedad moderna"
      ],
      'fr': [
        "$topic est principalement basé sur la mémorisation avec des applications pratiques limitées",
        "$topic peut être entièrement compris par l'observation occasionnelle sans étude systématique",
        "$topic est un domaine obsolète avec peu de pertinence pour la société moderne"
      ],
      'de': [
        "$topic basiert hauptsächlich auf Auswendiglernen mit begrenzten praktischen Anwendungen",
        "$topic kann durch gelegentliche Beobachtung ohne systematisches Studium vollständig verstanden werden",
        "$topic ist ein veraltetes Feld mit geringer Relevanz für die moderne Gesellschaft"
      ],
      // Add more languages as needed...
    };
    
    return templates[language] ?? templates['en']!;
  }
  
  static String _generatePlausibleDistractor(String topic, List<String> existingAnswers, String language) {
    final templates = {
      'en': [
        "$topic represents a specialized area requiring only basic foundational knowledge",
        "$topic is best understood through intuitive approaches rather than systematic study",
        "$topic has limited connections to other academic disciplines or fields"
      ],
      'es': [
        "$topic representa un área especializada que requiere solo conocimientos básicos fundamentales",
        "$topic se entiende mejor a través de enfoques intuitivos en lugar de estudio sistemático",
        "$topic tiene conexiones limitadas con otras disciplinas o campos académicos"
      ],
      'fr': [
        "$topic représente un domaine spécialisé nécessitant seulement des connaissances fondamentales de base",
        "$topic est mieux compris par des approches intuitives plutôt que par une étude systématique",
        "$topic a des connexions limitées avec d'autres disciplines ou domaines académiques"
      ],
      'de': [
        "$topic stellt einen spezialisierten Bereich dar, der nur grundlegende Grundkenntnisse erfordert",
        "$topic wird am besten durch intuitive Ansätze statt durch systematisches Studium verstanden",
        "$topic hat begrenzte Verbindungen zu anderen akademischen Disziplinen oder Bereichen"
      ],
      // Add more languages as needed...
    };
    
    final languageTemplates = templates[language] ?? templates['en']!;
    for (final template in languageTemplates) {
      if (!existingAnswers.contains(template)) {
        return template;
      }
    }
    
    // Fallback
    final fallbackTemplates = {
      'en': "$topic offers straightforward solutions to complex interdisciplinary challenges",
      'es': "$topic ofrece soluciones directas a desafíos interdisciplinarios complejos",
      'fr': "$topic offre des solutions simples aux défis interdisciplinaires complexes",
      'de': "$topic bietet einfache Lösungen für komplexe interdisziplinäre Herausforderungen",
    };
    
    return fallbackTemplates[language] ?? fallbackTemplates['en']!;
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

  static String _generateDetailedExplanation(String topic, String correctAnswer, String normalizedTopic, String language) {
    // For now, keep English explanations with a note about language support
    // In a production app, you would add full localization here
    final explanationTemplates = {
      'mathematics': "This mathematical concept demonstrates how $topic provides logical frameworks for understanding quantitative relationships. $correctAnswer This principle forms the foundation for advanced mathematical reasoning and problem-solving.",
      'physics': "In physics, $topic illustrates fundamental principles governing natural phenomena. $correctAnswer This understanding enables prediction and manipulation of physical systems.",
      'chemistry': "Chemistry shows how $topic involves molecular-level interactions that determine macroscopic properties. $correctAnswer This knowledge is essential for materials science and biochemical applications.",
      'biology': "Biological systems demonstrate how $topic operates across multiple levels of organization. $correctAnswer This principle is crucial for understanding life processes and evolutionary adaptations.",
      'history': "Historical analysis reveals how $topic shaped human civilization and cultural development. $correctAnswer This understanding provides context for contemporary social and political structures.",
      'literature': "Literary studies show how $topic reflects and influences human consciousness and cultural expression. $correctAnswer This insight enhances appreciation for artistic and intellectual heritage.",
      'computer science': "In computer science, $topic demonstrates computational thinking and algorithmic problem-solving. $correctAnswer This approach enables creation of efficient and scalable technological solutions.",
      'psychology': "Psychological research shows how $topic influences human behavior and cognitive processes. $correctAnswer This knowledge informs therapeutic interventions and educational strategies."
    };
    
    for (final key in explanationTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return explanationTemplates[key]!;
      }
    }
    
    return "Understanding $topic requires systematic analysis of underlying principles and their applications. $correctAnswer This knowledge enables deeper comprehension and practical implementation in relevant contexts.";
  }
  
  static String _generateLearningObjective(String topic, String normalizedTopic, String language) {
    // For now, keep English objectives with a note about language support
    // In a production app, you would add full localization here
    final objectiveTemplates = {
      'mathematics': "Develop analytical thinking and problem-solving skills through $topic",
      'physics': "Understand fundamental laws governing $topic and their applications",
      'chemistry': "Master molecular principles underlying $topic phenomena",
      'biology': "Comprehend life processes and evolutionary principles in $topic",
      'history': "Analyze historical patterns and their contemporary relevance in $topic",
      'literature': "Develop critical thinking and cultural awareness through $topic",
      'computer science': "Build computational thinking and algorithmic reasoning with $topic",
      'psychology': "Understand human behavior and cognitive processes in $topic contexts",
      'philosophy': "Develop logical reasoning and ethical thinking through $topic",
      'economics': "Analyze resource allocation and decision-making principles in $topic"
    };
    
    for (final key in objectiveTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return objectiveTemplates[key]!;
      }
    }
    
    return "Develop comprehensive understanding and practical application skills in $topic";
  }
  
  static String _generateRealWorldApplication(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final applicationTemplates = {
      'mathematics': 'Applied in financial modeling, engineering design, data analysis, artificial intelligence, and scientific research across all disciplines',
      'algebra': 'Essential for computer programming, economic forecasting, engineering calculations, and optimization problems in business and science',
      'calculus': 'Used in physics simulations, economic modeling, medical imaging, climate science, and artificial intelligence algorithms',
      'physics': 'Drives innovation in renewable energy, medical devices, telecommunications, aerospace engineering, and quantum computing',
      'chemistry': 'Critical for pharmaceutical development, materials engineering, environmental remediation, food science, and nanotechnology',
      'biology': 'Applied in medicine, biotechnology, conservation, agriculture, forensics, and development of sustainable technologies',
      'history': 'Informs policy-making, cultural understanding, international relations, legal systems, and social justice initiatives',
      'literature': 'Enhances communication skills, empathy, cross-cultural understanding, and provides frameworks for media analysis',
      'geography': 'Essential for urban planning, environmental management, disaster response, global business strategy, and climate change adaptation',
      'computer science': 'Powers modern technology including smartphones, internet, social media, medical devices, and autonomous systems',
      'programming': 'Creates software applications, automates business processes, enables scientific research, and drives digital innovation',
      'psychology': 'Applied in education, therapy, marketing, user experience design, organizational management, and public health',
      'economics': 'Guides government policy, business strategy, investment decisions, and international trade agreements',
      'philosophy': 'Provides frameworks for ethical decision-making in medicine, technology, law, and public policy',
      'ethics': 'Essential for professional conduct in medicine, engineering, journalism, business, and technology development'
    };
    
    for (final key in applicationTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return applicationTemplates[key]!;
      }
    }
    
    return "$topic has numerous practical applications in professional, academic, and personal contexts, providing valuable skills for career advancement and informed citizenship";
  }
  
  static String _generateCommonMistakes(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final mistakeTemplates = {
      'mathematics': "Avoiding memorization without understanding, skipping steps in problem-solving, confusing correlation with causation, and not checking answers for reasonableness",
      'physics': "Memorizing formulas without understanding physical principles, ignoring units and dimensional analysis, confusing mathematical models with physical reality, and not considering limiting cases",
      'chemistry': "Confusing molecular structure with chemical properties, ignoring stoichiometry in reactions, mixing up acids and bases, and not considering reaction conditions",
      'biology': "Oversimplifying complex biological processes, confusing genotype with phenotype, ignoring environmental factors in biological systems, and not considering evolutionary context",
      'history': "Viewing historical events through modern perspectives, oversimplifying complex historical causes, ignoring primary source reliability, and not considering multiple historical interpretations",
      'literature': "Focusing only on plot summary rather than literary analysis, ignoring historical and cultural context, over-interpreting minor details, and not supporting interpretations with textual evidence",
      'computer science': "Focusing on syntax rather than algorithmic thinking, not considering edge cases in programming, ignoring computational complexity, and not testing code thoroughly",
      'psychology': "Overgeneralizing research findings, confusing correlation with causation, ignoring cultural and individual differences, and not considering ethical implications of psychological research"
    };
    
    for (final key in mistakeTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return mistakeTemplates[key]!;
      }
    }
    
    return "Common mistakes in $topic include oversimplifying complex concepts, not connecting theory to practice, avoiding difficult material, and not seeking help when needed";
  }
  
  static String _assessTopicDifficulty(String normalizedTopic) {
    const beginner = ['basics', 'introduction', 'fundamentals', 'overview'];
    const intermediate = ['analysis', 'application', 'theory', 'principles'];
    const advanced = ['research', 'advanced', 'complex', 'graduate', 'phd', 'quantum', 'differential'];
    
    for (final keyword in advanced) {
      if (normalizedTopic.contains(keyword)) return 'Advanced';
    }
    
    for (final keyword in beginner) {
      if (normalizedTopic.contains(keyword)) return 'Beginner';
    }
    
    for (final keyword in intermediate) {
      if (normalizedTopic.contains(keyword)) return 'Intermediate';
    }
    
    // Default based on topic complexity
    const complexTopics = ['calculus', 'quantum', 'organic chemistry', 'neuroscience', 'philosophy'];
    for (final complex in complexTopics) {
      if (normalizedTopic.contains(complex)) return 'Advanced';
    }
    
    return 'Intermediate';
  }
  
  static String _generateAdvancedStudyTips(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final studyTipTemplates = {
      'mathematics': "Practice regularly with progressively challenging problems, focus on understanding concepts rather than memorizing formulas, work through proofs step-by-step, and connect abstract concepts to real-world applications",
      'physics': "Visualize concepts through diagrams and simulations, practice dimensional analysis, work through derivations from first principles, and connect mathematical formulations to physical intuition",
      'chemistry': "Master the periodic table patterns, practice balancing equations, visualize molecular structures, and understand the connection between microscopic behavior and macroscopic properties",
      'biology': "Create concept maps linking different biological systems, use mnemonics for complex processes, study with visual aids and models, and relate biological concepts to personal health and environmental issues",
      'history': "Create timelines and concept maps, analyze primary sources critically, connect historical events to contemporary issues, and practice writing analytical essays with evidence-based arguments",
      'literature': "Read actively with annotations, analyze literary devices and themes, discuss interpretations with others, and connect texts to historical and cultural contexts",
      'computer science': "Code regularly to reinforce concepts, break down complex problems into smaller components, debug systematically, and study algorithms by implementing them from scratch",
      'psychology': "Connect theories to personal experiences and observations, critically evaluate research methods and findings, practice applying concepts to real-world scenarios, and stay current with recent research"
    };
    
    for (final key in studyTipTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return studyTipTemplates[key]!;
      }
    }
    
    return "Develop deep understanding through active learning: ask questions, make connections between concepts, apply knowledge to practical problems, and teach concepts to others to reinforce your understanding";
  }
  
  static List<String> _generateRelatedConcepts(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final conceptMaps = {
      'mathematics': ['Logical Reasoning', 'Problem Solving', 'Pattern Recognition', 'Abstract Thinking', 'Quantitative Analysis'],
      'algebra': ['Functions', 'Equations', 'Variables', 'Mathematical Modeling', 'Pattern Recognition'],
      'calculus': ['Limits', 'Derivatives', 'Integrals', 'Differential Equations', 'Mathematical Analysis'],
      'physics': ['Scientific Method', 'Mathematical Modeling', 'Energy Conservation', 'Wave-Particle Duality', 'Systems thinking'],
      'chemistry': ['Molecular Structure', 'Chemical Bonding', 'Thermodynamics', 'Kinetics', 'Equilibrium'],
      'biology': ['Evolution', 'Genetics', 'Ecology', 'Cell Biology', 'Physiology'],
      'history': ['Chronological Thinking', 'Causation', 'Historical Context', 'Primary Sources', 'Cultural Analysis'],
      'literature': ['Literary Analysis', 'Cultural Context', 'Narrative Techniques', 'Symbolism', 'Character Development'],
      'computer science': ['Algorithms', 'Data Structures', 'Computational Thinking', 'Software Engineering', 'System Design'],
      'psychology': ['Research Methods', 'Cognitive Processes', 'Behavioral Analysis', 'Statistical Analysis', 'Experimental Design'],
      'economics': ['Supply and Demand', 'Market Analysis', 'Statistical Modeling', 'Policy Analysis', 'Resource Allocation'],
      'philosophy': ['Logic', 'Ethics', 'Epistemology', 'Critical Thinking', 'Argumentation'],
      'geography': ['Spatial Analysis', 'Environmental Systems', 'Human-Environment Interaction', 'Geographic Information Systems', 'Regional Studies']
    };
    
    for (final key in conceptMaps.keys) {
      if (normalizedTopic.contains(key)) {
        return conceptMaps[key]!;
      }
    }
    
    return ['Critical Thinking', 'Analysis', 'Application', 'Synthesis', 'Evaluation'];
  }
  
  static String _generateTopicDescription(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final descriptionTemplates = {
      'mathematics': "$topic is a fundamental branch of mathematics that develops logical reasoning, problem-solving skills, and provides tools for modeling real-world phenomena through abstract thinking and quantitative analysis",
      'physics': "$topic in physics explores the fundamental laws governing natural phenomena, combining theoretical understanding with experimental verification to explain how the universe operates",
      'chemistry': "$topic involves the study of matter at the molecular level, examining how atomic and molecular interactions determine the properties and behavior of substances",
      'biology': "$topic examines living systems and life processes, integrating principles from chemistry and physics to understand how organisms function, evolve, and interact with their environment",
      'history': "$topic analyzes past human experiences and events, providing context for understanding contemporary society and developing critical thinking skills about cause and effect",
      'literature': "$topic explores human experiences through artistic expression, developing critical thinking, cultural awareness, and communication skills while preserving and transmitting cultural heritage",
      'computer science': "$topic applies computational thinking and algorithmic problem-solving to create technological solutions, bridging theoretical computer science with practical software development",
      'psychology': "$topic studies human behavior and mental processes using scientific methods, providing insights into cognition, emotion, learning, and social interaction"
    };
    
    for (final key in descriptionTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return descriptionTemplates[key]!;
      }
    }
    
    return "$topic is a comprehensive field of study that integrates theoretical knowledge with practical applications, developing critical thinking skills and providing valuable insights for personal and professional growth";
  }
  
  static List<String> _generateKeyConcepts(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final keyConceptMaps = {
      'mathematics': ['Mathematical Reasoning', 'Problem-Solving Strategies', 'Abstract Thinking', 'Logical Proof'],
      'physics': ['Natural Laws', 'Mathematical Models', 'Experimental Methods', 'Energy and Matter'],
      'chemistry': ['Atomic Theory', 'Chemical Bonding', 'Molecular Interactions', 'Reaction Mechanisms'],
      'biology': ['Evolution', 'Cellular Processes', 'Genetic Inheritance', 'Ecological Relationships'],
      'history': ['Historical Context', 'Cause and Effect', 'Primary Sources', 'Cultural Perspectives'],
      'literature': ['Literary Devices', 'Thematic Analysis', 'Cultural Context', 'Narrative Structure'],
      'computer science': ['Algorithmic Thinking', 'Data Management', 'Software Design', 'Computational Complexity'],
      'psychology': ['Research Methods', 'Cognitive Processes', 'Behavioral Patterns', 'Statistical Analysis']
    };
    
    for (final key in keyConceptMaps.keys) {
      if (normalizedTopic.contains(key)) {
        return keyConceptMaps[key]!;
      }
    }
    
    return ['Core Principles', 'Practical Applications', 'Analytical Methods', 'Contemporary Relevance'];
  }
  
  static List<String> _generateLearningResources(String topic, String normalizedTopic, String language) {
    // Language support can be added here in future updates
    final resourceTemplates = {
      'mathematics': ['Interactive problem-solving platforms', 'Visual proof demonstrations', 'Mathematical modeling software', 'Peer tutoring groups'],
      'physics': ['Laboratory experiments and simulations', 'Video demonstrations of physical phenomena', 'Mathematical derivation practice', 'Physics problem-solving communities'],
      'chemistry': ['Molecular visualization software', 'Laboratory safety and techniques videos', 'Chemical reaction databases', 'Chemistry study groups'],
      'biology': ['Anatomical models and diagrams', 'Scientific journal articles', 'Field guides and identification tools', 'Biology research methodologies'],
      'history': ['Primary source document collections', 'Historical documentaries and films', 'Archaeological evidence databases', 'Historical analysis workshops'],
      'literature': ['Literary criticism collections', 'Author biography resources', 'Cultural context materials', 'Writing and analysis workshops'],
      'computer science': ['Programming practice platforms', 'Algorithm visualization tools', 'Software development communities', 'Technical documentation and tutorials'],
      'psychology': ['Research methodology guides', 'Statistical analysis software', 'Case study collections', 'Peer-reviewed psychology journals']
    };
    
    for (final key in resourceTemplates.keys) {
      if (normalizedTopic.contains(key)) {
        return resourceTemplates[key]!;
      }
    }
    
    return [
      'Academic textbooks and scholarly articles',
      'Online courses and video lectures',
      'Interactive learning platforms and simulations',
      'Study groups and expert discussions',
      'Practical exercises and real-world applications'
    ];
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

class TopicOverview {
  final String description;
  final List<String> keyConcepts;
  final String difficultyLevel;
  final List<String> learningResources;

  TopicOverview({
    required this.description,
    required this.keyConcepts,
    required this.difficultyLevel,
    required this.learningResources,
  });
}

class Question {
  final int id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String topic;
  final String difficulty;
  final String explanation;
  final String learningObjective;
  final String realWorldApplication;
  final String commonMistakes;
  final String studyTips;
  final List<String> relatedConcepts;
  final TopicOverview topicOverview;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.topic,
    required this.difficulty,
    required this.explanation,
    this.learningObjective = '',
    this.realWorldApplication = '',
    this.commonMistakes = '',
    this.studyTips = '',
    this.relatedConcepts = const [],
    TopicOverview? topicOverview,
  }) : topicOverview = topicOverview ?? TopicOverview(
         description: '',
         keyConcepts: [],
         difficultyLevel: 'Medium',
         learningResources: [],
       );

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
  String get correctAnswer => options[correctIndex];
  
  // Performance analysis methods
  double getComprehensionLevel(bool wasCorrect, int timeSpent) {
    double baseScore = wasCorrect ? 1.0 : 0.0;
    
    // Adjust based on difficulty
    switch (difficulty.toLowerCase()) {
      case 'easy':
        baseScore *= 0.8;
        break;
      case 'hard':
        baseScore *= 1.2;
        break;
      default: // medium
        baseScore *= 1.0;
    }
    
    // Time bonus (faster correct answers get slight bonus)
    if (wasCorrect && timeSpent < 15) {
      baseScore += 0.1;
    }
    
    return baseScore.clamp(0.0, 1.0);
  }
  
  String getPerformanceFeedback(bool wasCorrect, int timeSpent) {
    if (wasCorrect) {
      if (timeSpent < 10) {
        return "⚡ Excellent! Quick and accurate response shows strong understanding.";
      } else if (timeSpent < 20) {
        return "✅ Great job! You demonstrate solid knowledge of this concept.";
      } else {
        return "👍 Correct! Take time to review to improve response speed.";
      }
    } else {
      if (timeSpent < 10) {
        return "🤔 Quick response, but incorrect. Consider reading more carefully.";
      } else {
        return "📚 This concept needs more study. Review the explanation and practice similar problems.";
      }
    }
  }
}