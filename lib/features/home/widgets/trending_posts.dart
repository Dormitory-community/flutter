import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/user_model.dart';
import '../../shared/widgets/post_card.dart';

class TrendingPosts extends StatelessWidget {
  const TrendingPosts({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - 실제 앱에서는 provider나 repository에서 가져올 데이터
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

    final mockPosts = [
      PostListModel(
        id: '1',
        title: '기숙사 생활 꿀팁 공유해요!',
        content: '기숙사에서 1년 넘게 살면서 터득한 생활 꿀팁들을 공유합니다. 세탁실 이용 시간대, 공부하기 좋은 장소, 야식 주문 꿀팁 등등...',
        author: mockUser1,
        createdAt: DateTime(2024, 7, 20, 10, 0, 0),
        updatedAt: DateTime(2024, 7, 20, 10, 0, 0),
        category: '일상',
        likes: 24,
        tags: ['꿀팁', '생활정보', '기숙사'],
        views: 150,
        commentsCount: 3,
      ),
      PostListModel(
        id: '2',
        title: '오늘 점심 뭐 먹지? 추천 받아요!',
        content: '학교 근처에서 점심 먹을 곳 추천해주세요! 한식, 양식, 일식 다 좋아요. 혼밥하기 좋은 곳도 환영입니다!',
        author: mockUser2,
        createdAt: DateTime(2024, 7, 19, 12, 0, 0),
        updatedAt: DateTime(2024, 7, 19, 12, 0, 0),
        category: '일상',
        likes: 18,
        tags: ['점심', '맛집', '추천'],
        views: 100,
        commentsCount: 4,
      ),
    ];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '실시간 인기 글',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Posts List
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: mockPosts.map((post) {
                return PostCard(
                  post: post,
                  onTap: () {
                    context.push(
                      AppRoutes.boardDetail.replaceAll(':id', post.id),
                    );
                  },
                  showCategory: true,
                  dense: true,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}