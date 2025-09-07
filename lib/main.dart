import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용


import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/utils/timeago_localization.dart';
import 'core/utils/url_strategy_helper.dart'; // 헬퍼 import

void main() async {
  // 웹 URL 전략 설정 (웹에서만)
  configureUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 검증
  AppConfig.validateConfig();

  // 상태바 투명하게 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Supabase 초기화
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Kakao SDK 초기화
  if (kIsWeb) {
    KakaoSdk.init(javaScriptAppKey: AppConfig.kakaoJavaScriptAppKey);
  } else {
    KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);
  }

  // 시간 현지화 초기화
  TimeagoLocalization.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'LivingLogos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return MediaQuery(
          // 텍스트 크기 고정 (사용자 설정 무시)
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}