import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String ownerId;
  final String post;
  final DateTime? createdAt;

  Post({
    required this.postId,
    required this.ownerId,
    required this.post,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['postId'] ?? "",
      ownerId: map['ownerId'] ?? "",
      post: map['post'] ?? "",
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'ownerId': ownerId,
      'post': post,
      'createdAt': createdAt,
    };
  }
}
