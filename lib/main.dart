import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'main_navigation.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'services/language_service.dart';
import 'screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize language service
  final languageService = LanguageService();
  await languageService.loadSavedLanguage();
  
  runApp(QuizApp(languageService: languageService));
}

class QuizApp extends StatelessWidget {
  final LanguageService languageService;
  
  const QuizApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider(
          create: (context) => SettingsProvider()..initializeSettings(),
        ),
      ],
      child: Consumer2<LanguageService, SettingsProvider>(
        builder: (context, languageService, settings, child) {
          return MaterialApp(
            title: 'AI Quiz Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.theme.copyWith(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.primaryColor,
                brightness: Brightness.dark,
              ),
            ),
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
