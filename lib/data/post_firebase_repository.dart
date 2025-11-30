import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled14/domain/comments.dart';
import '../domain/post.dart';
import '../domain/post_repository.dart';

class FirebasePostRepository implements PostRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> createPost({required String uid, required String post}) async {
    String postId = _firestore.collection("Posts").doc().id;
    await _firestore.collection("Posts").doc(postId).set({
      'postId': postId,
      'ownerId': uid,
      'post': post,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Post>> getUserPosts(String uid) {
    return _firestore
        .collection("Posts")
        .where("ownerId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList(),
        );
  }

  @override
  Future<void> Like(String postid, String uid) async {
    await _firestore
        .collection('Posts')
        .doc(postid)
        .collection('likes')
        .doc(uid)
        .set({});
    await _firestore.collection('Posts').doc(postid).update({
      'likecount': FieldValue.increment(1),
    });
  }

  @override
  Future<void> Unlike(String postid, String uid) async {
    await _firestore
        .collection('Posts')
        .doc(postid)
        .collection('likes')
        .doc(uid)
        .delete();
    await _firestore.collection('Posts').doc(postid).update({
      'likecount': FieldValue.increment(-1),
    });
  }

  @override
  Stream<int> likecount(String postid) {
    return _firestore
        .collection('Posts')
        .doc(postid)
        .snapshots()
        .map((doc) => (doc.data()?['likecount'] ?? 0) as int);
  }

  @override
  Stream<bool> postlike(String postid, String uid) {
    return _firestore
        .collection('Posts')
        .doc(postid)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Stream<List<Post>> getAllPosts() {
    return _firestore
        .collection("Posts")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList(),
        );
  }

  @override
  Future<void> comments(
    String postId,
    String userName,
    String uid,
    String comment,
  ) async {
    String commentid = _firestore
        .collection('Posts')
        .doc(postId)
        .collection('comments')
        .doc()
        .id;
    await _firestore
        .collection('Posts')
        .doc(postId)
        .collection('comments')
        .doc(commentid)
        .set({'uid': uid, 'userName': userName, 'comments': comment});
  }

  Stream<List<Comments>> getCommets(String postId) {
    return _firestore
        .collection('Posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => Comments.fromMap(doc.data())).toList(),
        );
  }
}
