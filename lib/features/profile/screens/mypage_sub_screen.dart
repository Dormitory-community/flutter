// mypage_sub_screen_fixed.dart
// 전체 코드(내 게시글 / 내 댓글 / 스크랩 / 개인정보 및 보안) -
// 모든 _build* 메서드에서 BuildContext를 파라미터로 받아 사용하도록 수정함.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/post_model.dart';
import '../../../features/shared/widgets/post_card.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/auth_provider.dart';

// Posts Screen (내 게시글)
class PostsScreen extends ConsumerWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    // Mock data - 실제로는 provider에서 가져와야 함
    final myPosts = _getMockPosts();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('내 게시글'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 800 : double.infinity,
        ),
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
        child: myPosts.isEmpty ? _buildEmptyState(context) : _buildPostsList(myPosts, context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '작성한 게시글이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 게시글을 작성해보세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<PostListModel> posts, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          showCategory: true,
          onTap: () {
            context.go(AppRoutes.boardDetailPath(posts[index].id));
          },
        );
      },
    );
  }

  List<PostListModel> _getMockPosts() {
    // Mock data
    final mockUser = UserModel(
      id: 'user-123',
      email: 'kim.gisuk@example.com',
      name: '김기숙',
    );

    return [
      PostListModel(
        id: '1',
        title: '기숙사 생활 꿀팁 공유해요!',
        content: '기숙사에서 1년 넘게 살면서 터득한 생활 꿀팁들을 공유합니다...',
        author: mockUser,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: '자유게시판',
        likes: 24,
        commentsCount: 8,
        tags: ['꿀팁', '생활정보', '기숙사'],
      ),
      PostListModel(
        id: '2',
        title: '새 학기 적응이 어려워요',
        content: '기숙사에 처음 들어와서 새로운 환경에 적응하기가 힘들어요...',
        author: mockUser,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        category: '고민상담',
        likes: 12,
        commentsCount: 5,
        isAnonymous: true,
        tags: ['새학기', '적응', '룸메이트'],
      ),
    ];
  }
}

// Comments Screen (내 댓글)
class CommentsScreen extends ConsumerWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final myComments = _getMockComments();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('내 댓글'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 800 : double.infinity,
        ),
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
        child: myComments.isEmpty ? _buildEmptyState(context) : _buildCommentsList(myComments, context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '작성한 댓글이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 게시글에 댓글을 남겨보세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<CommentModel> comments, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: comments.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // author.displayName이 없다면 fallback 처리
                  comment.author.displayName ?? comment.author.name ?? '익명',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(comment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<CommentModel> _getMockComments() {
    final mockUser = UserModel(
      id: 'user-123',
      email: 'kim.gisuk@example.com',
      name: '김기숙',
    );

    return [
      CommentModel(
        id: 'comment-1',
        content: '정말 유용한 정보네요! 감사합니다',
        author: mockUser,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 3,
      ),
      CommentModel(
        id: 'comment-2',
        content: '저도 처음엔 그랬어요. 시간이 지나면 괜찮아질 거예요! 동아리에 가입해보는 건 어떨까요?',
        author: mockUser,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 5,
      ),
    ];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}

// Bookmarks Screen (스크랩)
class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final bookmarkedPosts = _getMockBookmarks();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('스크랩'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
        child: bookmarkedPosts.isEmpty ? _buildEmptyState(context) : _buildBookmarksList(bookmarkedPosts, context),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            '스크랩한 게시글이 없습니다',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '게시글을 스크랩해보세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(List<PostListModel> posts, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(
          post: posts[index],
          showCategory: true,
          dense: true,
          onTap: () {
            // TODO: 게시글 상세로 이동
          },
        );
      },
    );
  }

  List<PostListModel> _getMockBookmarks() {
    final mockUser = UserModel(
      id: 'user-123',
      email: 'kim.gisuk@example.com',
      name: '김기숙',
    );

    return [
      PostListModel(
        id: '1',
        title: '기숙사 생활 꿀팁 공유해요!',
        content: '기숙사에서 1년 넘게 살면서 터득한 생활 꿀팁들을 공유합니다...',
        author: mockUser,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        category: '자유게시판',
        likes: 24,
        commentsCount: 8,
        tags: ['꿀팁', '생활정보', '기숙사'],
      ),
    ];
  }
}

// Privacy Screen (개인정보 및 보안)
class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  bool _showDeleteDialog = false;
  bool _showPasswordDialog = false;
  String _newPassword = '';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('개인정보 및 보안'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 800 : double.infinity,
          ),
          margin: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 계정 정보
              _buildAccountInfoCard(context, user),

              const SizedBox(height: 16),

              // 개인정보 및 권한
              _buildPrivacyCard(context),

              const SizedBox(height: 16),

              // 계정 관리
              _buildAccountManagementCard(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final accountInfo = [
      {'label': '이메일', 'value': user.email ?? ''},
      {'label': '로그인 방식', 'value': '이메일 로그인'},
      {'label': '마지막 로그인', 'value': DateTime.now().toString().substring(0, 16)},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '계정 정보',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...accountInfo.map((info) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    info['label']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    info['value']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(BuildContext context) {
    final theme = Theme.of(context);
    final privacyItems = [
      {
        'title': '개인정보 처리방침',
        'description': '개인정보 수집 및 이용에 대한 정책',
        'icon': Icons.description,
        'onTap': () => _showSnackBar('개인정보 처리방침 페이지로 이동합니다.'),
      },
      {
        'title': '앱 내 권한 안내',
        'description': '위치, 카메라 등 앱 권한 설명',
        'icon': Icons.security,
        'onTap': () => _showSnackBar('앱 권한 안내 페이지로 이동합니다.'),
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  '개인정보 및 권한',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...privacyItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item['icon'] as IconData,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      item['title']! as String,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      item['description']! as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    onTap: item['onTap'] as VoidCallback,
                  ),
                  if (index < privacyItems.length - 1)
                    Divider(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountManagementCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  '계정 관리',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 비밀번호 변경
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '비밀번호 변경',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                '새로운 비밀번호로 업데이트합니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              onTap: () => _showPasswordChangeDialog(),
            ),

            Divider(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),

            // 회원 탈퇴
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '회원 탈퇴',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.error,
                ),
              ),
              subtitle: Text(
                '계정 및 모든 데이터가 영구적으로 삭제됩니다',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error.withOpacity(0.7),
                ),
              ),
              onTap: () => _showDeleteAccountDialog(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '새로운 비밀번호를 입력하세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              onChanged: (value) => setState(() => _newPassword = value),
              decoration: const InputDecoration(
                labelText: '새 비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _newPassword.isEmpty ? null : () => _handlePasswordChange(),
                  child: const Text('변경하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '회원 탈퇴',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '정말로 회원탈퇴를 하시겠습니까?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '계정 및 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDeleteAccount(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('탈퇴하기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePasswordChange() async {
    try {
      // TODO: 실제 비밀번호 변경 API 호출
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('비밀번호가 성공적으로 변경되었습니다.');
        setState(() => _newPassword = '');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('비밀번호 변경 중 오류가 발생했습니다.');
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    try {
      // TODO: 실제 계정 삭제 API 호출
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // 로그아웃 처리
        ref.read(authProvider.notifier).signOut();
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('계정 삭제 중 오류가 발생했습니다.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
