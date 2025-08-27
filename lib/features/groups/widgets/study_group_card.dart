import 'dart:math';
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // Matches React's borderRadius: 3 (~12px)
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 1, // Matches React's boxShadow: 0 1px 3px
        child: Padding(
          padding: const EdgeInsets.all(16), // Matches React's p: 3 (~24px, adjusted to 16 for Flutter's denser pixels)
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320), // Slightly increased to accommodate content
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (unchanged as per request)
                  Row(
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
                      const Spacer(),
                      Text(
                        studyGroup.formattedCreatedAt,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16), // Matches React's mb: 2 (~16px)

                  // Title
                  Text(
                    studyGroup.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17.6, // Matches React's 1.1rem
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 24), // Matches React's mb: 3 (~24px)

                  // Description
                  if ((studyGroup.description ?? '').isNotEmpty)
                    Text(
                      studyGroup.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 14, // Matches React's body2 (~14px)
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16), // Matches React's mb: 2 (~16px)

                  // Details (leader, schedule, location)
                  Column(
                    children: [
                      _buildDetailRow(Icons.person, '리더: ${studyGroup.leader}', theme),
                      const SizedBox(height: 8), // Matches React's spacing: 1 (~8px)
                      _buildDetailRow(Icons.access_time, studyGroup.schedule, theme),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.location_on, studyGroup.location, theme),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const SizedBox(height: 24),

                  // Footer: Participants + Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: studyGroup.participants.length > 4
                                ? 120.0
                                : min(studyGroup.participants.length * 24.0, 120.0),
                            height: 28, // Matches React's height: 28px
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (int i = 0; i < studyGroup.participants.length && i < 4; i++)
                                  Positioned(
                                    left: i * 22.0, // Adjusted for overlap (React's spacing: -0.5)
                                    child: CircleAvatar(
                                      radius: 14, // Matches React's width/height: 28px
                                      backgroundColor: _getAvatarColor(i),
                                      child: Text(
                                        _initials(studyGroup.participants[i]),
                                        style: const TextStyle(
                                          fontSize: 12, // Matches React's 0.75rem
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (studyGroup.participants.length > 4)
                                  Positioned(
                                    left: 4 * 22.0,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.grey[400],
                                      child: Text(
                                        '+${studyGroup.participants.length - 4}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11.2, // Matches React's 0.7rem
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14, // Matches React's body2
                              color: theme.textTheme.bodySmall?.color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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
      case '어학':
        return const Color(0xFF10b981);
      default:
        return Colors.grey;
    }
  }

  Color _getAvatarColor(int index) {
    const colors = [
      Color(0xFF8b5cf6),
      Color(0xFF3b82f6),
      Color(0xFF10b981),
      Color(0xFFf59e0b),
    ];
    return colors[index % colors.length];
  }

  Widget _buildDetailRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14, // Matches React's body2
              color: theme.textTheme.bodySmall?.color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}