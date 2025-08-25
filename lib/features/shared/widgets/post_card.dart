import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/models/post_models.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onCategoryTap,
    this.showCategory = false,
    this.dense = false,
  });

  final PostListModel post;
  final VoidCallback? onTap;
  final VoidCallback? onCategoryTap; // 선택적: 카테고리 탭 콜백
  final bool showCategory;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: dense ? const EdgeInsets.only(bottom: 12) : const EdgeInsets.only(bottom: 16),
      elevation: dense ? 1 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(dense ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Title + Excerpt + Thumbnail row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        // Excerpt
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
                      ],
                    ),
                  ),

                  // Thumbnail on right when available
                  if (post.thumbnailImage != null && post.thumbnailImage!.isNotEmpty) ...[
                    SizedBox(width: dense ? 12 : 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: post.thumbnailImage!,
                        width: dense ? 60 : 80,
                        height: dense ? 60 : 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Tags (if available)
              if (post.tags.isNotEmpty) ...[
                SizedBox(height: dense ? 6 : 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: dense ? 9 : 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              SizedBox(height: dense ? 8 : 12),

              // Footer: left (likes, comments, views | date | name) & right (category)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side
                  Expanded(
                    child: Row(
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

                        const SizedBox(width: 8),

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

                        const SizedBox(width: 8),

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

                        // Separator
                        const SizedBox(width: 8),
                        Text(
                          '|',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: dense ? 11 : 12,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Date
                        Text(
                          timeago.format(post.createdAt, locale: 'ko'),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: dense ? 11 : 12,
                          ),
                        ),

                        // Separator
                        const SizedBox(width: 8),
                        Text(
                          '|',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: dense ? 11 : 12,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Author name
                        Flexible(
                          child: Text(
                            post.isAnonymous ? '익명' : post.author.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: dense ? 11 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: Category
                  if (showCategory)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
