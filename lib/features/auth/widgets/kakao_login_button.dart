import 'package:flutter/material.dart';

class KakaoLoginButton extends StatefulWidget {
  const KakaoLoginButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.text,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text;

  @override
  State<KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<KakaoLoginButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonText = widget.text ?? '카카오톡으로 3초만에 로그인';

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: ElevatedButton(
          onPressed: widget.isLoading ? null : () async {
            if (widget.onPressed != null) {
              try {
                widget.onPressed!();
              } catch (e) {
                debugPrint('Kakao button press error: $e');
                // 에러가 발생해도 UI는 정상적으로 복원
                if (mounted) {
                  setState(() => _isPressed = false);
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isPressed
                ? const Color(0xFFe6cc00)
                : const Color(0xFFfee500),
            foregroundColor: const Color(0xFF191919),
            elevation: _isPressed ? 1 : 2,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
          ),
          child: widget.isLoading
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
              Flexible(
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}