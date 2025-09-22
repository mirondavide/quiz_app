import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../services/ai_topic_generator.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/advanced_effects.dart';
import 'custom_quiz_page.dart';

class TopicInputPage extends StatefulWidget {
  const TopicInputPage({super.key});

  @override
  State<TopicInputPage> createState() => _TopicInputPageState();
}

class _TopicInputPageState extends State<TopicInputPage>
    with TickerProviderStateMixin {
  final TextEditingController _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  List<String> _suggestions = [];
  bool _isGenerating = false;
  int _selectedDifficulty = 1; // 0: Easy, 1: Medium, 2: Hard
  int _questionCount = 5;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSuggestions();
    _topicController.addListener(_onTopicChanged);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  void _loadSuggestions() {
    setState(() {
      _suggestions = AITopicGenerator.getPopularTopics();
    });
  }

  void _onTopicChanged() {
    final suggestions = AITopicGenerator.getTopicSuggestions(_topicController.text);
    setState(() {
      _suggestions = suggestions;
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (_topicController.text.trim().isEmpty) {
      _showErrorMessage('Please enter a topic');
      return;
    }

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    settings.triggerHaptic(HapticFeedbackType.medium);

    setState(() {
      _isGenerating = true;
    });

    try {
      final questions = await AITopicGenerator.generateQuestions(
        _topicController.text.trim(),
        count: _questionCount,
      );

      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                CustomQuizPage(questions: questions, topic: _topicController.text.trim()),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      _showErrorMessage('Failed to generate quiz. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDark = settings.isDarkMode;
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
              'AI Quiz Generator',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with animated text
                    _buildHeader(isDark),
                    const SizedBox(height: 40),
                    
                    // Topic input section
                    _buildTopicInput(isDark),
                    const SizedBox(height: 24),
                    
                    // Suggestions
                    _buildSuggestions(isDark),
                    const SizedBox(height: 32),
                    
                    // Quiz settings
                    _buildQuizSettings(isDark),
                    const SizedBox(height: 40),
                    
                    // Generate button
                    _buildGenerateButton(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'AI-Powered Study Quiz',
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: false,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter any topic and our AI will generate personalized questions using OpenAI GPT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicInput(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to learn about?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _topicController,
            focusNode: _focusNode,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Physics Thermodynamics, Renaissance Art, Python Programming, World War II...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[500],
              ),
              prefixIcon: Icon(
                Icons.psychology,
                color: AppTheme.primaryColor,
              ),
              suffixIcon: _topicController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400],
                      ),
                      onPressed: () {
                        _topicController.clear();
                        _loadSuggestions();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            onSubmitted: (_) => _generateQuiz(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(bool isDark) {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Topics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions.take(9).map((suggestion) {
            return GestureDetector(
              onTap: () {
                _topicController.text = suggestion;
                _focusNode.unfocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  suggestion,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuizSettings(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Question count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Number of Questions',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              Row(
                children: [5, 10, 15].map((count) {
                  return GestureDetector(
                    onTap: () => setState(() => _questionCount = count),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _questionCount == count 
                            ? AppTheme.primaryColor 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: _questionCount == count 
                              ? Colors.white 
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGenerating
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Generating Questions...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Generate Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}