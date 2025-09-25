import 'lib/services/ai_topic_generator.dart';

void main() async {
  print('Testing Multilingual Answer Generation...\n');
  
  // Test Spanish
  print('=== TESTING SPANISH ANSWERS ===');
  final spanishQuestions = await AITopicGenerator.generateQuestions(
    'Mathematics', 
    count: 2, 
    language: 'es'
  );
  
  for (int i = 0; i < spanishQuestions.length; i++) {
    final q = spanishQuestions[i];
    print('Question ${i + 1} (Spanish):');
    print('Q: ${q.text}'); 
    print('Answers:');
    for (int j = 0; j < q.options.length; j++) {
      print('  ${j + 1}. ${q.options[j]}');
    }
    print('Correct: ${q.options[q.correctIndex]}\n');
  }
  
  // Test French
  print('=== TESTING FRENCH ANSWERS ===');
  final frenchQuestions = await AITopicGenerator.generateQuestions(
    'Mathematics', 
    count: 2, 
    language: 'fr'
  );
  
  for (int i = 0; i < frenchQuestions.length; i++) {
    final q = frenchQuestions[i];
    print('Question ${i + 1} (French):');
    print('Q: ${q.text}');
    print('Answers:');
    for (int j = 0; j < q.options.length; j++) {
      print('  ${j + 1}. ${q.options[j]}');
    }
    print('Correct: ${q.options[q.correctIndex]}\n');
  }
  
  // Test German  
  print('=== TESTING GERMAN ANSWERS ===');
  final germanQuestions = await AITopicGenerator.generateQuestions(
    'Mathematics', 
    count: 2, 
    language: 'de'
  );
  
  for (int i = 0; i < germanQuestions.length; i++) {
    final q = germanQuestions[i];
    print('Question ${i + 1} (German):');
    print('Q: ${q.text}');
    print('Answers:');
    for (int j = 0; j < q.options.length; j++) {
      print('  ${j + 1}. ${q.options[j]}');
    }
    print('Correct: ${q.options[q.correctIndex]}\n');
  }
}