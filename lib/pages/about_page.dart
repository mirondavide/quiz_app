import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
              'About',
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
                  children: [
                    // App Icon and Name
                    _buildAppHeader(isDark),
                    const SizedBox(height: 40),
                    
                    // App Info
                    _buildInfoCard(isDark),
                    const SizedBox(height: 24),
                    
                    // Features
                    _buildFeaturesCard(isDark),
                    const SizedBox(height: 24),
                    
                    // Developer Info
                    _buildDeveloperCard(isDark),
                    const SizedBox(height: 24),
                    
                    // Version Info
                    _buildVersionInfo(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF),
                const Color(0xFF5A52FF),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.quiz,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Quiz Master',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge Your Knowledge',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'About This App',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz Master is an engaging and interactive quiz application designed to challenge your knowledge across various topics. Test yourself with carefully crafted questions and track your progress as you learn.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(bool isDark) {
    final features = [
      {'icon': Icons.quiz, 'title': 'Interactive Quizzes', 'desc': 'Engaging questions with instant feedback'},
      {'icon': Icons.analytics, 'title': 'Progress Tracking', 'desc': 'Monitor your performance and improvement'},
      {'icon': Icons.palette, 'title': 'Beautiful UI', 'desc': 'Modern design with smooth animations'},
      {'icon': Icons.settings, 'title': 'Customizable', 'desc': 'Personalize your quiz experience'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['desc'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: const Color(0xFF6C63FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Developer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF6C63FF),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Master Team',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Built with Flutter & ❤️',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Quiz Master. All rights reserved.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}