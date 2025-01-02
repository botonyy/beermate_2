import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String userId;
  final String content;
  final String imageUrl;
  final bool isPublic;

  Post({
    required this.userId,
    required this.content,
    required this.imageUrl,
    required this.isPublic,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Post(
      userId: data['user_id'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['image_url'] ?? '',
      isPublic: data['is_public'] ?? false,
    );
  }
}
