import 'user_model.dart';

class PostModel {
  final String id;
  final String title;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final int likes;
  final int views;
  final List<CommentModel> comments;
  final List<String> tags;
  final List<String> images;
  final bool isAnonymous;
  final int bookmarkCount;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.likes = 0,
    this.views = 0,
    this.comments = const [],
    this.tags = const [],
    this.images = const [],
    this.isAnonymous = false,
    this.bookmarkCount = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['category'] as String,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      bookmarkCount: json['bookmark_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'likes': likes,
      'views': views,
      'comments': comments.map((e) => e.toJson()).toList(),
      'tags': tags,
      'images': images,
      'is_anonymous': isAnonymous,
      'bookmark_count': bookmarkCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    UserModel? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    int? likes,
    int? views,
    List<CommentModel>? comments,
    List<String>? tags,
    List<String>? images,
    bool? isAnonymous,
    int? bookmarkCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
    );
  }

  int get commentsCount => comments.length;

  String get excerpt {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}

class CommentModel {
  final String id;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final int likes;
  final bool isAnonymous;
  final String? parentId;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.content,
    required this.author,
    required this.createdAt,
    this.likes = 0,
    this.isAnonymous = false,
    this.parentId,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      likes: json['likes'] as int? ?? 0,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author.toJson(),
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'is_anonymous': isAnonymous,
      'parent_id': parentId,
      'replies': replies.map((e) => e.toJson()).toList(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? content,
    UserModel? author,
    DateTime? createdAt,
    int? likes,
    bool? isAnonymous,
    String? parentId,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
    );
  }

  bool get isReply => parentId != null;
  int get repliesCount => replies.length;
}

class PostListModel {
  final String id;
  final String title;
  final String content;
  final UserModel author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final int likes;
  final int views;
  final int commentsCount;
  final List<String> tags;
  final String? thumbnailImage;
  final bool isAnonymous;

  PostListModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    this.likes = 0,
    this.views = 0,
    this.commentsCount = 0,
    this.tags = const [],
    this.thumbnailImage,
    this.isAnonymous = false,
  });

  factory PostListModel.fromJson(Map<String, dynamic> json) {
    return PostListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      category: json['category'] as String,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      thumbnailImage: json['thumbnail_image'] as String?,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'likes': likes,
      'views': views,
      'comments_count': commentsCount,
      'tags': tags,
      'thumbnail_image': thumbnailImage,
      'is_anonymous': isAnonymous,
    };
  }

  String get excerpt {
    const maxLength = 100;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
}

enum PostCategory {
  free('자유게시판', 'free'),
  info('정보 공유', 'info'),
  counseling('고민 상담', 'counseling');

  const PostCategory(this.displayName, this.value);

  final String displayName;
  final String value;

  static PostCategory fromValue(String value) {
    return PostCategory.values.firstWhere(
          (category) => category.value == value,
      orElse: () => PostCategory.free,
    );
  }
}