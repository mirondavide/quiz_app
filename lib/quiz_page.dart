import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'question.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_widgets.dart';
import 'widgets/premium_navigation.dart';
import 'widgets/advanced_effects.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int currentQuestion = 0;
  int totalScore = 0;
  List<bool> answeredQuestions = [];
  List<bool> correctAnswers = [];
  bool isAnswered = false;
  int? selectedAnswer;
  
  late AnimationController _questionController;
  late AnimationController _progressController;
  late ConfettiController _confettiController;
  late Animation<double> _questionAnimation;
  late Animation<double> _progressAnimation;
  
  List<Question> questions = [
    Question(
      text: "Qual è la capitale d'Italia?",
      options: ["Roma", "Milano", "Napoli", "Torino"],
      correctAnswerIndex: 0,
      explanation: "Roma è la capitale d'Italia dal 1871, quando l'Italia fu unificata.",
      categoryIcon: Icons.location_city,
      categoryColor: Colors.blue,
      category: "Geografia",
      difficulty: QuestionDifficulty.easy,
    ),
    Question(
      text: "Quanto fa 5 × 5?",
      options: ["10", "25", "15", "30"],
      correctAnswerIndex: 1,
      explanation: "5 × 5 = 25. È una delle tabelline di base della matematica.",
      categoryIcon: Icons.calculate,
      categoryColor: Colors.green,
      category: "Matematica",
      difficulty: QuestionDifficulty.easy,
    ),
    Question(
      text: "Qual è l'animale simbolo dell'Australia?",
      options: ["Canguro", "Elefante", "Leone", "Pinguino"],
      correctAnswerIndex: 0,
      explanation: "Il canguro è l'animale simbolo dell'Australia ed è presente anche nello stemma nazionale.",
      categoryIcon: Icons.pets,
      categoryColor: Colors.orange,
      category: "Natura",
      difficulty: QuestionDifficulty.medium,
    ),
    Question(
      text: "Quale pianeta è conosciuto come il Pianeta Rosso?",
      options: ["Venere", "Marte", "Giove", "Saturno"],
      correctAnswerIndex: 1,
      explanation: "Marte è chiamato il Pianeta Rosso a causa del ferro ossidato sulla sua superficie.",
      categoryIcon: Icons.public,
      categoryColor: Colors.red,
      category: "Astronomia",
      difficulty: QuestionDifficulty.medium,
    ),
    Question(
      text: "Chi ha dipinto la Gioconda?",
      options: ["Michelangelo", "Leonardo da Vinci", "Raffaello", "Donatello"],
      correctAnswerIndex: 1,
      explanation: "La Gioconda (Monna Lisa) è stata dipinta da Leonardo da Vinci tra il 1503 e il 1506.",
      categoryIcon: Icons.brush,
      categoryColor: Colors.purple,
      category: "Arte",
      difficulty: QuestionDifficulty.hard,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize answer tracking
    answeredQuestions = List.filled(questions.length, false);
    correctAnswers = List.filled(questions.length, false);
    
    // Initialize animations
    _questionController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _confettiController = ConfettiController(
      duration: Duration(seconds: 2),
    );
    
    _questionAnimation = CurvedAnimation(
      parent: _questionController,
      curve: Curves.elasticOut,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    
    // Start initial animations
    _questionController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (isAnswered) return;
    
    HapticFeedback.selectionClick();
    
    setState(() {
      selectedAnswer = index;
      isAnswered = true;
      answeredQuestions[currentQuestion] = true;
      
      bool isCorrect = index == questions[currentQuestion].correctAnswerIndex;
      correctAnswers[currentQuestion] = isCorrect;
      
      if (isCorrect) {
        totalScore += questions[currentQuestion].points;
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
    
    // Show result feedback
    _showAnswerFeedback();
    
    // Auto-advance after showing explanation
    Future.delayed(Duration(milliseconds: 3000), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _showAnswerFeedback() {
    bool isCorrect = correctAnswers[currentQuestion];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCorrect ? "Corretto! 🎉" : "Sbagliato! 😔",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (isCorrect)
                          Text(
                            "+${questions[currentQuestion].points} punti",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (questions[currentQuestion].explanation != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    questions[currentQuestion].explanation!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
        backgroundColor: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
        duration: Duration(milliseconds: 2800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: EdgeInsets.all(AppTheme.spacingM),
      ),
    );
  }

  void _nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      _questionController.reset();
      setState(() {
        currentQuestion++;
        isAnswered = false;
        selectedAnswer = null;
      });
      _questionController.forward();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    // Calculate results
    int correctCount = correctAnswers.where((answer) => answer).length;
    double percentage = (correctCount / questions.length) * 100;
    
    // Trigger confetti for good scores
    if (percentage >= 70) {
      _confettiController.play();
    }
    
    String getGradeEmoji(double percentage) {
      if (percentage >= 90) return "🏆";
      if (percentage >= 80) return "🎉";
      if (percentage >= 70) return "👏";
      if (percentage >= 60) return "🙂";
      return "📚";
    }
    
    String getGradeMessage(double percentage) {
      if (percentage >= 90) return "Perfetto!";
      if (percentage >= 80) return "Eccellente!";
      if (percentage >= 70) return "Molto bene!";
      if (percentage >= 60) return "Buon lavoro!";
      return "Continua a studiare!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            ),
            contentPadding: EdgeInsets.zero,
            content: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLarge),
                        topRight: Radius.circular(AppTheme.radiusLarge),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            getGradeEmoji(percentage),
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quiz Completato!",
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                getGradeMessage(percentage),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Padding(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      children: [
                        // Score display
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingL),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    "Punteggio",
                                    "$totalScore",
                                    "punti",
                                    AppTheme.primaryColor,
                                  ),
                                  _buildStatItem(
                                    "Precisione",
                                    "${percentage.toInt()}",
                                    "%",
                                    percentage >= 70 ? AppTheme.successColor : AppTheme.errorColor,
                                  ),
                                  _buildStatItem(
                                    "Corrette",
                                    "$correctCount",
                                    "/${questions.length}",
                                    AppTheme.successColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: AppTheme.spacingL),
                        
                        // Questions review
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Riepilogo Risposte",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: AppTheme.spacingM),
                              Row(
                                children: List.generate(questions.length, (index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: AppTheme.spacingS),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: correctAnswers[index] 
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: AppTheme.spacingL),
                        
                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _resetQuiz();
                                },
                                backgroundColor: AppTheme.primaryColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh, color: Colors.white),
                                    SizedBox(width: AppTheme.spacingS),
                                    Text(
                                      "Ricomincia",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti
          if (percentage >= 70)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.5708, // Down
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.05,
                shouldLoop: false,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                  AppTheme.accentColor,
                  AppTheme.successColor,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String suffix, Color color) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _resetQuiz() {
    setState(() {
      currentQuestion = 0;
      totalScore = 0;
      isAnswered = false;
      selectedAnswer = null;
      answeredQuestions = List.filled(questions.length, false);
      correctAnswers = List.filled(questions.length, false);
    });
    
    _questionController.reset();
    _progressController.reset();
    _questionController.forward();
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];

    return Scaffold(
      appBar: PremiumAppBar(
        title: 'Quiz Challenge',
        leading: Container(
          margin: EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(50),
            boxShadow: AppTheme.cardShadow,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(AppTheme.spacingS),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.buttonShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: AppTheme.spacingXS),
                Text(
                  '$totalScore',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: Column(
              children: [
                // Progress section
                SlideInAnimation(
                  delay: Duration(milliseconds: 200),
                  child: _buildProgressSection(),
                ),
                
                // Question content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingL),
                    child: ScaleTransition(
                      scale: _questionAnimation,
                      child: FadeTransition(
                        opacity: _questionAnimation,
                        child: Column(
                          children: [
                            // Question card
                            Expanded(
                              flex: 2,
                              child: _buildQuestionCard(question),
                            ),
                            
                            SizedBox(height: AppTheme.spacingL),
                            
                            // Answer options
                            Expanded(
                              flex: 3,
                              child: _buildAnswerOptions(question),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    double progress = (currentQuestion + 1) / questions.length;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        children: [
          // Question counter and category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: questions[currentQuestion].categoryColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      questions[currentQuestion].categoryIcon,
                      size: 16,
                      color: questions[currentQuestion].categoryColor,
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      questions[currentQuestion].category,
                      style: TextStyle(
                        color: questions[currentQuestion].categoryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: questions[currentQuestion].difficulty.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      questions[currentQuestion].difficulty.icon,
                      size: 16,
                      color: questions[currentQuestion].difficulty.color,
                    ),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      questions[currentQuestion].difficulty.name,
                      style: TextStyle(
                        color: questions[currentQuestion].difficulty.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppTheme.spacingM),
          
          // Progress bar
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: progress * _progressAnimation.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 8,
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.spacingS),
          
          Text(
            "Domanda ${currentQuestion + 1} di ${questions.length}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Stack(
      children: [
        // Background particle system for correct answers
        if (isAnswered && selectedAnswer == question.correctAnswerIndex)
          Positioned.fill(
            child: ParticleSystem(
              isActive: true,
              color: AppTheme.successColor,
              particleCount: 20,
              maxSize: 6,
            ),
          ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppTheme.spacingXL),
          decoration: BoxDecoration(
            gradient: isAnswered
                ? (selectedAnswer == question.correctAnswerIndex
                    ? LinearGradient(
                        colors: [AppTheme.successColor.withOpacity(0.1), Colors.white],
                      )
                    : LinearGradient(
                        colors: [AppTheme.errorColor.withOpacity(0.1), Colors.white],
                      ))
                : null,
            color: isAnswered ? null : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: isAnswered
                    ? (selectedAnswer == question.correctAnswerIndex
                        ? AppTheme.successColor.withOpacity(0.3)
                        : AppTheme.errorColor.withOpacity(0.3))
                    : Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category and difficulty badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: AppTheme.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color: question.categoryColor?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          question.categoryIcon,
                          size: 16,
                          color: question.categoryColor,
                        ),
                        SizedBox(width: AppTheme.spacingS),
                        Text(
                          question.category,
                          style: TextStyle(
                            color: question.categoryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PulsingButton(
                    onPressed: null,
                    glowColor: AppTheme.primaryColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            question.difficulty.icon,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: AppTheme.spacingXS),
                          AnimatedCounter(
                            value: question.points,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            ' pts',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppTheme.spacingXL),
              
              // Question text with shimmer effect
              Shimmer.fromColors(
                baseColor: AppTheme.textPrimary,
                highlightColor: AppTheme.primaryColor.withOpacity(0.3),
                period: Duration(seconds: 3),
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText(
                      question.text,
                      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ) ?? TextStyle(),
                      textAlign: TextAlign.center,
                      duration: Duration(milliseconds: 1500),
                    ),
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOptions(Question question) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: question.options.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedAnswer == index;
          bool isCorrect = index == question.correctAnswerIndex;
          bool showResult = isAnswered;
          
          Color getButtonColor() {
            if (!showResult) {
              return isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor;
            }
            if (isCorrect) return AppTheme.successColor;
            if (isSelected && !isCorrect) return AppTheme.errorColor;
            return AppTheme.surfaceColor.withOpacity(0.6);
          }
          
          Color getTextColor() {
            if (!showResult) {
              return isSelected ? Colors.white : AppTheme.textPrimary;
            }
            if (isCorrect || (isSelected && !isCorrect)) return Colors.white;
            return AppTheme.textLight;
          }
          
          return AnimationConfiguration.staggeredList(
            position: index,
            delay: Duration(milliseconds: 100),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: AnimatedButton(
                    onPressed: isAnswered ? null : () => _selectAnswer(index),
                    backgroundColor: getButtonColor(),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    hapticFeedback: !isAnswered,
                    child: Container(
                      padding: EdgeInsets.all(AppTheme.spacingM),
                      child: Row(
                        children: [
                          // Option letter
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: AppTheme.spacingM),
                          
                          // Option text
                          Expanded(
                            child: Text(
                              question.options[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: getTextColor(),
                              ),
                            ),
                          ),
                          
                          // Result icon
                          if (showResult && (isCorrect || isSelected))
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}