class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    // defaultValue: 'YOUR_SUPABASE_URL',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    // defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Kakao SDK Configuration
  static const String kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    // defaultValue: 'YOUR_KAKAO_NATIVE_APP_KEY',
  );

  static const String kakaoJavaScriptAppKey = String.fromEnvironment(
    'KAKAO_JAVASCRIPT_APP_KEY',
    // defaultValue: 'YOUR_KAKAO_JAVASCRIPT_APP_KEY',
  );

  // App Information
  static const String appName = '고양시 한국장학재단 연합기숙사 커뮤니티';
  static const String appShortName = 'LivingLogos';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableKakaoLogin = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = false; // 개발 단계에서는 비활성화

  // UI Configuration
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonHeight = 50.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPostTitleLength = 100;
  static const int maxPostContentLength = 5000;
  static const int maxCommentLength = 500;

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;

  // Cache Configuration
  static const Duration cacheExpiry = Duration(minutes: 30);
  static const int maxCacheSize = 100; // MB

  // Image Configuration
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const int maxImageSizeMB = 10;
  static const int maxImagesPerPost = 5;

  // Environment Detection
  static bool get isDebug {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }

  static bool get isRelease => !isDebug;

  // Validation Methods
  static bool get isValidSupabaseConfig {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY' &&
        supabaseAnonKey.isNotEmpty;
  }

  static bool get isValidKakaoConfig {
    return kakaoNativeAppKey.isNotEmpty && kakaoJavaScriptAppKey.isNotEmpty;

  }

  // Helper methods for configuration validation
  static void validateConfig() {
    if (!isValidSupabaseConfig) {
      throw Exception(
        'Supabase configuration is missing. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
      );
    }

    if (enableKakaoLogin && !isValidKakaoConfig) {
      throw Exception(
        'Kakao configuration is missing. Please set KAKAO_NATIVE_APP_KEY environment variable.',
      );
    }
  }
}