import 'dart:io';

import 'model.dart';

abstract class UserRepository {
  Future<Model?> getCurrentUserData();

  Future<Model?> getUserById(String uid);

  Stream<List<Model>> watchAllUsers();

  Future<List<Model>> searchUser(String value);

  Future<void> updateUser(
    String uid, {
    required String name,
    required String email,
  });

  Future<void> deleteUser(String uid);
  Future<void> followUser(String currentUid, String targetUid);
  Future<void> unfollowUser(String currentUid, String targetUid);
  Future<String> uploadImage(File image, String uid);
  Stream getFollowers(String uid);
  Stream getFollowing(String uid);
}
