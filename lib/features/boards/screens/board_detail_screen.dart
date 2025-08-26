import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../shared/widgets/user_avatar.dart';


// Mock data provider (실제 앱에서는 API 호출로 대체)
final postDetailProvider = StateProvider.family<PostModel?, String>((ref, id) {
  // Mock data
  final mockUser1 = UserModel(
    id: 'user-1',
    email: 'minsu.kim@example.com',
    name: '김민수',
    studentId: '202312345',
  );

  final mockUser2 = UserModel(
    id: 'user-2',
    email: 'seoyeon.park@example.com',
    name: '박서연',
    studentId: '202254321',
  );

  final mockComments = [
    CommentModel(
      id: 'c1',
      content: '저도 처음엔 그랬어요. 시간이 지나면 괜찮아질 거예요! 동아리에 가입해보는 건 어떨까요?',
      author: mockUser2,
      createdAt: DateTime(2024, 7, 20, 10, 30, 0),
      likes: 3,
      isAnonymous: true,
      replies: [
        CommentModel(
          id: 'r1',
          content: '동아리 추천 감사해요! 어떤 동아리가 좋을까요?',
          author: mockUser1,
          createdAt: DateTime(2024, 7, 20, 11, 0, 0),
          likes: 1,
          parentId: 'c1',
        ),
      ],
    ),
    CommentModel(
      id: 'c2',
      content: '시간이 약입니다. 너무 조급해하지 마세요.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 20, 11, 0, 0),
      likes: 1,
    ),
  ];

  if (id == '1') {
    return PostModel(
      id: '1',
      title: '새 학기 적응이 어려워요',
      content: '기숙사에 처음 들어와서 새로운 환경에 적응하기가 힘들어요. 룸메이트와도 어색하고, 수업도 어렵고, 친구 사귀는 것도 쉽지 않네요. 다들 어떻게 적응하셨나요? 조언 부탁드립니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 20, 10, 0, 0),
      updatedAt: DateTime(2024, 7, 20, 10, 0, 0),
      category: '고민 상담',
      likes: 12,
      views: 80,
      comments: mockComments,
      tags: ['새학기', '적응', '룸메이트'],
      images: [
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',
        'https://os.catdogeats.shop/images/cat_in_box.jpg',

      ],
      isAnonymous: true,
      bookmarkCount: 4,
    );
  }
  return null;
});

final likedProvider = StateProvider<bool>((ref) => false);
final bookmarkedProvider = StateProvider<bool>((ref) => false);
final commentTextProvider = StateProvider<String>((ref) => '');
final isAnonymousCommentProvider = StateProvider<bool>((ref) => false);
final replyToCommentProvider = StateProvider<String?>((ref) => null);

class BoardDetailScreen extends ConsumerWidget {
  const BoardDetailScreen({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postDetailProvider(id));
    final user = ref.watch(userProvider);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('게시글 상세'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('게시글을 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  title: const Text('게시글 상세'),
                  floating: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showPostMenu(context),
                    ),
                  ],
                ),

                // Post Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _PostContent(post: post),
                  ),
                ),

                // Comments
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _CommentSection(post: post),
                  ),
                ),

                // Bottom padding for comment input
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: user != null ? _CommentInput(postId: post.id) : null,
    );
  }

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('공유하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 공유 기능 구현
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하기'),
        content: const Text('이 게시글을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다.')),
              );
            },
            child: const Text('신고'),
          ),
        ],
      ),
    );
  }
}

