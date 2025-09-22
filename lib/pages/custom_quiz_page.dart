import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../services/ai_topic_generator.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/advanced_effects.dart';

class CustomQuizPage extends StatefulWidget {
  final List<Question> questions;
  final String topic;

  const CustomQuizPage({
    super.key,
    required this.questions,
    required this.topic,
  });

  @override
  State<CustomQuizPage> createState() => _CustomQuizPageState();
}

class _CustomQuizPageState extends State<CustomQuizPage>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _isAnswered = false;
  int _score = 0;
  bool _quizCompleted = false;
  
  late AnimationController _questionController;
  late AnimationController _optionController;
  late AnimationController _progressController;
  late ConfettiController _confettiController;
  
  late Animation<double> _questionAnimation;
  late Animation<double> _optionAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startQuestionAnimation();
  }

  void _initializeAnimations() {
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _optionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _questionAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _questionController, curve: Curves.easeOut));
    
    _optionAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _optionController, curve: Curves.easeOut));
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOut));
  }

  void _startQuestionAnimation() {
    _questionController.reset();
    _optionController.reset();
    
    _questionController.forward().then((_) {
      _optionController.forward();
    });
    
    _updateProgress();
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionController.dispose();
    _progressController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;
    
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.triggerHaptic(HapticFeedbackType.light);
    
    setState(() {
      _selectedAnswer = index;
      _isAnswered = true;
    });

    // Check if answer is correct
    final question = widget.questions[_currentQuestionIndex];
    if (question.isCorrect(index)) {
      _score++;
      settings.triggerHaptic(HapticFeedbackType.medium);
    }

    // Auto-advance after delay
    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
      _startQuestionAnimation();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    
    // Trigger confetti for good performance
    final percentage = (_score / widget.questions.length) * 100;
    if (percentage >= 70) {
      _confettiController.play();
    }
    
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.triggerHaptic(HapticFeedbackType.heavy);
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _score = 0;
      _quizCompleted = false;
    });
    _progressController.reset();
    _startQuestionAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
        
        if (_quizCompleted) {
          return _buildResultsPage(isDark);
        }
        
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.topic,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background particles
              Positioned.fill(
                child: ParticleSystem(
                  isActive: true,
                  color: AppTheme.primaryColor,
                  particleCount: 10,
                  maxSize: 3,
                ),
              ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Progress section
                    _buildProgressSection(isDark),
                    const SizedBox(height: 32),
                    
                    // Question section
                    Expanded(
                      child: _buildQuestionSection(isDark),
                    ),
                  ],
                ),
              ),
              
              // Confetti overlay
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            Text(
              '${_currentQuestionIndex + 1} / ${widget.questions.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(bool isDark) {
    final question = widget.questions[_currentQuestionIndex];
    
    return Column(
      children: [
        // Question card
        FadeTransition(
          opacity: _questionAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(_questionAnimation),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question.difficulty,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    question.text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Options
        Expanded(
          child: FadeTransition(
            opacity: _optionAnimation,
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                return SlideInAnimation(
                  delay: Duration(milliseconds: 100 * index),
                  child: _buildOptionCard(question, index, isDark),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(Question question, int index, bool isDark) {
    final isSelected = _selectedAnswer == index;
    final isCorrect = question.correctIndex == index;
    final showResult = _isAnswered;
    
    Color cardColor;
    Color textColor;
    Color borderColor;
    
    if (showResult) {
      if (isSelected && isCorrect) {
        cardColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
      } else if (isSelected && !isCorrect) {
        cardColor = AppTheme.errorColor.withOpacity(0.1);
        borderColor = AppTheme.errorColor;
        textColor = AppTheme.errorColor;
      } else if (isCorrect) {
        cardColor = AppTheme.successColor.withOpacity(0.1);
        borderColor = AppTheme.successColor;
        textColor = AppTheme.successColor;
      } else {
        cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
        borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
        textColor = isDark ? Colors.white70 : Colors.grey[600]!;
      }
    } else {
      cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
      borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
      textColor = isDark ? Colors.white : Colors.black87;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectAnswer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question.options[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.3,
                  ),
                ),
              ),
              if (showResult && isCorrect)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              if (showResult && isSelected && !isCorrect)
                Icon(
                  Icons.cancel,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsPage(bool isDark) {
    final percentage = (_score / widget.questions.length) * 100;
    final isGoodScore = percentage >= 70;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E27) : Colors.grey[50],
      body: Stack(
        children: [
          // Confetti
          if (isGoodScore)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple
                ],
              ),
            ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),
                  
                  // Results header
                  SlideInAnimation(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isGoodScore 
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isGoodScore ? Icons.celebration : Icons.emoji_events,
                            size: 60,
                            color: isGoodScore ? AppTheme.successColor : AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              isGoodScore ? 'Excellent Work!' : 'Good Effort!',
                              textStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Score display
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your Score',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$_score',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: isGoodScore ? AppTheme.successColor : AppTheme.primaryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / ${widget.questions.length}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: isDark ? Colors.white70 : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${percentage.toInt()}%',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Topic: ${widget.topic}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white70 : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Performance feedback
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isGoodScore 
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isGoodScore 
                                    ? AppTheme.successColor.withOpacity(0.3)
                                    : AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getPerformanceFeedback(percentage),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _restartQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Try Again',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Back to Topics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceFeedback(double percentage) {
    if (percentage >= 90) {
      return '🌟 Outstanding! You have excellent knowledge of ${widget.topic}!';
    } else if (percentage >= 80) {
      return '🎉 Great job! You have a strong understanding of ${widget.topic}.';
    } else if (percentage >= 70) {
      return '👍 Good work! You have a solid grasp of ${widget.topic}.';
    } else if (percentage >= 60) {
      return '📚 Not bad! Consider reviewing ${widget.topic} to improve further.';
    } else if (percentage >= 40) {
      return '💪 Keep studying! ${widget.topic} requires more practice.';
    } else {
      return '📖 Don\'t give up! ${widget.topic} needs focused study time.';
    }
  }
}