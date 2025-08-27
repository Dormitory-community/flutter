import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/study_group_card.dart';
import '../../../core/models/study_group_model.dart';
import '../../../core/router/app_router.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  String _searchTerm = '';
  String _selectedCategory = '전체';
  int _currentPage = 1;
  final int _groupsPerPage = 6;

  final List<String> _categories = [
    '전체', '학습', '어학', '취미', '운동', 'IT/코딩', '공모전', '자격증'
  ];

  final List<StudyGroupModel> _mockStudyGroups = [
    StudyGroupModel(
      id: '1',
      title: 'TOEIC 스터디 모집',
      description: '토익 900점 목표로 함께 공부할 스터디원을 모집합니다.',
      category: '어학',
      leader: '김영어',
      schedule: '화, 목 19:00',
      location: '스터디룸 A',
      tags: ['토익', '영어', '자격증'],
      participants: ['A', 'B', 'C', 'D'],
      maxParticipants: 6,
      createdAt: DateTime(2024, 1, 15),
    ),
    StudyGroupModel(
      id: '2',
      title: '알고리즘 코딩테스트 준비',
      description: '백준, 프로그래머스 문제를 함께 풀며 코딩테스트를 준비해요.',
      category: '학습',
      leader: '박코딩',
      schedule: '월, 수, 금 20:00',
      location: '온라인 (디스코드)',
      tags: ['알고리즘', '코딩테스트', '프로그래밍'],
      participants: ['A', 'B', 'C', 'D', 'E', 'F'],
      maxParticipants: 8,
      createdAt: DateTime(2024, 1, 14),
    ),
    StudyGroupModel(
      id: '3',
      title: '독서 모임 - 자기계발서',
      description: '매월 자기계발서 한 권씩 읽고 토론하는 모임입니다.',
      category: '취미',
      leader: '이독서',
      schedule: '매주 일 14:00',
      location: '카페 북스',
      tags: ['독서', '자기계발', '토론'],
      participants: ['A', 'B', 'C'],
      maxParticipants: 5,
      createdAt: DateTime(2024, 1, 12),
    ),
    StudyGroupModel(
      id: '4',
      title: '헬스 운동 메이트',
      description: '주 3회 헬스장에서 함께 운동할 메이트를 구합니다.',
      category: '운동',
      leader: '최헬스',
      schedule: '월, 수, 금 18:00',
      location: '학교 헬스장',
      tags: ['헬스', '운동', '다이어트'],
      participants: ['A', 'B'],
      maxParticipants: 4,
      createdAt: DateTime(2024, 1, 10),
    ),
  ];

  List<StudyGroupModel> get _filteredGroups {
    return _mockStudyGroups.where((group) {
      final matchesCategory = _selectedCategory == '전체' || group.category == _selectedCategory;
      final matchesSearch = group.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          group.description.toLowerCase().contains(_searchTerm.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<StudyGroupModel> get _paginatedGroups {
    final filtered = _filteredGroups;
    final startIndex = (_currentPage - 1) * _groupsPerPage;
    final endIndex = (startIndex + _groupsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredGroups.length / _groupsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16),
          child: Column(
            children: [
              // Search + Create
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                          _currentPage = 1;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '스터디/모임 검색...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                    ),
                  ),
                  if (isLargeScreen) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.groupWrite),
                      icon: const Icon(Icons.add),
                      label: const Text('모임 만들기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8b5cf6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Categories
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _currentPage = 1;
                        });
                      },
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: const Color(0xFF8b5cf6),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Groups Grid
              Expanded(
                child: _paginatedGroups.isNotEmpty
                    ? GridView.builder(
                  itemCount: _paginatedGroups.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLargeScreen ? 2 : 1,
                    childAspectRatio: isLargeScreen ? 1.2 : 0.8,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemBuilder: (context, index) {
                    final group = _paginatedGroups[index];
                    return StudyGroupCard(
                      studyGroup: group,
                      onTap: () => context.go(AppRoutes.groupDetailPath(group.id)),
                    );
                  },
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups,
                        size: 64,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 16),
                      Text('모임이 없습니다', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        '선택한 카테고리나 검색어에 해당하는 모임이 없습니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // Pagination
              if (_totalPages > 1) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                        (index) {
                      final page = index + 1;
                      final isSelected = page == _currentPage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => setState(() => _currentPage = page),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF8b5cf6) : null,
                              borderRadius: BorderRadius.circular(8),
                              border: !isSelected ? Border.all(color: theme.dividerColor) : null,
                            ),
                            child: Center(
                              child: Text(
                                '$page',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !isLargeScreen
          ? SizedBox(
        height: 40,
        child: FloatingActionButton.extended(
          onPressed: () => context.go(AppRoutes.groupWrite),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('글쓰기', style: TextStyle(fontSize: 12)),
          backgroundColor: const Color(0xFF8b5cf6),
          foregroundColor: Colors.white,
        ),
      )
          : null,
    );
  }
}
