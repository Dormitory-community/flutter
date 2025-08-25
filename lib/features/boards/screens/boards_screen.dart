import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/models/post_models.dart';
import '../../../core/models/user_model.dart';
import '../../shared/widgets/post_card.dart';

// Mock data provider (실제 앱에서는 API 호출로 대체)
final postsProvider = StateProvider<List<PostListModel>>((ref) {
  final mockUser1 = UserModel(
    id: 'user-1',
    email: 'chulsoo.kim@example.com',
    name: '김철수',
    studentId: '202312345',
  );

  final mockUser2 = UserModel(
    id: 'user-2',
    email: 'younghee.lee@example.com',
    name: '이영희',
    studentId: '202254321',
  );

  return [
    PostListModel(
      id: '1',
      title: '기숙사 생활 꿀팁 공유해요!',
      content:
      '기숙사에서 1년 넘게 살면서 터득한 생활 꿀팁들을 공유합니다. 세탁실 이용 시간대, 공부하기 좋은 장소, 야식 주문 꿀팁 등등 알려줄수 있어요 저한테 쪽지 주시면 다양한 정보를 드르도록 하겠습니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 20, 10, 0, 0),
      updatedAt: DateTime(2024, 7, 20, 10, 0, 0),
      category: '자유게시판',
      likes: 24,
      tags: ['꿀팁', '생활정보', '기숙사'],
      views: 150,
      commentsCount: 3,
      thumbnailImage: "https://os.catdogeats.shop/images/cat_in_box.jpg",
    ),
    PostListModel(
      id: '2',
      title: '오늘 점심 뭐 먹지? 추천 받아요!',
      content:
      '학교 근처에서 점심 먹을 곳 추천해주세요! 한식, 양식, 일식 다 좋아요. 혼밥하기 좋은 곳도 환영입니다!',
      author: mockUser2,
      createdAt: DateTime(2024, 7, 19, 12, 0, 0),
      updatedAt: DateTime(2024, 7, 19, 12, 0, 0),
      category: '자유게시판',
      likes: 18,
      tags: ['점심', '맛집', '추천'],
      views: 100,
      commentsCount: 4,
    ),
    PostListModel(
      id: '3',
      title: '새 학기 스터디 그룹 모집',
      content:
      '새 학기를 맞아 함께 공부할 스터디 그룹을 모집합니다. 주 3회, 평일 저녁 시간대로 진행할 예정입니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 18, 15, 30, 0),
      updatedAt: DateTime(2024, 7, 18, 15, 30, 0),
      category: '정보 공유',
      likes: 32,
      tags: ['스터디', '그룹', '모집'],
      views: 89,
      commentsCount: 7,
    ),
    PostListModel(
      id: '4',
      title: '새 학기 스터디 그룹 모집',
      content:
      '새 학기를 맞아 함께 공부할 스터디 그룹을 모집합니다. 주 3회, 평일 저녁 시간대로 진행할 예정입니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 18, 15, 30, 0),
      updatedAt: DateTime(2024, 7, 18, 15, 30, 0),
      category: '정보 공유',
      likes: 32,
      tags: ['스터디', '그룹', '모집'],
      views: 89,
      commentsCount: 7,
    ),
    PostListModel(
      id: '5',
      title: '새 학기 스터디 그룹 모집',
      content:
      '새 학기를 맞아 함께 공부할 스터디 그룹을 모집합니다. 주 3회, 평일 저녁 시간대로 진행할 예정입니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 18, 15, 30, 0),
      updatedAt: DateTime(2024, 7, 18, 15, 30, 0),
      category: '정보 공유',
      likes: 32,
      tags: ['스터디', '그룹', '모집'],
      views: 89,
      commentsCount: 7,
    ),
    PostListModel(
      id: '6',
      title: '새 학기 스터디 그룹 모집',
      content:
      '새 학기를 맞아 함께 공부할 스터디 그룹을 모집합니다. 주 3회, 평일 저녁 시간대로 진행할 예정입니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 18, 15, 30, 0),
      updatedAt: DateTime(2024, 7, 18, 15, 30, 0),
      category: '정보 공유',
      likes: 32,
      tags: ['스터디', '그룹', '모집'],
      views: 89,
      commentsCount: 7,
    ),
  ];
});

final selectedCategoryProvider = StateProvider<String>((ref) => '전체');

class BoardsScreen extends ConsumerWidget {
  const BoardsScreen({super.key});

  static const double _maxContentWidth = 900; // 원하는 max width

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    final selectedCategory = ref.watch(selectedCategoryProvider);

    final categories = ['전체', '자유게시판', '정보 공유', '고민 상담'];

    final filteredPosts = selectedCategory == '전체'
        ? posts
        : posts.where((post) => post.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Category Filter (centered and constrained to max width)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref.read(selectedCategoryProvider.notifier).state = category;
                        },
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedColor: Theme.of(context).colorScheme.surface,   // 선택시에도 배경 변화 없음
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary // 선택 시 테두리 색
                              : Theme.of(context).colorScheme.outline, // 비선택 시 테두리 색
                          width: 1.2,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Posts List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Refresh posts from API
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];

                  // 각 카드 중앙 정렬 + 최대 너비 적용
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                      child: PostCard(
                        post: post,
                        onTap: () {
                          context.push(
                            AppRoutes.boardDetail.replaceAll(':id', post.id),
                          );
                        },
                        showCategory: selectedCategory == '전체',
                        dense: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 40,                // 버튼 높이
        // width 생략하면 내부 콘텐츠에 따라 결정
        child: FloatingActionButton.extended(
          onPressed: () => _showWriteOptions(context),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('글쓰기', style: TextStyle(fontSize: 12)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showWriteOptions(BuildContext context) {
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
            Text(
              '게시글 작성',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _WriteOptionTile(
              icon: Icons.chat_bubble_outline,
              title: '자유게시판',
              subtitle: '자유로운 소통과 일상 이야기',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.boardWrite.replaceAll(':type', 'free'));
              },
            ),
            const SizedBox(height: 12),
            _WriteOptionTile(
              icon: Icons.info_outline,
              title: '정보 공유',
              subtitle: '유용한 정보와 팁 공유',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.boardWrite.replaceAll(':type', 'info'));
              },
            ),
            const SizedBox(height: 12),
            _WriteOptionTile(
              icon: Icons.psychology_outlined,
              title: '고민 상담',
              subtitle: '고민과 조언을 나누는 공간',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.boardWrite.replaceAll(':type', 'counseling'));
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

class _WriteOptionTile extends StatelessWidget {
  const _WriteOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
