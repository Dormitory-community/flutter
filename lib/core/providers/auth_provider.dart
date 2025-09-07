import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../models/user_model.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier(this._supabase) : super(const AsyncValue.loading()) {
    _init();
  }

  final SupabaseClient _supabase;
  bool _isInitialized = false;

  // TODO: 앱 스킴/리다이렉트 URI를 실제 값으로 바꾸세요.
  // 예: 'io.yourapp://login-callback' (Android/iOS 앱 스킴)
  // 웹은 null(또는 Supabase에서 관리하는 콜백)을 사용합니다.
  static const String kRedirectUriAndroidIos = 'livinglogos://login-callback';

  void _init() {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      // 초기 세션 확인
      final session = _supabase.auth.currentSession;
      if (session != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(session.user));
      } else {
        state = const AsyncValue.data(null);
      }

      // 인증 상태 변경 리스너 (중복 방지)
      _supabase.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;

        final session = data.session;
        if (session != null) {
          state = AsyncValue.data(UserModel.fromSupabaseUser(session.user));
        } else {
          state = const AsyncValue.data(null);
        }
      });
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!mounted) return;

    try {
      state = const AsyncValue.loading();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null) {
        if (response.user!.emailConfirmedAt == null) {
          throw Exception('이메일 인증이 필요합니다. 이메일을 확인해주세요.');
        }

        state = AsyncValue.data(UserModel.fromSupabaseUser(response.user!));
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    if (!mounted) return;

    try {
      state = const AsyncValue.loading();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (!mounted) return;

      if (response.user != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(response.user!));
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
      rethrow;
    }
  }

  /// 방법 A: Supabase의 OAuth 흐름으로 Kakao 로그인 수행
  /// - 모바일(iOS/Android)에서는 deep link (앱 스킴) 리다이렉트 필요
  /// - 웹에서는 Supabase가 제공하는 콜백을 사용 (redirectTo: null)
  Future<void> signInWithKakao() async {
    if (!mounted) return;

    try {
      state = const AsyncValue.loading();

      if (kIsWeb) {
        // 웹: Supabase가 제공하는 콜백(https://<project>.supabase.co/auth/v1/callback)을 사용
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.kakao,
          // redirectTo null이면 Supabase의 콜백 사용 (웹)
          redirectTo: null,
          // authScreenLaunchMode 옵션은 supabase_flutter 버전에 따라 사용법이 다름.
        );
      } else {
        // 모바일: 앱으로 돌아올 수 있는 스킴을 redirectTo로 지정
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.kakao,
          redirectTo: kRedirectUriAndroidIos,
        );
      }

      // 로그인은 브라우저/카카오 앱으로 이동 -> 리다이렉트 후 Supabase SDK가 세션을 설정합니다.
      // _init()의 onAuthStateChange 리스너가 세션 변화를 받아 state를 갱신합니다.
      //
      // 여기서는 곧바로 성공을 가정하지 말고 리다이렉트 후 리스너가 처리하도록 합니다.
    } catch (e) {
      debugPrint('Kakao OAuth login error: $e');
      if (mounted) {
        state = AsyncValue.error('카카오 로그인 중 오류가 발생했습니다: ${e.toString()}', StackTrace.current);
      }
      rethrow;
    }
  }

  String _formatKakaoError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('cancelled') || errorString.contains('canceled')) {
      return '로그인이 취소되었습니다.';
    } else if (errorString.contains('network')) {
      return '네트워크 연결을 확인해주세요.';
    } else {
      return '카카오 로그인 중 오류가 발생했습니다: ${error.toString()}';
    }
  }

  Future<void> signOut() async {
    try {
      // Supabase 로그아웃
      await _supabase.auth.signOut();

      // (선택) 카카오 측 세션 정리: SDK의 logout/unlink는 네이티브 카카오 토큰을 지웁니다.
      try {
        await UserApi.instance.logout();
      } catch (e) {
        debugPrint('Kakao logout (SDK) error (continuing): $e');
      }

      if (mounted) {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthNotifier(supabase);
});

// Helper providers
final userProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.value;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  return user != null;
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});
