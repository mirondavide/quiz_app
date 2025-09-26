// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'AIクイズマスター';

  @override
  String get welcomeTitle => 'AIクイズマスターへようこそ';

  @override
  String get welcomeSubtitle => 'AI搭載クイズで知識をテストしよう';

  @override
  String get getStarted => '開始';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get selectLanguageSubtitle => '最高の体験のためにお好みの言語を選択してください';

  @override
  String get continueButton => '続行';

  @override
  String get enterTopicTitle => '何について学びたいですか？';

  @override
  String get enterTopicSubtitle => '任意のトピックを入力すると、パーソナライズされたクイズを作成します';

  @override
  String get topicPlaceholder => '例：量子物理学、ルネサンス芸術、機械学習...';

  @override
  String get generateQuiz => 'クイズ生成';

  @override
  String get generating => '生成中';

  @override
  String get generatingQuiz => 'パーソナライズされたクイズを生成中...';

  @override
  String get question => '質問';

  @override
  String get next => '次へ';

  @override
  String get finish => '完了';

  @override
  String get correct => '正解！';

  @override
  String get incorrect => '不正解';

  @override
  String get explanation => '解説';

  @override
  String get yourScore => 'あなたのスコア';

  @override
  String get excellentWork => '素晴らしい！';

  @override
  String get goodJob => 'よくできました！';

  @override
  String get keepTrying => '頑張って！';

  @override
  String get newQuiz => '新しいクイズ';

  @override
  String get reviewAnswers => '答えを確認';

  @override
  String get settings => '設定';

  @override
  String get languageSettings => '言語設定';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get notifications => '通知';

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
  String get aiQuizGenerator => 'AIクイズジェネレーター';

  @override
  String get aiQuizSubtitle => '任意のトピックを入力して、AIによるパーソナライズされたクイズ問題を即座に取得';

  @override
  String get topicInputHint => '例：量子物理学、ルネサンス芸術、機械学習...';

  @override
  String get generateQuizQuestions => 'クイズ問題を生成';

  @override
  String get popularTopics => '人気のトピック';

  @override
  String get generatingQuestions => 'プレミアム問題を生成中...';

  @override
  String get aiCraftingMessage => '私たちのAIがあなただけの\nパーソナライズされた問題を作成中';

  @override
  String get somethingWentWrong => 'おっと！何かがうまくいきませんでした';

  @override
  String get failedGenerateQuestions => '問題の生成に失敗しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get excellent => '素晴らしい！🎉';

  @override
  String get notQuiteRight => '惜しい🤔';

  @override
  String pointsEarned(int points) {
    return '+$pointsポイント獲得！';
  }

  @override
  String get quizComplete => 'クイズ完了！';

  @override
  String get outstandingPerformance => '優秀な成績！';

  @override
  String get greatJob => 'よくできました！';

  @override
  String get goodEffort => '良い努力！';

  @override
  String get keepLearning => '学習を続けよう！';

  @override
  String get points => 'ポイント';

  @override
  String get accuracy => '正答率';

  @override
  String get retry => '再挑戦';

  @override
  String get newTopic => '新しいトピック';

  @override
  String get outOf => '／';

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
