import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/language_service.dart';
import '../widgets/animated_widgets.dart';
import 'file_upload_screen.dart';
import 'text_input_screen.dart';

class InputSelectionScreen extends StatefulWidget {
  const InputSelectionScreen({super.key});

  @override
  State<InputSelectionScreen> createState() => _InputSelectionScreenState();
}

class _InputSelectionScreenState extends State<InputSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
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

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onOptionTap(VoidCallback onTap) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
              _buildHeader(localizations, theme, isDarkMode),
              
              // Content
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildContent(localizations, mediaQuery, isDarkMode),
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

  Widget _buildHeader(AppLocalizations localizations, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
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
              const Spacer(),
              // Language selector
              _buildLanguageSelector(isDarkMode),
            ],
          ),
          const SizedBox(height: 32),
          
          // Hero section
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.elevatedShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  localizations.chooseInputMethod,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.selectHowToProvideContent,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDarkMode) {
    final languageService = Provider.of<LanguageService>(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.cardShadow,
      ),
      child: IconButton(
        onPressed: () {
          // Show language selection dialog
          _showLanguageDialog(languageService, isDarkMode);
        },
        icon: const Icon(
          Icons.language_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations localizations, MediaQueryData mediaQuery, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Upload File Option
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildInputOption(
                  icon: Icons.upload_file_rounded,
                  title: localizations.uploadFile,
                  subtitle: localizations.uploadFileDescription,
                  gradient: AppTheme.primaryGradient,
                  onTap: () => _onOptionTap(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FileUploadScreen(),
                      ),
                    );
                  }),
                  isDarkMode: isDarkMode,
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Type Topic Option
          _buildInputOption(
            icon: Icons.edit_rounded,
            title: localizations.typeTopic,
            subtitle: localizations.typeTopicDescription,
            gradient: AppTheme.successGradient,
            onTap: () => _onOptionTap(() {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TextInputScreen(),
                ),
              );
            }),
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 40),
          
          // Info section
          _buildInfoSection(localizations, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildInputOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.elevatedShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations localizations, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.darkSurfaceSecondary.withOpacity(0.5)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.darkSurfaceTertiary
              : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.supportedFormats,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            localizations.supportedFormatsDescription,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(LanguageService languageService, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isDarkMode ? AppTheme.darkCardShadow : AppTheme.elevatedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseLanguage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ...LanguageService.supportedLocales.map((locale) {
                final lang = LanguageService.languages[locale.languageCode];
                if (lang == null) return const SizedBox.shrink();
                final isSelected = languageService.currentLocale.languageCode == lang.code;
                return ListTile(
                  title: Text(
                    lang.nativeName,
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    lang.name,
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                    ),
                  ),
                  leading: Radio<String>(
                    value: lang.code,
                    groupValue: languageService.currentLocale.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        languageService.changeLanguage(value);
                        Navigator.of(context).pop();
                      }
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    languageService.changeLanguage(lang.code);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}