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

  void _init() {
    // 초기 세션 확인
    final session = _supabase.auth.currentSession;
    if (session != null) {
      state = AsyncValue.data(UserModel.fromSupabaseUser(session.user));
    } else {
      state = const AsyncValue.data(null);
    }

    // 인증 상태 변경 리스너
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(session.user));
      } else {
        state = const AsyncValue.data(null);
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = const AsyncValue.loading();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(response.user!));
      } else {
        throw Exception('로그인에 실패했습니다.');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String fullName) async {
    try {
      state = const AsyncValue.loading();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(response.user!));
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signInWithKakao() async {
    try {
      state = const AsyncValue.loading();

      // 카카오 로그인
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // Supabase에 카카오 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
        accessToken: token.accessToken,
      );

      if (response.user != null) {
        state = AsyncValue.data(UserModel.fromSupabaseUser(response.user!));
      } else {
        throw Exception('카카오 로그인에 실패했습니다.');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // 카카오 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그아웃 실패해도 계속 진행
      }

      // Supabase 로그아웃
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
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