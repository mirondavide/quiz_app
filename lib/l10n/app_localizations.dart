import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AI Quiz Master'**
  String get appTitle;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to AI Quiz Master'**
  String get welcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge with AI-powered quizzes'**
  String get welcomeSubtitle;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Language selection title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the best experience'**
  String get selectLanguageSubtitle;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Topic input screen title
  ///
  /// In en, this message translates to:
  /// **'What would you like to learn about?'**
  String get enterTopicTitle;

  /// Topic input screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter any topic and we\'ll create a personalized quiz for you'**
  String get enterTopicSubtitle;

  /// Topic input field placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g., Physics, History, Programming...'**
  String get topicPlaceholder;

  /// Generate quiz button text
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateQuiz;

  /// Generating text for loading screen
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get generating;

  /// Generating quiz loading text
  ///
  /// In en, this message translates to:
  /// **'Generating your personalized quiz...'**
  String get generatingQuiz;

  /// Question label
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Explanation label
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Excellent performance message
  ///
  /// In en, this message translates to:
  /// **'Excellent Work!'**
  String get excellentWork;

  /// Good performance message
  ///
  /// In en, this message translates to:
  /// **'Good Job!'**
  String get goodJob;

  /// Needs improvement message
  ///
  /// In en, this message translates to:
  /// **'Keep Trying!'**
  String get keepTrying;

  /// New quiz button text
  ///
  /// In en, this message translates to:
  /// **'New Quiz'**
  String get newQuiz;

  /// Review answers button text
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Dark mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// Italian language name
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get italian;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get russian;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// Dutch language name
  ///
  /// In en, this message translates to:
  /// **'Nederlands'**
  String get dutch;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// Turkish language name
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// Swedish language name
  ///
  /// In en, this message translates to:
  /// **'Svenska'**
  String get swedish;

  /// Polish language name
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get polish;

  /// Norwegian language name
  ///
  /// In en, this message translates to:
  /// **'Norsk'**
  String get norwegian;

  /// AI Quiz Generator title
  ///
  /// In en, this message translates to:
  /// **'AI Quiz Generator'**
  String get aiQuizGenerator;

  /// AI Quiz subtitle description
  ///
  /// In en, this message translates to:
  /// **'Enter any topic and get instant personalized quiz questions powered by AI'**
  String get aiQuizSubtitle;

  /// Topic input field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., Quantum Physics, Renaissance Art, Machine Learning...'**
  String get topicInputHint;

  /// Generate quiz questions button text
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz Questions'**
  String get generateQuizQuestions;

  /// Popular topics section title
  ///
  /// In en, this message translates to:
  /// **'Popular Topics'**
  String get popularTopics;

  /// Loading text for generating questions
  ///
  /// In en, this message translates to:
  /// **'Generating Premium Questions...'**
  String get generatingQuestions;

  /// AI crafting message during loading
  ///
  /// In en, this message translates to:
  /// **'Our AI is crafting personalized questions\njust for you'**
  String get aiCraftingMessage;

  /// Error message title
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get somethingWentWrong;

  /// Failed to generate questions error message
  ///
  /// In en, this message translates to:
  /// **'Failed to generate questions'**
  String get failedGenerateQuestions;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Excellent feedback message
  ///
  /// In en, this message translates to:
  /// **'Excellent! 🎉'**
  String get excellent;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Not quite right 🤔'**
  String get notQuiteRight;

  /// Points earned message
  ///
  /// In en, this message translates to:
  /// **'+{points} points earned!'**
  String pointsEarned(int points);

  /// Quiz completion message
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Outstanding performance message
  ///
  /// In en, this message translates to:
  /// **'Outstanding Performance!'**
  String get outstandingPerformance;

  /// Great job message
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// Good effort message
  ///
  /// In en, this message translates to:
  /// **'Good Effort!'**
  String get goodEffort;

  /// Keep learning message
  ///
  /// In en, this message translates to:
  /// **'Keep Learning!'**
  String get keepLearning;

  /// Points label
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// Accuracy label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// New topic button text
  ///
  /// In en, this message translates to:
  /// **'New Topic'**
  String get newTopic;

  /// Of preposition for question counter
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get outOf;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Quiz tab label
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// About tab label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Welcome greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Start quiz button text
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// Create quiz description
  ///
  /// In en, this message translates to:
  /// **'Create personalized quizzes'**
  String get createQuiz;

  /// Customize description
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customize;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle description
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark themes'**
  String get toggleDarkMode;

  /// Haptic feedback setting
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic feedback description
  ///
  /// In en, this message translates to:
  /// **'Enable vibration for interactions'**
  String get enableVibration;

  /// About app menu item
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// App info description
  ///
  /// In en, this message translates to:
  /// **'Learn more about the app'**
  String get appInfo;

  /// AI Assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// Upload or ask anything subtitle
  ///
  /// In en, this message translates to:
  /// **'Upload files or ask me anything'**
  String get uploadOrAskAnything;

  /// Start AI button
  ///
  /// In en, this message translates to:
  /// **'Start AI Chat'**
  String get startAI;

  /// Upload or type description
  ///
  /// In en, this message translates to:
  /// **'Upload files or type questions'**
  String get uploadOrType;

  /// Legacy quiz description
  ///
  /// In en, this message translates to:
  /// **'Traditional quiz mode'**
  String get legacyQuiz;

  /// AI Chat tab
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// Choose input method
  ///
  /// In en, this message translates to:
  /// **'Choose Input Method'**
  String get chooseInputMethod;

  /// Select how to provide content
  ///
  /// In en, this message translates to:
  /// **'Select how you want to provide content'**
  String get selectHowToProvideContent;

  /// Upload file option
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// Upload file description
  ///
  /// In en, this message translates to:
  /// **'Upload PDF, DOCX, or images'**
  String get uploadFileDescription;

  /// Type topic option
  ///
  /// In en, this message translates to:
  /// **'Type Topic'**
  String get typeTopic;

  /// Type topic description
  ///
  /// In en, this message translates to:
  /// **'Enter any question or topic'**
  String get typeTopicDescription;

  /// Supported formats
  ///
  /// In en, this message translates to:
  /// **'Supported Formats'**
  String get supportedFormats;

  /// Supported formats description
  ///
  /// In en, this message translates to:
  /// **'PDF, DOCX, DOC, TXT, JPG, PNG, and more'**
  String get supportedFormatsDescription;

  /// Select file to analyze
  ///
  /// In en, this message translates to:
  /// **'Select a file to analyze with AI'**
  String get selectFileToAnalyze;

  /// Tap to upload
  ///
  /// In en, this message translates to:
  /// **'Tap to Upload File'**
  String get tapToUpload;

  /// Or choose option
  ///
  /// In en, this message translates to:
  /// **'Or choose an option below'**
  String get orChooseOption;

  /// Gallery option
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Send to AI
  ///
  /// In en, this message translates to:
  /// **'Send to AI'**
  String get sendToAI;

  /// Processing
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// File not supported
  ///
  /// In en, this message translates to:
  /// **'File format not supported'**
  String get fileNotSupported;

  /// File pick error
  ///
  /// In en, this message translates to:
  /// **'Error picking file'**
  String get filePickError;

  /// Image pick error
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get imagePickError;

  /// Camera error
  ///
  /// In en, this message translates to:
  /// **'Error accessing camera'**
  String get cameraError;

  /// Processing error
  ///
  /// In en, this message translates to:
  /// **'Error processing request'**
  String get processingError;

  /// Enter topic description
  ///
  /// In en, this message translates to:
  /// **'Enter any topic or question to get AI insights'**
  String get enterTopicDescription;

  /// Your topic
  ///
  /// In en, this message translates to:
  /// **'Your Topic'**
  String get yourTopic;

  /// Enter topic hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Explain quantum computing, summarize this concept...'**
  String get enterTopicHint;

  /// Suggested topics
  ///
  /// In en, this message translates to:
  /// **'Suggested Topics'**
  String get suggestedTopics;

  /// Ask AI
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAI;

  /// Please enter topic
  ///
  /// In en, this message translates to:
  /// **'Please enter a topic or question'**
  String get pleaseEnterTopic;

  /// Preparing response
  ///
  /// In en, this message translates to:
  /// **'Preparing Response'**
  String get preparingResponse;

  /// Processing input
  ///
  /// In en, this message translates to:
  /// **'Processing your input with AI...'**
  String get processingInput;

  /// Error occurred
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurred;

  /// Unknown error
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// Go back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Ready to help
  ///
  /// In en, this message translates to:
  /// **'Ready to help'**
  String get readyToHelp;

  /// Typing
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// Just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Ask follow up
  ///
  /// In en, this message translates to:
  /// **'Ask a follow-up question...'**
  String get askFollowUp;

  /// API Configuration
  ///
  /// In en, this message translates to:
  /// **'API Configuration'**
  String get apiConfiguration;

  /// Configure AI
  ///
  /// In en, this message translates to:
  /// **'Configure AI settings'**
  String get configureAI;

  /// API Key
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// Enter API key
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key'**
  String get enterApiKey;

  /// API URL
  ///
  /// In en, this message translates to:
  /// **'API URL'**
  String get apiUrl;

  /// Custom API URL
  ///
  /// In en, this message translates to:
  /// **'Custom API URL (optional)'**
  String get customApiUrl;

  /// Model
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Select model
  ///
  /// In en, this message translates to:
  /// **'Select AI model'**
  String get selectModel;

  /// Test connection
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Connection successful
  ///
  /// In en, this message translates to:
  /// **'Connection successful!'**
  String get connectionSuccessful;

  /// Connection failed
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// API key required
  ///
  /// In en, this message translates to:
  /// **'API key is required'**
  String get apiKeyRequired;

  /// Invalid API key
  ///
  /// In en, this message translates to:
  /// **'Invalid API key format'**
  String get invalidApiKey;

  /// Settings saved
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// AI not configured
  ///
  /// In en, this message translates to:
  /// **'AI not configured. Please set your API key in settings.'**
  String get aiNotConfigured;

  /// Configure now
  ///
  /// In en, this message translates to:
  /// **'Configure Now'**
  String get configureNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'ko',
    'nl',
    'no',
    'pl',
    'pt',
    'ru',
    'sv',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
