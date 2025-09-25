import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'quiz_page.dart';
import 'theme/app_theme.dart';
import 'screens/language_selection_screen.dart';
import 'pages/about_page.dart';
import 'providers/settings_provider.dart';
import 'services/language_service.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
  
  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.lightImpact();
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
      setState(() {
        _currentIndex = index;
      });
    }
  }
  
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return QuizPage();
      case 2:
        return _buildSettingsPage();
      case 3:
        return AboutPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    final localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.welcome,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        localizations.welcomeSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  // Profile/Language Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageSelectionScreen(isOnboarding: false),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.language_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 40),
              
              // Hero Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.elevatedShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      localizations.appTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      localizations.aiQuizSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.play_arrow_rounded,
                      title: localizations.startQuiz,
                      subtitle: localizations.createQuiz,
                      gradient: AppTheme.successGradient,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.settings_rounded,
                      title: localizations.settings,
                      subtitle: localizations.customize,
                      gradient: AppTheme.primaryGradient,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 100), // Bottom padding for navigation
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsPage() {
    final localizations = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languageService = Provider.of<LanguageService>(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings Header
              Text(
                localizations.settings,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                localizations.customize,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              
              SizedBox(height: 32),
              
              // Theme Settings
              _buildSettingsCard(
                title: localizations.appearance,
                children: [
                  _buildSettingsTile(
                    icon: Icons.palette_rounded,
                    title: localizations.darkMode,
                    subtitle: localizations.toggleDarkMode,
                    trailing: Switch(
                      value: settingsProvider.themeMode == ThemeMode.dark,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        settingsProvider.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.vibration_rounded,
                    title: localizations.hapticFeedback,
                    subtitle: localizations.enableVibration,
                    trailing: Switch(
                      value: true, // settingsProvider.hapticFeedbackEnabled,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        // settingsProvider.setHapticFeedback(value);
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Language Settings
              _buildSettingsCard(
                title: localizations.languageSettings,
                children: [
                  _buildSettingsTile(
                    icon: Icons.language_rounded,
                    title: localizations.chooseLanguage,
                    subtitle: languageService.getCurrentLanguageOption()?.nativeName ?? 'English',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionScreen(isOnboarding: false),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              // About Settings
              _buildSettingsCard(
                title: localizations.about,
                children: [
                  _buildSettingsTile(
                    icon: Icons.info_rounded,
                    title: localizations.aboutApp,
                    subtitle: localizations.appInfo,
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
              
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _getCurrentPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary.withOpacity(0.6),
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_rounded, 0),
                activeIcon: _buildNavIcon(Icons.home_rounded, 0, isActive: true),
                label: localizations.home,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.quiz_rounded, 1),
                activeIcon: _buildNavIcon(Icons.quiz_rounded, 1, isActive: true),
                label: localizations.quiz,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.settings_rounded, 2),
                activeIcon: _buildNavIcon(Icons.settings_rounded, 2, isActive: true),
                label: localizations.settings,
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.info_rounded, 3),
                activeIcon: _buildNavIcon(Icons.info_rounded, 3, isActive: true),
                label: localizations.about,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        final scale = (_currentIndex == index && isActive) ? _bounceAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: isActive ? BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ) : null,
            child: Icon(
              icon,
              color: isActive ? Colors.white : null,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}