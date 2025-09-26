import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/language_service.dart';
import 'ai_chat_screen.dart';

class TextInputScreen extends StatefulWidget {
  const TextInputScreen({super.key});

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _buttonScaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;
  String? _errorMessage;

  // Predefined topic suggestions
  final List<String> _topicSuggestions = [
    'Artificial Intelligence',
    'Climate Change',
    'Space Exploration',
    'Renewable Energy',
    'Quantum Computing',
    'Biotechnology',
    'Digital Privacy',
    'Sustainable Development',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _textController.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
    // Auto-focus the text field after animation
    Future.delayed(const Duration(milliseconds: 600), () {
      _focusNode.requestFocus();
    });
  }

  void _onTextChanged() {
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _buttonScaleController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _sendToAI() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.pleaseEnterTopic;
      });
      return;
    }

    _triggerHaptic();
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    _buttonScaleController.forward().then((_) {
      _buttonScaleController.reverse();
    });

    try {
      final languageService = Provider.of<LanguageService>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      
      // Navigate to chat screen with text
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AIChatScreen(
            inputText: text,
            language: languageService.getCurrentLanguageOption()?.name ?? 'English',
            theme: settings.isDarkMode ? 'dark' : 'light',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.processingError;
        _isProcessing = false;
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    _triggerHaptic();
    _textController.text = suggestion;
    _focusNode.requestFocus();
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  void _clearText() {
    _triggerHaptic();
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final hasText = _textController.text.trim().isNotEmpty;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBackgroundGradient
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(localizations, isDarkMode),
              
              // Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildContent(localizations, hasText, isDarkMode),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDarkMode
                  ? AppTheme.darkSurfaceSecondary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.typeTopic,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  localizations.enterTopicDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations localizations, bool hasText, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text input section
          _buildTextInputSection(localizations, hasText, isDarkMode),
          
          const SizedBox(height: 24),
          
          // Suggestions section
          if (!hasText) ...[
            _buildSuggestionsSection(localizations, isDarkMode),
            const SizedBox(height: 24),
          ],
          
          // Error message
          if (_errorMessage != null) ...[
            _buildErrorMessage(_errorMessage!, isDarkMode),
            const SizedBox(height: 16),
          ],
          
          const Spacer(),
          
          // Send button
          _buildSendButton(localizations, hasText),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextInputSection(AppLocalizations localizations, bool hasText, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.darkSurfaceSecondary.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.darkSurfaceTertiary
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.yourTopic,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (hasText)
                  IconButton(
                    onPressed: _clearText,
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: localizations.enterTopicHint,
                hintStyle: TextStyle(
                  color: isDarkMode 
                      ? AppTheme.darkTextSecondary.withOpacity(0.7) 
                      : AppTheme.textSecondary.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : Colors.white.withOpacity(0.1),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                height: 1.4,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _sendToAI(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(AppLocalizations localizations, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.suggestedTopics,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _topicSuggestions.map((suggestion) {
            return _buildSuggestionChip(suggestion, isDarkMode);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String suggestion, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.cardShadow,
        ),
        child: Text(
          suggestion,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(AppLocalizations localizations, bool hasText) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isProcessing || !hasText) ? null : _sendToAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasText ? AppTheme.primaryColor : AppTheme.textMuted,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: hasText ? 8 : 0,
                shadowColor: hasText ? AppTheme.primaryColor.withOpacity(0.4) : null,
              ),
              child: _isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(localizations.processing),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded),
                        const SizedBox(width: 8),
                        Text(localizations.askAI),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(String message, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.errorColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}