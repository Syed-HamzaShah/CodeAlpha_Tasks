class PostModel {
  final String id;
  final String description;
  final String? mediaUrl;
  final String createdBy;
  final String createdByName;
  final String? createdByAvatar;
  final DateTime createdAt;
  final List<String> likes;
  final List<PostComment> comments;

  PostModel({
    required this.id,
    required this.description,
    this.mediaUrl,
    required this.createdBy,
    required this.createdByName,
    this.createdByAvatar,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      mediaUrl: map['mediaurl'] ?? map['mediaUrl'], // Handle both cases
      createdBy: map['createdby'] ?? map['createdBy'] ?? '',
      createdByName: map['createdbyname'] ?? map['createdByName'] ?? '',
      createdByAvatar: map['createdbyavatar'] ?? map['createdByAvatar'],
      createdAt: DateTime.parse(
        map['createdat'] ??
            map['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      likes: List<String>.from(map['likes'] ?? []),
      comments:
          (map['comments'] as List? ?? [])
              .map((comment) => PostComment.fromMap(comment))
              .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'mediaUrl': mediaUrl,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByAvatar': createdByAvatar,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
    };
  }

  PostModel copyWith({
    String? id,
    String? description,
    String? mediaUrl,
    String? createdBy,
    String? createdByName,
    String? createdByAvatar,
    DateTime? createdAt,
    List<String>? likes,
    List<PostComment>? comments,
  }) {
    return PostModel(
      id: id ?? this.id,
      description: description ?? this.description,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByAvatar: createdByAvatar ?? this.createdByAvatar,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }
}

class PostComment {
  final String id;
  final String text;
  final String userId;
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.text,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
  });

  factory PostComment.fromMap(Map<String, dynamic> map) {
    return PostComment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'],
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
