import 'package:flutter/material.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text, // 커스텀 텍스트를 위한 옵션
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text; // null이면 기본 로그인 텍스트 사용

  @override
  Widget build(BuildContext context) {
    final buttonText = text ?? '카카오톡으로 3초만에 로그인';

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFfee500),
          foregroundColor: const Color(0xFF191919),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF191919)),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kakao Logo
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF191919),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'K',
                  style: TextStyle(
                    color: Color(0xFFfee500),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}