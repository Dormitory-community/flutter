class StudyGroupModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String leader;
  final String schedule;
  final String location;
  final List<String> tags;
  final List<String> participants;
  final int maxParticipants;
  final DateTime createdAt;

  StudyGroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.leader,
    required this.schedule,
    required this.location,
    required this.tags,
    required this.participants,
    required this.maxParticipants,
    required this.createdAt,
  });

  factory StudyGroupModel.fromJson(Map<String, dynamic> json) {
    return StudyGroupModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      leader: json['leader'] as String,
      schedule: json['schedule'] as String,
      location: json['location'] as String,
      tags: List<String>.from(json['tags'] as List),
      participants: List<String>.from(json['participants'] as List),
      maxParticipants: json['max_participants'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'leader': leader,
      'schedule': schedule,
      'location': location,
      'tags': tags,
      'participants': participants,
      'max_participants': maxParticipants,
      'created_at': createdAt.toIso8601String(),
    };
  }

  StudyGroupModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? leader,
    String? schedule,
    String? location,
    List<String>? tags,
    List<String>? participants,
    int? maxParticipants,
    DateTime? createdAt,
  }) {
    return StudyGroupModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      leader: leader ?? this.leader,
      schedule: schedule ?? this.schedule,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedCreatedAt => '${createdAt.month}월 ${createdAt.day}일 생성';

  @override
  String toString() {
    return 'StudyGroupModel(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyGroupModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}