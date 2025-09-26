// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'AI 퀴즈 마스터';

  @override
  String get welcomeTitle => 'AI 퀴즈 마스터에 오신 것을 환영합니다';

  @override
  String get welcomeSubtitle => 'AI 기반 퀴즈로 지식을 테스트하세요';

  @override
  String get getStarted => '시작하기';

  @override
  String get chooseLanguage => '언어 선택';

  @override
  String get selectLanguageSubtitle => '최상의 경험을 위해 선호하는 언어를 선택하세요';

  @override
  String get continueButton => '계속';

  @override
  String get enterTopicTitle => '무엇에 대해 배우고 싶으신가요?';

  @override
  String get enterTopicSubtitle => '아무 주제나 입력하시면 맞춤형 퀴즈를 만들어 드립니다';

  @override
  String get topicPlaceholder => '예: 양자물리학, 르네상스 미술, 머신러닝...';

  @override
  String get generateQuiz => '퀴즈 생성';

  @override
  String get generating => '생성 중';

  @override
  String get generatingQuiz => '맞춤형 퀴즈를 생성하는 중...';

  @override
  String get question => '문제';

  @override
  String get next => '다음';

  @override
  String get finish => '완료';

  @override
  String get correct => '정답!';

  @override
  String get incorrect => '오답';

  @override
  String get explanation => '해설';

  @override
  String get yourScore => '당신의 점수';

  @override
  String get excellentWork => '훌륭합니다!';

  @override
  String get goodJob => '잘했습니다!';

  @override
  String get keepTrying => '계속 노력하세요!';

  @override
  String get newQuiz => '새 퀴즈';

  @override
  String get reviewAnswers => '답안 검토';

  @override
  String get settings => '설정';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get darkMode => '다크 모드';

  @override
  String get notifications => '알림';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Français';

  @override
  String get german => 'Deutsch';

  @override
  String get chinese => '中文';

  @override
  String get italian => 'Italiano';

  @override
  String get portuguese => 'Português';

  @override
  String get russian => 'Русский';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String get dutch => 'Nederlands';

  @override
  String get arabic => 'العربية';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get turkish => 'Türkçe';

  @override
  String get swedish => 'Svenska';

  @override
  String get polish => 'Polski';

  @override
  String get norwegian => 'Norsk';

  @override
  String get aiQuizGenerator => 'AI 퀴즈 생성기';

  @override
  String get aiQuizSubtitle => '아무 주제나 입력하고 AI로 맞춤형 퀴즈 문제를 즉시 받아보세요';

  @override
  String get topicInputHint => '예: 양자물리학, 르네상스 미술, 머신러닝...';

  @override
  String get generateQuizQuestions => '퀴즈 문제 생성';

  @override
  String get popularTopics => '인기 주제';

  @override
  String get generatingQuestions => '프리미엄 문제 생성 중...';

  @override
  String get aiCraftingMessage => '우리의 AI가 당신만을 위한\n맞춤형 문제를 제작 중입니다';

  @override
  String get somethingWentWrong => '앗! 문제가 발생했습니다';

  @override
  String get failedGenerateQuestions => '문제 생성에 실패했습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get excellent => '훌륭해요! 🎉';

  @override
  String get notQuiteRight => '아쉬워요 🤔';

  @override
  String pointsEarned(int points) {
    return '+$points점 획득!';
  }

  @override
  String get quizComplete => '퀴즈 완료!';

  @override
  String get outstandingPerformance => '뛰어난 성과!';

  @override
  String get greatJob => '훌륭한 일!';

  @override
  String get goodEffort => '좋은 노력!';

  @override
  String get keepLearning => '계속 배우세요!';

  @override
  String get points => '점수';

  @override
  String get accuracy => '정확도';

  @override
  String get retry => '재시도';

  @override
  String get newTopic => '새 주제';

  @override
  String get outOf => '중';

  @override
  String get home => 'Home';

  @override
  String get quiz => 'Quiz';

  @override
  String get about => 'About';

  @override
  String get welcome => 'Welcome';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get createQuiz => 'Create personalized quizzes';

  @override
  String get customize => 'Customize your experience';

  @override
  String get appearance => 'Appearance';

  @override
  String get toggleDarkMode => 'Switch between light and dark themes';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get enableVibration => 'Enable vibration for interactions';

  @override
  String get aboutApp => 'About App';

  @override
  String get appInfo => 'Learn more about the app';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get uploadOrAskAnything => 'Upload files or ask me anything';

  @override
  String get startAI => 'Start AI Chat';

  @override
  String get uploadOrType => 'Upload files or type questions';

  @override
  String get legacyQuiz => 'Traditional quiz mode';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get chooseInputMethod => 'Choose Input Method';

  @override
  String get selectHowToProvideContent =>
      'Select how you want to provide content';

  @override
  String get uploadFile => 'Upload File';

  @override
  String get uploadFileDescription => 'Upload PDF, DOCX, or images';

  @override
  String get typeTopic => 'Type Topic';

  @override
  String get typeTopicDescription => 'Enter any question or topic';

  @override
  String get supportedFormats => 'Supported Formats';

  @override
  String get supportedFormatsDescription =>
      'PDF, DOCX, DOC, TXT, JPG, PNG, and more';

  @override
  String get selectFileToAnalyze => 'Select a file to analyze with AI';

  @override
  String get tapToUpload => 'Tap to Upload File';

  @override
  String get orChooseOption => 'Or choose an option below';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get sendToAI => 'Send to AI';

  @override
  String get processing => 'Processing...';

  @override
  String get fileNotSupported => 'File format not supported';

  @override
  String get filePickError => 'Error picking file';

  @override
  String get imagePickError => 'Error picking image';

  @override
  String get cameraError => 'Error accessing camera';

  @override
  String get processingError => 'Error processing request';

  @override
  String get enterTopicDescription =>
      'Enter any topic or question to get AI insights';

  @override
  String get yourTopic => 'Your Topic';

  @override
  String get enterTopicHint =>
      'e.g., Explain quantum computing, summarize this concept...';

  @override
  String get suggestedTopics => 'Suggested Topics';

  @override
  String get askAI => 'Ask AI';

  @override
  String get pleaseEnterTopic => 'Please enter a topic or question';

  @override
  String get preparingResponse => 'Preparing Response';

  @override
  String get processingInput => 'Processing your input with AI...';

  @override
  String get errorOccurred => 'An Error Occurred';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get goBack => 'Go Back';

  @override
  String get readyToHelp => 'Ready to help';

  @override
  String get typing => 'Typing...';

  @override
  String get justNow => 'Just now';

  @override
  String get askFollowUp => 'Ask a follow-up question...';

  @override
  String get apiConfiguration => 'API Configuration';

  @override
  String get configureAI => 'Configure AI settings';

  @override
  String get apiKey => 'API Key';

  @override
  String get enterApiKey => 'Enter your OpenAI API key';

  @override
  String get apiUrl => 'API URL';

  @override
  String get customApiUrl => 'Custom API URL (optional)';

  @override
  String get model => 'Model';

  @override
  String get selectModel => 'Select AI model';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get save => 'Save';

  @override
  String get connectionSuccessful => 'Connection successful!';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get apiKeyRequired => 'API key is required';

  @override
  String get invalidApiKey => 'Invalid API key format';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get aiNotConfigured =>
      'AI not configured. Please set your API key in settings.';

  @override
  String get configureNow => 'Configure Now';
}