class _PostContent extends ConsumerWidget {
  const _PostContent({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liked = ref.watch(likedProvider);
    final bookmarked = ref.watch(bookmarkedProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(post.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    post.category,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(post.createdAt, locale: 'ko'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              post.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Author
            Row(
              children: [
                UserAvatar(
                  avatarUrl: post.author.avatarUrl,
                  displayName: post.author.displayName,
                  isAnonymous: post.isAnonymous,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  post.isAnonymous ? '익명' : post.author.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Content
            Text(
              post.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.8,
              ),
            ),

            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Images
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post.images[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: post.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const Divider(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Like Button
                InkWell(
                  onTap: () => ref.read(likedProvider.notifier).state = !liked,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.likes.toString(),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // Comment Button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.commentsCount.toString(),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),

                // Bookmark Button
                InkWell(
                  onTap: () => ref.read(bookmarkedProvider.notifier).state = !bookmarked,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(
                          bookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: bookmarked ? Colors.orange : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.bookmarkCount.toString(),
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '공지사항':
        return Colors.red;
      case '고민 상담':
        return Colors.purple;
      case '정보 공유':
        return Colors.blue;
      case '자유게시판':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _CommentSection extends ConsumerWidget {
  const _CommentSection({required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Text(
          '댓글 (${post.commentsCount})',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...post.comments.map((comment) {
          final isLast = comment == post.comments.last;
          return _CommentItem(comment: comment, isLast: isLast);
        }).toList(),
      ],
    );
  }
}

class _CommentItem extends ConsumerWidget {
  const _CommentItem({
    required this.comment,
    this.isLast = false,
  });

  final CommentModel comment;
  final bool isLast;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final replyToComment = ref.watch(replyToCommentProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Main Comment
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    avatarUrl: comment.author.avatarUrl,
                    displayName: comment.author.displayName,
                    isAnonymous: comment.isAnonymous,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.isAnonymous ? '익명' : comment.author.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 16),
                              onPressed: () => _showCommentMenu(context, comment),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.content,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              timeago.format(comment.createdAt, locale: 'ko'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                ref.read(replyToCommentProvider.notifier).state =
                                replyToComment == comment.id ? null : comment.id;
                              },
                              icon: const Icon(Icons.reply, size: 14),
                              label: Text(
                                replyToComment == comment.id ? '취소' : '답글',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Replies
              if (comment.replies.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 44, top: 8),
                  child: Column(
                    children: comment.replies.map((reply) => _ReplyItem(reply: reply)).toList(),
                  ),
                ),
            ],
          ),
        ),

        // isLast 플래그에 따라 Divider 출력
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  void _showCommentMenu(BuildContext context, CommentModel comment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 댓글 신고 기능
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_outlined),
              title: const Text('쪽지 보내기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 쪽지 보내기 기능
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyItem extends StatelessWidget {
  const _ReplyItem({required this.reply});

  final CommentModel reply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            avatarUrl: reply.author.avatarUrl,
            displayName: reply.author.displayName,
            isAnonymous: reply.isAnonymous,
            size: 28,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      reply.isAnonymous ? '익명' : reply.author.displayName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 14),
                      onPressed: () => _showReplyMenu(context, reply),
                    ),
                  ],
                ),
                Text(
                  reply.content,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(reply.createdAt, locale: 'ko'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReplyMenu(BuildContext context, CommentModel reply) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: const Text('신고하기'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 대댓글 신고 기능
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentInput extends ConsumerWidget {
  const _CommentInput({required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentText = ref.watch(commentTextProvider);
    final isAnonymous = ref.watch(isAnonymousCommentProvider);
    final replyToComment = ref.watch(replyToCommentProvider);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewPadding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyToComment != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 16),
                  const SizedBox(width: 8),
                  const Text('답글 작성 중...', style: TextStyle(fontSize: 12)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => ref.read(replyToCommentProvider.notifier).state = null,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => ref.read(commentTextProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: replyToComment != null ? '답글을 입력하세요...' : '댓글을 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isAnonymous,
                          onChanged: (value) => ref.read(isAnonymousCommentProvider.notifier).state = value ?? false,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text('익명', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: commentText.trim().isNotEmpty ? () => _submitComment(context, ref) : null,
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: commentText.trim().isNotEmpty
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.3),
                  foregroundColor: commentText.trim().isNotEmpty
                      ? Colors.white
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(BuildContext context, WidgetRef ref) {
    final commentText = ref.read(commentTextProvider);
    final isAnonymous = ref.read(isAnonymousCommentProvider);
    final replyToComment = ref.read(replyToCommentProvider);

    if (commentText.trim().isEmpty) return;

    // TODO: API 호출로 댓글 제출
    print('댓글 제출: $commentText, 익명: $isAnonymous, 답글: $replyToComment');

    // Reset form
    ref.read(commentTextProvider.notifier).state = '';
    ref.read(isAnonymousCommentProvider.notifier).state = false;
    ref.read(replyToCommentProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글이 등록되었습니다.')),
    );
  }
}