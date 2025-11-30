import 'package:untitled14/domain/comments.dart';
import 'package:untitled14/domain/post.dart';

abstract class PostRepository {
  Future<void> createPost({required String uid, required String post});
  Future<void> comments(
    String postId,
    String userName,
    String uid,
    String comment,
  );

  Stream<List<Post>> getUserPosts(String uid);
  Future<void> Like(String postId, String uid);
  Future<void> Unlike(String postId, String uid);
  Stream<bool> postlike(String postId, String uid);
  Stream<int> likecount(String postId);
  Stream<List<Post>> getAllPosts();
  Stream<List<Comments>> getCommets(String postId);
}
