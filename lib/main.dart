import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'main_navigation.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'services/language_service.dart';
import 'services/ai_service.dart';
import 'screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize language service
  final languageService = LanguageService();
  await languageService.loadSavedLanguage();
  
  // Initialize AI service
  final aiService = AIService();
  await aiService.loadConfiguration();
  
  runApp(QuizApp(languageService: languageService, aiService: aiService));
}

class QuizApp extends StatelessWidget {
  final LanguageService languageService;
  final AIService aiService;
  
  const QuizApp({super.key, required this.languageService, required this.aiService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider()..initializeSettings(),
        ),
        Provider.value(value: aiService),
      ],
      child: Consumer2<LanguageService, SettingsProvider>(
        builder: (context, languageService, settings, child) {
          // Update system UI overlay based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: settings.isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor,
              systemNavigationBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
            ),
          );
          
          return MaterialApp(
            title: 'AI Quiz Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LanguageService.supportedLocales,
            home: _shouldShowLanguageSelection() 
                ? const LanguageSelectionScreen(isOnboarding: true)
                : MainNavigationPage(),
            routes: {
              '/main': (context) => MainNavigationPage(),
              '/language': (context) => const LanguageSelectionScreen(),
            },
          );
        },
      ),
    );
  }
  
  bool _shouldShowLanguageSelection() {
    // Show language selection on first launch
    // You can customize this logic based on your needs
    return false; // Set to true for first-time users
  }
}