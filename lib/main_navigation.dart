import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'quiz_page.dart';
import 'theme/app_theme.dart';
import 'widgets/premium_navigation.dart';
import 'widgets/animated_widgets.dart';
import 'widgets/advanced_effects.dart';
import 'providers/settings_provider.dart';
import 'pages/about_page.dart';
import 'pages/topic_input_page.dart';
import 'pages/api_config_page.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOut,
    ));
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDarkMode = settings.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: EnhancedAppTheme.getBackgroundGradient(isDarkMode),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            _buildHomePage(),
            QuizPage(),
            _buildStatsPage(),
            _buildSettingsPage(),
          ],
        ),
      ),
      bottomNavigationBar: PremiumNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        items: [
          PremiumNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
          ),
          PremiumNavItem(
            icon: Icons.quiz_rounded,
            label: 'Quiz',
          ),
          PremiumNavItem(
            icon: Icons.analytics_rounded,
            label: 'Stats',
          ),
          PremiumNavItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1 ? null : ScaleTransition(
        scale: _fabAnimation,
        child: FloatingNavButton(
          icon: Icons.auto_awesome,
          onPressed: () {
            final settings = Provider.of<SettingsProvider>(context, listen: false);
            settings.triggerHaptic(HapticFeedbackType.medium);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => TopicInputPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut)),
                    ),
                    child: child,
                  );
                },
              ),
            );
          },
          tooltip: 'AI Quiz Generator',
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHomePage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            SlideInAnimation(
              delay: Duration(milliseconds: 200),
              child: Stack(
                children: [
                  // Background particle system
                  Positioned.fill(
                    child: ParticleSystem(
                      isActive: true,
                      color: AppTheme.primaryColor,
                      particleCount: 15,
                      maxSize: 4,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingXL),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppTheme.spacingM),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.psychology_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        'Quiz Premium',
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        speed: Duration(milliseconds: 100),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.spacingL),
                        Shimmer.fromColors(
                          baseColor: Colors.white.withOpacity(0.7),
                          highlightColor: Colors.white,
                          child: Text(
                            'Test your knowledge with our beautifully designed quiz experience featuring smooth animations and instant feedback.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Quick stats
            SlideInAnimation(
              delay: Duration(milliseconds: 400),
              child: Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: AppTheme.spacingL),

            SlideInAnimation(
              delay: Duration(milliseconds: 600),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.quiz_rounded,
                      title: '5',
                      subtitle: 'Questions',
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.category_rounded,
                      title: '5',
                      subtitle: 'Categories',
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingM),

            SlideInAnimation(
              delay: Duration(milliseconds: 800),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.psychology_alt_rounded,
                      title: '100',
                      subtitle: 'Max Points',
                      color: AppTheme.accentColor,
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.emoji_events_rounded,
                      title: '3',
                      subtitle: 'Difficulty Levels',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingXL),

            // Categories section
            SlideInAnimation(
              delay: Duration(milliseconds: 1000),
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: AppTheme.spacingL),

            SlideInAnimation(
              delay: Duration(milliseconds: 1200),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.2,
                children: [
                  _buildCategoryCard(
                    icon: Icons.location_city,
                    title: 'Geography',
                    color: Colors.blue,
                  ),
                  _buildCategoryCard(
                    icon: Icons.calculate,
                    title: 'Mathematics',
                    color: Colors.green,
                  ),
                  _buildCategoryCard(
                    icon: Icons.pets,
                    title: 'Nature',
                    color: Colors.orange,
                  ),
                  _buildCategoryCard(
                    icon: Icons.brush,
                    title: 'Art',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.spacingL),

            // AI Quiz Generator Feature
            SlideInAnimation(
              delay: Duration(milliseconds: 1400),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppTheme.spacingM),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.psychology,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Quiz Generator',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Create custom quizzes on any topic',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => TopicInputPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(curve: Curves.easeInOut)),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Generate Custom Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return PulsingButton(
      onPressed: null,
      glowColor: color,
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            ProgressRing(
              progress: 0.8,
              size: 60,
              strokeWidth: 4,
              backgroundColor: color.withOpacity(0.2),
              progressColor: color,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: AppTheme.spacingM),
            AnimatedCounter(
              value: int.parse(title),
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: AppTheme.spacingM),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPage() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SlideInAnimation(
              child: Text(
                'Your Statistics',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacingXL),
            SlideInAnimation(
              delay: Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: AppTheme.spacingL),
                    Text(
                      'Statistics Coming Soon',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppTheme.spacingM),
                    Text(
                      'Track your progress, view detailed analytics, and see your improvement over time.',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDarkMode = settings.isDarkMode;
        
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideInAnimation(
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: EnhancedAppTheme.getTextPrimary(isDarkMode),
                    ),
                  ),
                ),
                
                SizedBox(height: AppTheme.spacingL),
                
                // Appearance Section
                SlideInAnimation(
                  delay: Duration(milliseconds: 200),
                  child: _buildSettingsSection(
                    title: 'Appearance',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildSettingToggle(
                        icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: isDarkMode ? 'Switch to light theme' : 'Switch to dark theme',
                        value: isDarkMode,
                        onChanged: (value) => settings.toggleTheme(),
                        iconColor: isDarkMode ? Colors.indigo : Colors.amber,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppTheme.spacingL),
                
                // Experience Section
                SlideInAnimation(
                  delay: Duration(milliseconds: 400),
                  child: _buildSettingsSection(
                    title: 'Experience',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildSettingToggle(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic Feedback',
                        subtitle: 'Feel tactile responses for interactions',
                        value: settings.hapticEnabled,
                        onChanged: (value) => settings.toggleHaptic(),
                        iconColor: Colors.green,
                        isDarkMode: isDarkMode,
                      ),
                      Divider(color: EnhancedAppTheme.getTextLight(isDarkMode).withOpacity(0.2)),
                      _buildSettingToggle(
                        icon: Icons.volume_up_rounded,
                        title: 'Sound Effects',
                        subtitle: 'Enable audio feedback for actions',
                        value: settings.soundEnabled,
                        onChanged: (value) => settings.toggleSound(),
                        iconColor: Colors.blue,
                        isDarkMode: isDarkMode,
                      ),
                      Divider(color: EnhancedAppTheme.getTextLight(isDarkMode).withOpacity(0.2)),
                      _buildSettingToggle(
                        icon: Icons.animation_rounded,
                        title: 'Animations',
                        subtitle: 'Enable smooth transitions and effects',
                        value: settings.animationsEnabled,
                        onChanged: (value) => settings.toggleAnimations(),
                        iconColor: Colors.purple,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppTheme.spacingL),
                
                // Information Section
                SlideInAnimation(
                  delay: Duration(milliseconds: 600),
                  child: _buildSettingsSection(
                    title: 'Information',
                    isDarkMode: isDarkMode,
                    children: [
                      _buildSettingItem(
                        icon: Icons.api,
                        title: 'AI Configuration',
                        subtitle: 'Set up OpenAI API key for enhanced questions',
                        onTap: () {
                          settings.triggerHaptic(HapticFeedbackType.light);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => APIConfigPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(curve: Curves.easeInOut)),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        iconColor: Colors.orange,
                        isDarkMode: isDarkMode,
                      ),
                      Divider(color: EnhancedAppTheme.getTextLight(isDarkMode).withOpacity(0.2)),
                      _buildSettingItem(
                        icon: Icons.info_rounded,
                        title: 'About Quiz Premium',
                        subtitle: 'App information, credits, and version',
                        onTap: () {
                          settings.triggerHaptic(HapticFeedbackType.light);
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => AboutPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(curve: Curves.easeInOut)),
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        iconColor: AppTheme.primaryColor,
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: AppTheme.spacingXL),
                
                // Reset Section
                SlideInAnimation(
                  delay: Duration(milliseconds: 800),
                  child: PulsingButton(
                    onPressed: () => _showResetDialog(context, settings),
                    glowColor: AppTheme.errorColor,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppTheme.spacingL),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restore_rounded,
                            color: AppTheme.errorColor,
                          ),
                          SizedBox(width: AppTheme.spacingS),
                          Text(
                            'Reset All Settings',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: EnhancedAppTheme.getSurfaceColor(isDarkMode),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: EnhancedAppTheme.getTextPrimary(isDarkMode),
            ),
          ),
          SizedBox(height: AppTheme.spacingL),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: EnhancedAppTheme.getTextPrimary(isDarkMode),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: EnhancedAppTheme.getTextSecondary(isDarkMode),
          fontSize: 14,
        ),
      ),
      trailing: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          inactiveThumbColor: EnhancedAppTheme.getTextLight(isDarkMode),
          inactiveTrackColor: EnhancedAppTheme.getTextLight(isDarkMode).withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
    required bool isDarkMode,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(AppTheme.spacingS),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: EnhancedAppTheme.getTextPrimary(isDarkMode),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: EnhancedAppTheme.getTextSecondary(isDarkMode),
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: EnhancedAppTheme.getTextLight(isDarkMode),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    final isDarkMode = settings.isDarkMode;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: EnhancedAppTheme.getSurfaceColor(isDarkMode),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: AppTheme.errorColor,
              ),
              SizedBox(width: AppTheme.spacingS),
              Text(
                'Reset Settings',
                style: TextStyle(
                  color: EnhancedAppTheme.getTextPrimary(isDarkMode),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
            style: TextStyle(
              color: EnhancedAppTheme.getTextSecondary(isDarkMode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                settings.triggerHaptic(HapticFeedbackType.light);
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: EnhancedAppTheme.getTextSecondary(isDarkMode),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                settings.triggerHaptic(HapticFeedbackType.medium);
                settings.resetSettings();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Settings reset successfully'),
                    backgroundColor: AppTheme.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}