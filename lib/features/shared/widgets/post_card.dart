import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/post_models.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.showCategory = false,
    this.dense = false,
  });

  final PostListModel post;
  final VoidCallback? onTap;
  final bool showCategory;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: dense
          ? const EdgeInsets.only(bottom: 12)
          : const EdgeInsets.only(bottom: 16),
      elevation: dense ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(dense ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Author Avatar
                  CircleAvatar(
                    radius: dense ? 14 : 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      post.author.initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: dense ? 11 : 12,
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
                          post.isAnonymous ? '익명' : post.author.displayName,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: dense ? 12 : 13,
                          ),
                        ),
                        Text(
                          timeago.format(post.createdAt, locale: 'ko'),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: dense ? 10 : 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Chip (if showCategory is true)
                  if (showCategory) ...[
                    const SizedBox(width: 8),
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
                        post.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: dense ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: dense ? 8 : 12),

              // Title
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: dense ? 14 : 15,
                ),
                maxLines: dense ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: dense ? 4 : 6),

              // Content Excerpt
              Text(
                post.excerpt,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: dense ? 12 : 13,
                  height: 1.4,
                ),
                maxLines: dense ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Tags (if available)
              if (post.tags.isNotEmpty) ...[
                SizedBox(height: dense ? 6 : 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: post.tags.take(3).map((tag) {
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
                          fontSize: dense ? 9 : 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: dense ? 8 : 12),

              // Footer Row
              Row(
                children: [
                  // Likes
                  Icon(
                    Icons.favorite_border,
                    size: dense ? 14 : 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.likes.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: dense ? 11 : 12,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comments
                  Icon(
                    Icons.chat_bubble_outline,
                    size: dense ? 14 : 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.commentsCount.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: dense ? 11 : 12,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Views
                  Icon(
                    Icons.visibility,
                    size: dense ? 14 : 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post.views.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: dense ? 11 : 12,
                    ),
                  ),

                  const Spacer(),

                  // Thumbnail Image (if available)
                  if (post.thumbnailImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: dense ? 40 : 50,
                        height: dense ? 40 : 50,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: const Icon(Icons.image, size: 20),
                        // 실제 구현에서는 CachedNetworkImage 사용
                        // child: CachedNetworkImage(
                        //   imageUrl: post.thumbnailImage!,
                        //   fit: BoxFit.cover,
                        //   placeholder: (context, url) => Container(
                        //     color: Theme.of(context).colorScheme.surfaceVariant,
                        //     child: const Center(
                        //       child: CircularProgressIndicator(strokeWidth: 2),
                        //     ),
                        //   ),
                        //   errorWidget: (context, url, error) => Container(
                        //     color: Theme.of(context).colorScheme.surfaceVariant,
                        //     child: const Icon(Icons.broken_image),
                        //   ),
                        // ),
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