import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/router/app_router.dart';
import '../../../core/models/user_model.dart';

// Group model
class GroupModel {
  final String id;
  final String title;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final int likes;
  final int views;
  final List<String> tags;
  final int participantCount;
  final int maxParticipants;
  final DateTime? deadline;
  final String status; // recruiting, full, closed

  GroupModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.likes = 0,
    this.views = 0,
    this.tags = const [],
    required this.participantCount,
    required this.maxParticipants,
    this.deadline,
    this.status = 'recruiting',
  });

  String get excerpt {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  bool get isRecruiting => status == 'recruiting';
  bool get isFull => participantCount >= maxParticipants;
  Color get statusColor {
    switch (status) {
      case 'recruiting':
        return Colors.green;
      case 'full':
        return Colors.orange;
      case 'closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'recruiting':
        return '모집중';
      case 'full':
        return '모집완료';
      case 'closed':
        return '모집마감';
      default:
        return '알수없음';
    }
  }
}

// Mock data provider
final groupsProvider = StateProvider<List<GroupModel>>((ref) {
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
    GroupModel(
      id: '1',
      title: '알고리즘 스터디 그룹 모집',
      content: '백준, 프로그래머스 문제를 함께 풀 스터디 그룹을 모집합니다. 주 3회, 평일 저녁 시간대로 진행합니다.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 20, 14, 0, 0),
      updatedAt: DateTime(2024, 7, 20, 14, 0, 0),
      category: '스터디',
      likes: 15,
      tags: ['알고리즘', '코딩테스트', '백준'],
      views: 89,
      participantCount: 3,
      maxParticipants: 6,
      deadline: DateTime(2024, 7, 25),
      status: 'recruiting',
    ),
    GroupModel(
      id: '2',
      title: '영어 회화 모임',
      content: '원어민과 함께하는 영어 회화 모임입니다. 초급자도 환영합니다!',
      author: mockUser2,
      createdAt: DateTime(2024, 7, 19, 16, 30, 0),
      updatedAt: DateTime(2024, 7, 19, 16, 30, 0),
      category: '언어',
      likes: 22,
      tags: ['영어', '회화', '원어민'],
      views: 134,
      participantCount: 8,
      maxParticipants: 8,
      deadline: DateTime(2024, 7, 22),
      status: 'full',
    ),
    GroupModel(
      id: '3',
      title: '독서 모임 멤버 모집',
      content: '한 달에 한 권씩 책을 읽고 토론하는 독서 모임입니다. 다양한 장르의 책을 읽어보아요.',
      author: mockUser1,
      createdAt: DateTime(2024, 7, 18, 20, 15, 0),
      updatedAt: DateTime(2024, 7, 18, 20, 15, 0),
      category: '취미',
      likes: 18,
      tags: ['독서', '토론', '모임'],
      views: 67,
      participantCount: 2,
      maxParticipants: 10,
      deadline: DateTime(2024, 7, 30),
      status: 'recruiting',
    ),
  ];
});

final selectedGroupCategoryProvider = StateProvider<String>((ref) => '전체');

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider);
    final selectedCategory = ref.watch(selectedGroupCategoryProvider);

    final categories = ['전체', '스터디', '취미', '운동', '언어', '기타'];

    final filteredGroups = selectedCategory == '전체'
        ? groups
        : groups.where((group) => group.category == selectedCategory).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // Category Filter
          Container(
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
                      ref.read(selectedGroupCategoryProvider.notifier).state = category;
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
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

          // Groups List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Refresh groups from API
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredGroups.length,
                itemBuilder: (context, index) {
                  final group = filteredGroups[index];
                  return _GroupCard(
                    group: group,
                    onTap: () {
                      context.push(
                        AppRoutes.groupDetail.replaceAll(':id', group.id),
                      );
                    },
                    showCategory: selectedCategory == '전체',
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.groupWrite);
        },
        icon: const Icon(Icons.group_add),
        label: const Text('그룹 만들기'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    this.onTap,
    this.showCategory = false,
  });

  final GroupModel group;
  final VoidCallback? onTap;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Author Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      group.author.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Author Name and Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.author.displayName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          timeago.format(group.createdAt, locale: 'ko'),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: group.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: group.statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      group.statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: group.statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Category Chip (if showCategory is true)
              if (showCategory) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    group.category,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Title
              Text(
                group.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // Content Excerpt
              Text(
                group.excerpt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Tags (if available)
              if (group.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: group.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),

              // Footer Row
              Row(
                children: [
                  // Participants
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.participantCount}/${group.maxParticipants}명',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Likes
                  Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    group.likes.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Views
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    group.views.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const Spacer(),

                  // Deadline (if available)
                  if (group.deadline != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(group.deadline!, locale: 'ko'),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}