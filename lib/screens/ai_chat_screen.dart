import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/ai_service.dart';
import '../services/file_service.dart';

class AIChatScreen extends StatefulWidget {
  final String? inputText;
  final AppFile? inputFile;
  final String language;
  final String theme;

  const AIChatScreen({
    super.key,
    this.inputText,
    this.inputFile,
    required this.language,
    required this.theme,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _typingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _typingAnimation;

  final FileService _fileService = FileService();
  final TextEditingController _followUpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  String? _errorMessage;
  AIResponse? _currentResponse;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeChat();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _typingController.repeat(reverse: true);
    _animationController.forward();
  }

  Future<void> _initializeChat() async {
    try {
      // Add user message first
      if (widget.inputText != null) {
        _addMessage(ChatMessage(
          content: widget.inputText!,
          isUser: true,
          timestamp: DateTime.now(),
        ));
      } else if (widget.inputFile != null) {
        _addMessage(ChatMessage(
          content: 'Uploaded: ${widget.inputFile!.name}',
          isUser: true,
          timestamp: DateTime.now(),
          file: widget.inputFile,
        ));
      }

      // Show typing indicator
      setState(() {
        _isTyping = true;
      });

      // Simulate processing delay for better UX
      await Future.delayed(const Duration(seconds: 2));

      // Get AI service instance
      final aiService = AIService();
      
      // Generate AI response
      AIResponse response;
      if (widget.inputText != null) {
        response = await aiService.generateTextResponse(
          topic: widget.inputText!,
          language: widget.language,
          theme: widget.theme,
        );
      } else if (widget.inputFile != null) {
        final fileContent = await _fileService.extractTextContent(widget.inputFile!);
        response = await aiService.generateFileResponse(
          fileContent: fileContent,
          fileName: widget.inputFile!.name,
          language: widget.language,
          theme: widget.theme,
        );
      } else {
        throw Exception('No input provided');
      }

      setState(() {
        _currentResponse = response;
        _isTyping = false;
        _isLoading = false;
      });

      _addMessage(ChatMessage(
        content: response.content,
        isUser: false,
        timestamp: response.timestamp,
        aiResponse: response,
      ));

    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isTyping = false;
        _isLoading = false;
      });
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendFollowUp() async {
    final text = _followUpController.text.trim();
    if (text.isEmpty) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    _addMessage(ChatMessage(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _followUpController.clear();
    setState(() {
      _isTyping = true;
    });

    try {
      // Get AI service instance
      final aiService = AIService();
      
      final response = await aiService.generateTextResponse(
        topic: text,
        language: widget.language,
        theme: widget.theme,
      );

      setState(() {
        _isTyping = false;
      });

      _addMessage(ChatMessage(
        content: response.content,
        isUser: false,
        timestamp: response.timestamp,
        aiResponse: response,
      ));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typingController.dispose();
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(localizations),
              
              // Chat content
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildChatContent(localizations),
                    );
                  },
                ),
              ),
              
              // Input area
              _buildInputArea(localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkSurfaceSecondary.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkSurfaceTertiary
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkTextPrimary
                  : AppTheme.textPrimary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkSurfaceSecondary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.aiAssistant,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _isTyping 
                      ? localizations.typing 
                      : localizations.readyToHelp,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isTyping 
                        ? AppTheme.primaryColor 
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isTyping 
                  ? AppTheme.warningColor 
                  : AppTheme.successColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isTyping 
                      ? AppTheme.warningColor 
                      : AppTheme.successColor).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent(AppLocalizations localizations) {
    if (_isLoading && _messages.isEmpty) {
      return _buildLoadingState(localizations);
    }

    if (_errorMessage != null && _messages.isEmpty) {
      return _buildErrorState(localizations);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index], context);
      },
    );
  }

  Widget _buildLoadingState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.preparingResponse,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkTextPrimary
                  : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.processingInput,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations localizations) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.errorColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.errorOccurred,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkTextPrimary
                    : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? localizations.unknownError,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: message.isUser 
                    ? AppTheme.primaryGradient 
                    : (isDarkMode
                        ? AppTheme.darkCardGradient
                        : LinearGradient(
                            colors: [Colors.white, Colors.white.withOpacity(0.9)],
                          )),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.file != null) 
                    _buildFileAttachment(message.file!, isDarkMode),
                  
                  if (message.aiResponse?.type == AIResponseType.questionAnswer)
                    _buildQAContent(message.aiResponse!, isDarkMode)
                  else
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: message.isUser 
                            ? Colors.white 
                            : (isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                        height: 1.4,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.7) 
                          : (isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileAttachment(AppFile file, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurfaceSecondary : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(file.type),
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${file.extension.toUpperCase()} • ${file.sizeDisplay}',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildQAContent(AIResponse response, bool isDarkMode) {
    final qaList = response.questionAnswers;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: qaList.map((qa) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppTheme.primaryColor.withOpacity(0.2) 
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  qa.question,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                qa.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.darkSurfaceColor
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkCardShadow 
                  : AppTheme.cardShadow,
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingDot(0),
                    const SizedBox(width: 4),
                    _buildTypingDot(1),
                    const SizedBox(width: 4),
                    _buildTypingDot(2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final delay = index * 0.2;
    final animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Interval(delay, 1.0, curve: Curves.easeInOut),
    ));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(AppLocalizations localizations) {
    if (_isLoading || _errorMessage != null) {
      return const SizedBox.shrink();
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppTheme.darkSurfaceSecondary.withOpacity(0.5) 
            : Colors.white.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: isDarkMode 
                ? AppTheme.darkSurfaceTertiary 
                : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _followUpController,
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: localizations.askFollowUp,
                hintStyle: TextStyle(
                  color: isDarkMode 
                      ? AppTheme.darkTextSecondary.withOpacity(0.7) 
                      : AppTheme.textSecondary.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode 
                    ? AppTheme.darkSurfaceColor 
                    : Colors.white.withOpacity(0.9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendFollowUp(),
            ),
          ),
          const SizedBox(width: 12),
          
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: IconButton(
              onPressed: _sendFollowUp,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(AppFileType type) {
    switch (type) {
      case AppFileType.pdf:
        return Icons.picture_as_pdf_rounded;
      case AppFileType.document:
        return Icons.description_rounded;
      case AppFileType.text:
        return Icons.text_snippet_rounded;
      case AppFileType.image:
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

// Chat Message model
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AppFile? file;
  final AIResponse? aiResponse;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.file,
    this.aiResponse,
  });
}
