import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class ShareMenu extends StatelessWidget {
  final String? url;
  final String title;
  final String description;

  const ShareMenu({
    super.key,
    this.url,
    this.title = '이 스터디 그룹을 확인해보세요!',
    this.description = '함께 공부하고 성장해요!',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.share),
      tooltip: '공유하기',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'native_share',
          child: ListTile(
            leading: Icon(Icons.share),
            title: Text('공유하기'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'copy_link',
          child: ListTile(
            leading: Icon(Icons.content_copy),
            title: Text('링크 복사'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem<String>(
          value: 'kakao_share',
          child: ListTile(
            leading: Icon(Icons.chat_bubble),
            title: Text('카카오톡 공유'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'native_share':
            _handleNativeShare(context);
            break;
          case 'copy_link':
            _handleCopyLink(context);
            break;
          case 'kakao_share':
            _handleKakaoShare(context);
            break;
        }
      },
    );
  }

  String get _currentUrl {
    // Flutter에서는 현재 URL을 직접 가져올 수 없으므로
    // url이 제공되지 않으면 기본값을 사용
    return url ?? 'https://livinglogos.app';
  }

  Future<void> _handleNativeShare(BuildContext context) async {
    try {
      await Share.share(
        '$title\n\n$description\n\n$_currentUrl',
        subject: title,
      );
    } catch (e) {
      _showSnackBar(context, '공유에 실패했습니다.', isError: true);
    }
  }

  Future<void> _handleCopyLink(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: _currentUrl));
      _showSnackBar(context, 'URL이 복사되었습니다!');
    } catch (e) {
      _showSnackBar(context, 'URL 복사에 실패했습니다.', isError: true);
    }
  }

  Future<void> _handleKakaoShare(BuildContext context) async {
    try {
      // 카카오톡 설치 여부 확인
      bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (!isKakaoTalkSharingAvailable) {
        _showSnackBar(context, '카카오톡이 설치되지 않았습니다.', isError: true);
        return;
      }

      // 텍스트 템플릿으로 공유
      TextTemplate template = TextTemplate(
        text: '$title\n\n$description',
        link: Link(
          webUrl: Uri.parse(_currentUrl),
          mobileWebUrl: Uri.parse(_currentUrl),
        ),
      );

      Uri uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);

      _showSnackBar(context, '카카오톡으로 공유했습니다!');
    } catch (error) {
      _showSnackBar(context, '카카오톡 공유에 실패했습니다.', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}