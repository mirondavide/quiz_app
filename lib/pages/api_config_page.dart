import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class APIConfigPage extends StatefulWidget {
  const APIConfigPage({super.key});

  @override
  State<APIConfigPage> createState() => _APIConfigPageState();
}

class _APIConfigPageState extends State<APIConfigPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _loadAPIKey();
  }

  Future<void> _loadAPIKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('openai_api_key') ?? '';
    if (apiKey.isNotEmpty) {
      _apiKeyController.text = apiKey;
    }
  }

  Future<void> _saveAPIKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      _showMessage('Please enter an API key', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', _apiKeyController.text.trim());
      
      if (mounted) {
        _showMessage('API key saved successfully!', isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      _showMessage('Failed to save API key', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
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
              'AI Configuration',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.api,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'OpenAI API Configuration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your OpenAI API key to enable AI-powered question generation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // API Key Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OpenAI API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _apiKeyController,
                        obscureText: _isObscured,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'sk-...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.4) : Colors.grey[500],
                          ),
                          prefixIcon: Icon(
                            Icons.key,
                            color: AppTheme.primaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility_off : Icons.visibility,
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'How to get your API key:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Visit platform.openai.com\n'
                        '2. Sign up or log in to your account\n'
                        '3. Go to API section\n'
                        '4. Generate a new API key\n'
                        '5. Copy and paste it here',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAPIKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Save API Key',
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
        );
      },
    );
  }
}