import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;    // 앞으로 이 필드를 통해 URL 받음
  final String? displayName;  // fallback initials 생성용 (옵션)
  final bool isAnonymous;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.avatarUrl,
    this.displayName,
    this.isAnonymous = false,
    this.size = 40,
    this.onTap,
  }) : super(key: key);

  String? _initials() {
    final name = displayName;
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials();

    Widget child;
    if (isAnonymous) {
      child = Icon(Icons.person_off, size: size * 0.5);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (c, u) => Center(
          child: SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (c, u, e) => _fallback(initials),
      );
    } else {
      child = _fallback(initials);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: Container(
          width: size,
          height: size,
          color: theme.colorScheme.surfaceVariant,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _fallback(String? initials) {
    if (initials != null) {
      return Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Icon(Icons.person, size: size * 0.5);
  }
}
