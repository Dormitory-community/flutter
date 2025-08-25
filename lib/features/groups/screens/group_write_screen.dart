import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class GroupWriteScreen extends StatefulWidget {
  const GroupWriteScreen({super.key});

  @override
  State<GroupWriteScreen> createState() => _GroupWriteScreenState();
}

class _GroupWriteScreenState extends State<GroupWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();

  String _selectedCategory = '';
  int _maxParticipants = 6;
  List<String> _tags = [];

  final List<String> _categories = [
    '학습',
    '어학',
    '취미',
    '운동',
    '공모전',
    '자격증',
    'IT/코딩'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scheduleController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 폼 데이터 처리
      final formData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'category': _selectedCategory,
        'schedule': _scheduleController.text,
        'location': _locationController.text,
        'maxParticipants': _maxParticipants,
        'tags': _tags,
      };

      print(formData);

      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모임이 생성되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );

      // 그룹 목록으로 이동
      context.go(AppRoutes.groups);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('모임 게시글 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.groups),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 헤더 카드
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8b5cf6), Color(0xFF3b82f6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '모임 게시글 작성',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '함께 활동할 모임을 만들어보세요.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 폼 카드
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 선택
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '카테고리',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory.isEmpty ? null : _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '카테고리를 선택해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 제목
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '제목',
                          hintText: '예: TOEIC 900점 목표 스터디',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 내용
                      TextFormField(
                        controller: _contentController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          labelText: '내용',
                          hintText: '모임에 대한 자세한 설명을 작성해주세요...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '내용을 입력해주세요';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // 태그 섹션
                      const Text(
                        '태그 추가',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 태그 표시
                      if (_tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _tags.map((tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: Colors.grey[200],
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // 태그 입력
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: const InputDecoration(
                                hintText: '태그를 입력하고 Enter를 누르세요',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addTag,
                            child: const Text('추가'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 모임 상세 정보
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            // 모임 일정
                            TextFormField(
                              controller: _scheduleController,
                              decoration: const InputDecoration(
                                labelText: '모임 일정',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.schedule),
                              ),
                              readOnly: true,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      _scheduleController.text =
                                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                                    });
                                  }
                                }
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '모임 일정을 선택해주세요';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 모임 장소
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: '모임 장소',
                                hintText: '예: 스터디룸 A, 온라인 (디스코드)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '모임 장소를 입력해주세요';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // 최대 참여 인원
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: '최대 참여 인원',
                                hintText: '6',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue: _maxParticipants.toString(),
                              onChanged: (value) {
                                setState(() {
                                  _maxParticipants = int.tryParse(value) ?? 6;
                                });
                              },
                              validator: (value) {
                                final num = int.tryParse(value ?? '');
                                if (num == null || num < 2 || num > 20) {
                                  return '2~20 사이의 숫자를 입력해주세요';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 첨부 파일 버튼
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // 사진 첨부 로직
                            },
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('사진 첨부'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              // 파일 첨부 로직
                            },
                            icon: const Icon(Icons.attach_file),
                            label: const Text('파일 첨부'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 제출 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8b5cf6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            '모임 생성 완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}