import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'question.dart';
import 'services/ai_topic_generator.dart' as AI;
import 'services/language_service.dart';
import 'theme/app_theme.dart';
import 'widgets/animated_widgets.dart';
import 'widgets/premium_widgets.dart';

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
  bool isLoadingQuestions = false;
  bool hasQuestions = false;
  String? errorMessage;
  
  late AnimationController _heroController;
  late AnimationController _questionController;
  late AnimationController _progressController;
  late ConfettiController _confettiController;
  late Animation<double> _heroAnimation;
  late Animation<double> _questionAnimation;
  late Animation<double> _progressAnimation;
  
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize premium animations
    _heroController = AnimationController(
      duration: AppTheme.animationExtraSlow,
      vsync: this,
    );
    _questionController = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );
    _progressController = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );
    _confettiController = ConfettiController(
      duration: Duration(seconds: 3),
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: AppTheme.bounceCurve,
    );
    _questionAnimation = CurvedAnimation(
      parent: _questionController,
      curve: AppTheme.smoothCurve,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: AppTheme.defaultCurve,
    );
    
    // Start initial animations
    _heroController.forward();
    _questionController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
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
    
    // Show premium result feedback
    _showPremiumAnswerFeedback();
    
    // Auto-advance with animation
    Future.delayed(Duration(milliseconds: 3500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }
  
  Future<void> _generateQuestionsForTopic(String topic, {int count = 5}) async {
    setState(() {
      isLoadingQuestions = true;
      errorMessage = null;
      hasQuestions = false;
    });
    
    try {
      // Get current language from LanguageService
      final languageService = Provider.of<LanguageService>(context, listen: false);
      final currentLanguage = languageService.currentLocale.languageCode;
      
      final generatedQuestions = await AI.AITopicGenerator.generateQuestions(
        topic, 
        count: count, 
        language: currentLanguage,
      );
      
      // Convert AI.Question to quiz_page.Question format
      final convertedQuestions = generatedQuestions.map((aiQuestion) {
        return Question(
          text: aiQuestion.text,
          options: aiQuestion.options,
          correctAnswerIndex: aiQuestion.correctIndex,
          explanation: aiQuestion.explanation,
          categoryIcon: _getCategoryIcon(aiQuestion.topic),
          categoryColor: _getCategoryColor(aiQuestion.topic),
          category: aiQuestion.topic,
          difficulty: _convertDifficulty(aiQuestion.difficulty),
        );
      }).toList();
      
      setState(() {
        questions = convertedQuestions;
        answeredQuestions = List.filled(questions.length, false);
        correctAnswers = List.filled(questions.length, false);
        isLoadingQuestions = false;
        hasQuestions = true;
        currentQuestion = 0;
        totalScore = 0;
        isAnswered = false;
        selectedAnswer = null;
      });
      
      // Reset and start animations
      _questionController.reset();
      _progressController.reset();
      _questionController.forward();
      _progressController.forward();
      
    } catch (e) {
      setState(() {
        isLoadingQuestions = false;
        errorMessage = 'Failed to generate questions. Please try again.';
      });
    }
  }
  
  IconData _getCategoryIcon(String topic) {
    final topicLower = topic.toLowerCase();
    if (topicLower.contains('math') || topicLower.contains('calcul') || topicLower.contains('algebra')) {
      return Icons.calculate;
    } else if (topicLower.contains('physics') || topicLower.contains('science')) {
      return Icons.science;
    } else if (topicLower.contains('history')) {
      return Icons.history_edu;
    } else if (topicLower.contains('geography')) {
      return Icons.public;
    } else if (topicLower.contains('literature') || topicLower.contains('art')) {
      return Icons.brush;
    } else if (topicLower.contains('biology') || topicLower.contains('nature')) {
      return Icons.eco;
    } else if (topicLower.contains('chemistry')) {
      return Icons.biotech;
    } else if (topicLower.contains('computer') || topicLower.contains('programming')) {
      return Icons.computer;
    } else if (topicLower.contains('psychology')) {
      return Icons.psychology;
    }
    return Icons.school;
  }
  
  Color _getCategoryColor(String topic) {
    final topicLower = topic.toLowerCase();
    if (topicLower.contains('math') || topicLower.contains('calcul') || topicLower.contains('algebra')) {
      return Colors.blue;
    } else if (topicLower.contains('physics') || topicLower.contains('science')) {
      return Colors.indigo;
    } else if (topicLower.contains('history')) {
      return Colors.brown;
    } else if (topicLower.contains('geography')) {
      return Colors.green;
    } else if (topicLower.contains('literature') || topicLower.contains('art')) {
      return Colors.purple;
    } else if (topicLower.contains('biology') || topicLower.contains('nature')) {
      return Colors.lightGreen;
    } else if (topicLower.contains('chemistry')) {
      return Colors.orange;
    } else if (topicLower.contains('computer') || topicLower.contains('programming')) {
      return Colors.teal;
    } else if (topicLower.contains('psychology')) {
      return Colors.pink;
    }
    return AppTheme.primaryColor;
  }
  
  QuestionDifficulty _convertDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return QuestionDifficulty.easy;
      case 'hard':
        return QuestionDifficulty.hard;
      default:
        return QuestionDifficulty.medium;
    }
  }

  void _showPremiumAnswerFeedback() {
    bool isCorrect = correctAnswers[currentQuestion];
    final localizations = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(AppTheme.spacingL),
        padding: EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          gradient: isCorrect ? AppTheme.successGradient : AppTheme.errorGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.elevatedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result Icon
            Container(
              padding: EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
            
            SizedBox(height: AppTheme.spacingL),
            
            // Result Text
            Text(
              isCorrect ? localizations.excellent : localizations.notQuiteRight,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: AppTheme.spacingM),
            
            if (isCorrect)
              Text(
                localizations.pointsEarned(questions[currentQuestion].points),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            
            if (questions[currentQuestion].explanation != null) ...[
              SizedBox(height: AppTheme.spacingL),
              Container(
                padding: EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Text(
                  questions[currentQuestion].explanation!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
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
    final localizations = AppLocalizations.of(context)!;
    
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
      if (percentage >= 90) return localizations.outstandingPerformance;
      if (percentage >= 80) return localizations.excellentWork;
      if (percentage >= 70) return localizations.greatJob;
      if (percentage >= 60) return localizations.goodEffort;
      return localizations.keepLearning;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Header
              Container(
                padding: EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXLarge),
                    topRight: Radius.circular(AppTheme.radiusXLarge),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      getGradeEmoji(percentage),
                      style: TextStyle(fontSize: 48),
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    Text(
                      localizations.quizComplete,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacingS),
                    Text(
                      getGradeMessage(percentage),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(AppTheme.spacingXL),
                child: Column(
                  children: [
                    // Score Display
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.stars_rounded, color: AppTheme.primaryColor),
                                SizedBox(height: AppTheme.spacingS),
                                Text(
                                  "$totalScore",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  localizations.points,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: (percentage >= 70 ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: (percentage >= 70 ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.analytics_rounded, color: percentage >= 70 ? AppTheme.successColor : AppTheme.errorColor),
                                SizedBox(height: AppTheme.spacingS),
                                Text(
                                  "${percentage.toInt()}%",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: percentage >= 70 ? AppTheme.successColor : AppTheme.errorColor,
                                  ),
                                ),
                                Text(
                                  localizations.accuracy,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppTheme.spacingL),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _resetQuiz();
                            },
                            gradient: AppTheme.primaryGradient,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, color: Colors.white),
                                SizedBox(width: AppTheme.spacingS),
                                Text(
                                  localizations.retry,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: GradientButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _startNewTopic();
                            },
                            gradient: LinearGradient(
                              colors: [AppTheme.accentColor, AppTheme.accentLight],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.psychology_rounded, color: Colors.white),
                                SizedBox(width: AppTheme.spacingS),
                                Text(
                                  localizations.newTopic,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
  
  void _startNewTopic() {
    setState(() {
      hasQuestions = false;
      questions.clear();
      currentQuestion = 0;
      totalScore = 0;
      isAnswered = false;
      selectedAnswer = null;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    if (!hasQuestions && !isLoadingQuestions) {
      return _buildPremiumTopicInputScreen();
    } else if (isLoadingQuestions) {
      return _buildPremiumLoadingScreen();
    } else if (errorMessage != null) {
      return _buildPremiumErrorScreen();
    } else {
      return _buildPremiumQuizScreen();
    }
  }
  
  Widget _buildPremiumTopicInputScreen() {
    final TextEditingController topicController = TextEditingController();
    final localizations = AppLocalizations.of(context)!;
    
    return AnimationLimiter(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          children: [
            SizedBox(height: 60),
            
            // Premium Hero Section
            AnimationConfiguration.staggeredList(
              position: 0,
              delay: Duration(milliseconds: 100),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Column(
                    children: [
                      // Hero Icon with Glow
                      Container(
                        padding: EdgeInsets.all(AppTheme.spacingXL),
                        decoration: BoxDecoration(
                          gradient: AppTheme.heroGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.glowShadow,
                        ),
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      
                      SizedBox(height: AppTheme.spacingXL),
                      
                      // Premium Title with Animation
                      PremiumShimmer(
                        child: Text(
                          localizations.aiQuizGenerator,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: AppTheme.spacingM),
                      
                      Text(
                        localizations.aiQuizSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingXXL),
            
            // Premium Topic Input
            AnimationConfiguration.staggeredList(
              position: 1,
              delay: Duration(milliseconds: 200),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: GlassmorphismCard(
                    child: TextField(
                      controller: topicController,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: localizations.topicInputHint,
                        hintStyle: TextStyle(
                          color: AppTheme.textLight,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(AppTheme.spacingS),
                          padding: EdgeInsets.all(AppTheme.spacingS),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(AppTheme.spacingL),
                      ),
                      onSubmitted: (topic) {
                        if (topic.trim().isNotEmpty) {
                          _generateQuestionsForTopic(topic.trim());
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingXL),
            
            // Premium Generate Button
            AnimationConfiguration.staggeredList(
              position: 2,
              delay: Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: PremiumAnimatedButton(
                      onPressed: () {
                        if (topicController.text.trim().isNotEmpty) {
                          _generateQuestionsForTopic(topicController.text.trim());
                        }
                      },
                      gradient: AppTheme.primaryGradient,
                      glowEffect: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 24, color: Colors.white),
                          SizedBox(width: AppTheme.spacingM),
                          Text(
                            localizations.generateQuizQuestions,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppTheme.spacingXXL),
            
            // Popular Topics
            AnimationConfiguration.staggeredList(
              position: 3,
              delay: Duration(milliseconds: 400),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.popularTopics,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingL),
                      Wrap(
                        spacing: AppTheme.spacingM,
                        runSpacing: AppTheme.spacingM,
                        children: [
                          'Mathematics',
                          'Physics',
                          'History',
                          'Biology',
                          'Computer Science',
                          'Literature',
                          'Chemistry',
                          'Psychology',
                        ].map((topic) {
                          return PremiumAnimatedButton(
                            onPressed: () {
                              topicController.text = topic;
                              _generateQuestionsForTopic(topic);
                            },
                            backgroundColor: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingL,
                              vertical: AppTheme.spacingM,
                            ),
                            child: Text(
                              topic,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumLoadingScreen() {
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Loading Animation
          PulsingWidget(
            child: Container(
              padding: EdgeInsets.all(AppTheme.spacingXXL),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: PremiumLoadingSpinner(
                size: 60,
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ),
          
          SizedBox(height: AppTheme.spacingXXL),
          
          // Animated Text
          AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                localizations.generatingQuestions,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                speed: Duration(milliseconds: 100),
              ),
            ],
            isRepeatingAnimation: true,
            repeatForever: true,
          ),
          
          SizedBox(height: AppTheme.spacingL),
          
          Text(
            localizations.aiCraftingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumErrorScreen() {
    final localizations = AppLocalizations.of(context)!;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: GlassmorphismCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                padding: EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: AppTheme.errorColor,
                ),
              ),
              
              SizedBox(height: AppTheme.spacingXL),
              
              Text(
                localizations.somethingWentWrong,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              SizedBox(height: AppTheme.spacingM),
              
              Text(
                errorMessage ?? localizations.failedGenerateQuestions,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              
              SizedBox(height: AppTheme.spacingXXL),
              
              GradientButton(
                onPressed: () {
                  setState(() {
                    errorMessage = null;
                    hasQuestions = false;
                  });
                },
                gradient: AppTheme.primaryGradient,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white),
                    SizedBox(width: AppTheme.spacingS),
                    Text(
                      localizations.tryAgain,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPremiumQuizScreen() {
    if (questions.isEmpty) return Container();
    
    final question = questions[currentQuestion];
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Premium Progress Header
        Container(
          padding: EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              // Progress Bar
              PremiumProgressIndicator(
                value: (currentQuestion + 1) / questions.length,
                showPercentage: true,
                height: 8,
              ),
              
              SizedBox(height: AppTheme.spacingM),
              
              // Question Counter & Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PremiumBadge(
                    text: "${currentQuestion + 1} ${localizations.outOf} ${questions.length}",
                    backgroundColor: AppTheme.primaryColor,
                    icon: Icon(Icons.quiz_rounded, size: 16, color: Colors.white),
                  ),
                  PremiumBadge(
                    text: question.category,
                    backgroundColor: question.categoryColor,
                    icon: Icon(question.categoryIcon, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Question Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: AnimatedBuilder(
              animation: _questionAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _questionAnimation.value,
                  child: Opacity(
                    opacity: _questionAnimation.value,
                    child: Column(
                      children: [
                        // Premium Question Card
                        Expanded(
                          flex: 2,
                          child: GlassmorphismCard(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Difficulty Badge
                                  PremiumBadge(
                                    text: question.difficulty.name.toUpperCase(),
                                    backgroundColor: question.difficulty.color,
                                    glow: true,
                                  ),
                                  
                                  SizedBox(height: AppTheme.spacingL),
                                  
                                  // Question Text with Premium Animation
                                  PremiumShimmer(
                                    enabled: !isAnswered,
                                    child: Text(
                                      question.text,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: AppTheme.spacingL),
                        
                        // Premium Answer Options
                        Expanded(
                          flex: 3,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: question.options.length,
                              itemBuilder: (context, index) {
                                bool isSelected = selectedAnswer == index;
                                bool isCorrect = index == question.correctAnswerIndex;
                                bool showResult = isAnswered;
                                
                                Color getBackgroundColor() {
                                  if (!showResult) {
                                    return isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor;
                                  }
                                  if (isCorrect) return AppTheme.successColor;
                                  if (isSelected && !isCorrect) return AppTheme.errorColor;
                                  return AppTheme.surfaceSecondary;
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
                                    verticalOffset: 30.0,
                                    child: FadeInAnimation(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: AppTheme.spacingM),
                                        child: PremiumAnimatedButton(
                                          onPressed: isAnswered ? null : () => _selectAnswer(index),
                                          backgroundColor: getBackgroundColor(),
                                          padding: EdgeInsets.all(AppTheme.spacingL),
                                          boxShadow: showResult && (isCorrect || isSelected) 
                                              ? AppTheme.elevatedShadow 
                                              : AppTheme.cardShadow,
                                          child: Row(
                                            children: [
                                              // Option Letter
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    String.fromCharCode(65 + index),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              
                                              SizedBox(width: AppTheme.spacingM),
                                              
                                              // Option Text
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
                                              
                                              // Result Icon
                                              if (showResult && (isCorrect || isSelected))
                                                Container(
                                                  padding: EdgeInsets.all(AppTheme.spacingS),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}