import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/share_menu.dart';

class GroupDetailScreen extends StatelessWidget {
  final String id;

  const GroupDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터 - 실제로는 id를 기반으로 데이터를 가져올 것
    final sampleGroups = {
      '1': {
        'id': 1,
        'title': 'React 스터디 그룹',
        'category': '학습',
        'description': 'React를 함께 공부하며 프로젝트를 진행하는 스터디 그룹입니다. 초보자도 환영합니다!',
        'fullDescription': '''React를 처음 시작하는 분들부터 중급자까지 함께 공부할 수 있는 스터디 그룹입니다.

매주 토요일 오후 2시에 모여서 React 공식 문서를 함께 읽고, 실습 프로젝트를 진행합니다.

현재 진행 중인 프로젝트:
- Todo 앱 만들기
- 날씨 앱 개발
- 개인 포트폴리오 사이트 제작

스터디 진행 방식:
1. 매주 정해진 분량의 React 문서 학습
2. 실습 과제 진행 및 코드 리뷰
3. 개인 프로젝트 진행 상황 공유
4. Q&A 시간

준비물: 노트북, 개발 환경 세팅''',
        'members': 8,
        'maxMembers': 12,
        'schedule': '매주 토요일 14:00',
        'location': '강남역 스터디카페',
        'organizer': {
          'name': '김개발',
          'avatar': '/placeholder.svg?height=40&width=40',
        },
        'tags': ['React', 'JavaScript', '프론트엔드', '초보환영'],
        'createdAt': '2024-01-15',
      },
      '2': {
        'id': 2,
        'title': '영어 회화 모임',
        'category': '어학',
        'description': '원어민과 함께하는 영어 회화 연습 모임입니다.',
        'fullDescription': '''원어민 강사와 함께하는 영어 회화 연습 모임입니다.

매주 수요일 저녁 7시에 모여서 다양한 주제로 영어 대화를 나눕니다.

모임 특징:
- 원어민 강사 1명과 한국인 참가자 6-8명
- 레벨별 그룹 구성 (초급, 중급, 고급)
- 매주 다른 주제로 토론 진행
- 발음 교정 및 표현 피드백 제공

주요 활동:
1. 아이스브레이킹 (10분)
2. 주제별 토론 (30분)
3. 롤플레이 활동 (15분)
4. 자유 대화 시간 (15분)

참가 조건: 기초 영어 회화 가능자''',
        'members': 6,
        'maxMembers': 8,
        'schedule': '매주 수요일 19:00',
        'location': '홍대 카페',
        'organizer': {
          'name': 'Sarah Kim',
          'avatar': '/placeholder.svg?height=40&width=40',
        },
        'tags': ['영어', '회화', '원어민', '토론'],
        'createdAt': '2024-01-20',
      },
    };

    final group = sampleGroups[id];

    if (group == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('그룹 상세보기'),
        ),
        body: const Center(
          child: Text('그룹을 찾을 수 없습니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 상세보기'),
        actions: [
          ShareMenu(
            url: 'https://livinglogos.app/groups/$id',
            title: '${group['title']} - 함께해요!',
            description: '${group['category']} | ${group['schedule']} | ${group['location']}',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그룹 헤더
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8b5cf6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['title']! as String,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Chip(
                                label: Text(group['category']! as String),
                                backgroundColor: const Color(0xFF8b5cf6),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                              ...(group['tags']! as List<String>).map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.grey[200],
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // 그룹 정보
                Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      '멤버 ${group['members']}/${group['maxMembers']}명',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.schedule,
                      group['schedule']! as String,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.location_on,
                      group['location']! as String,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // 모임장 정보
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF8b5cf6),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '모임장: ${(group['organizer']! as Map)['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${group['createdAt']} 개설',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // 상세 설명
                const Text(
                  '상세 설명',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  group['fullDescription']! as String,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                  ),
                ),

                const SizedBox(height: 32),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // 참여 신청 로직
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8b5cf6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          '참여 신청하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 문의하기 로직
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8b5cf6),
                          side: const BorderSide(color: Color(0xFF8b5cf6)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text(
                          '문의하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}