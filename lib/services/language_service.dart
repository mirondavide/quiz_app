import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('en');
  
  Locale get currentLocale => _currentLocale;
  
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('zh'),
    Locale('ar'),
    Locale('hi'),
    Locale('tr'),
    Locale('sv'),
    Locale('pl'),
    Locale('no'),
  ];
  
  static const Map<String, LanguageOption> languages = {
    'en': LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
    ),
    'es': LanguageOption(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flagEmoji: '🇪🇸',
    ),
    'fr': LanguageOption(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flagEmoji: '🇫🇷',
    ),
    'de': LanguageOption(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flagEmoji: '🇩🇪',
    ),
    'it': LanguageOption(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      flagEmoji: '🇮🇹',
    ),
    'pt': LanguageOption(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      flagEmoji: '🇵🇹',
    ),
    'ru': LanguageOption(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      flagEmoji: '🇷🇺',
    ),
    'ja': LanguageOption(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flagEmoji: '🇯🇵',
    ),
    'ko': LanguageOption(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flagEmoji: '🇰🇷',
    ),
    'nl': LanguageOption(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
      flagEmoji: '🇳🇱',
    ),
    'zh': LanguageOption(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flagEmoji: '🇨🇳',
    ),
    'ar': LanguageOption(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flagEmoji: '🇸🇦',
    ),
    'hi': LanguageOption(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
    'tr': LanguageOption(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flagEmoji: '🇹🇷',
    ),
    'sv': LanguageOption(
      code: 'sv',
      name: 'Swedish',
      nativeName: 'Svenska',
      flagEmoji: '🇸🇪',
    ),
    'pl': LanguageOption(
      code: 'pl',
      name: 'Polish',
      nativeName: 'Polski',
      flagEmoji: '🇵🇱',
    ),
    'no': LanguageOption(
      code: 'no',
      name: 'Norwegian',
      nativeName: 'Norsk',
      flagEmoji: '🇳🇴',
    ),
  };
  
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString(_languageKey);
    
    if (savedLanguageCode != null && languages.containsKey(savedLanguageCode)) {
      _currentLocale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }
  
  Future<void> changeLanguage(String languageCode) async {
    if (languages.containsKey(languageCode)) {
      _currentLocale = Locale(languageCode);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      notifyListeners();
    }
  }
  
  LanguageOption? getCurrentLanguageOption() {
    return languages[_currentLocale.languageCode];
  }
  
  List<LanguageOption> getAllLanguageOptions() {
    return languages.values.toList();
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;
  
  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });
}