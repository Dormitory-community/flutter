// lib/core/utils/auth_utils.dart
import 'package:flutter/material.dart';

class AuthUtils {
  /// 이메일 유효성 검증
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// 비밀번호 강도 검증
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (password.length < 6) {
      return '비밀번호는 최소 6자 이상이어야 합니다';
    }
    return null;
  }

  /// 이메일 유효성 검증
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!isValidEmail(email)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  /// 이름 유효성 검증
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '이름을 입력해주세요';
    }
    if (name.trim().length < 2) {
      return '이름은 최소 2자 이상이어야 합니다';
    }
    return null;
  }

  /// 비밀번호 확인 검증
  static String? validatePasswordConfirm(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return '비밀번호 확인을 입력해주세요';
    }
    if (password != confirmPassword) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// 에러 메시지를 사용자 친화적인 메시지로 변환
  static String getErrorMessage(String error) {
    if (error.contains('User already registered') ||
        error.contains('already registered')) {
      return '이미 등록된 이메일입니다';
    } else if (error.contains('Password should be at least 6 characters')) {
      return '비밀번호는 6자 이상이어야 합니다';
    } else if (error.contains('Invalid email')) {
      return '올바른 이메일 형식을 입력해주세요';
    } else if (error.contains('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다';
    } else if (error.contains('Email not confirmed')) {
      return '이메일 인증이 완료되지 않았습니다. 이메일을 확인해주세요';
    } else if (error.contains('Too many requests')) {
      return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요';
    }
    return '요청 처리 중 오류가 발생했습니다. 다시 시도해주세요';
  }

  /// 성공 메시지 표시
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 에러 메시지 표시
  static void showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getErrorMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}