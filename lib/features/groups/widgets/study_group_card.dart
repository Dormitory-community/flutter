import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../../core/models/study_group_model.dart';

class StudyGroupCard extends StatelessWidget {
  final StudyGroupModel studyGroup;
  final VoidCallback? onTap;

  const StudyGroupCard({
    super.key,
    required this.studyGroup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDarkMode ? 0 : 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? theme.colorScheme.outline
              : theme.colorScheme.outline.withOpacity(0.5), // Lighter border in light mode
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header with category and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      studyGroup.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: _getCategoryColor(studyGroup.category),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    studyGroup.formattedCreatedAt,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Title
              Text(
                studyGroup.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 🔹 Description
              Expanded(
                child: Text(
                  studyGroup.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Details
              Column(
                children: [
                  _buildDetailRow(Icons.person, '리더: ${studyGroup.leader}', theme),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.access_time, studyGroup.schedule, theme),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.location_on, studyGroup.location, theme),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Tags
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: studyGroup.tags.map((tag) => Chip(
                  label: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.brightness == Brightness.dark
                          ? theme.colorScheme.onSurface
                          : Colors.grey[700],
                    ),
                  ),
                  backgroundColor: theme.brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[100],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),

              const SizedBox(height: 20),

              // 🔹 Footer with participants and join button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // 🧑 Participant avatars
                      SizedBox(
                        width: studyGroup.participants.length > 4
                            ? 140
                            : studyGroup.participants.length * 28.0,
                        height: 32,
                        child: Stack(
                          children: [
                            ...studyGroup.participants
                                .take(4)
                                .mapIndexed((index, participant) {
                              return Positioned(
                                left: index * 20.0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getAvatarColor(index),
                                  child: Text(
                                    participant,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            if (studyGroup.participants.length > 4)
                              Positioned(
                                left: 80,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[400],
                                  child: Text(
                                    '+${studyGroup.participants.length - 4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${studyGroup.participants.length}/${studyGroup.maxParticipants}명',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Handle join action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8b5cf6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      '참여하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  /// 🔹 공통 UI 빌더
  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 🔹 카테고리 색상
  Color _getCategoryColor(String category) {
    switch (category) {
      case '어학':
        return const Color(0xFF10b981);
      case '학습':
        return const Color(0xFF3b82f6);
      case '취미':
        return const Color(0xFFf59e0b);
      case '운동':
        return const Color(0xFFef4444);
      case 'IT/코딩':
        return const Color(0xFF8b5cf6);
      case '공모전':
        return const Color(0xFF06b6d4);
      case '자격증':
        return const Color(0xFF84cc16);
      default:
        return Colors.grey;
    }
  }

  /// 🔹 아바타 색상
  Color _getAvatarColor(int index) {
    const colors = [
      Color(0xFF8b5cf6),
      Color(0xFF3b82f6),
      Color(0xFF10b981),
      Color(0xFFf59e0b),
    ];
    return colors[index % colors.length];
  }
}