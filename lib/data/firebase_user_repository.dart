import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/model.dart';
import '../domain/user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Future<Model?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _firestore.collection('Users').doc(user.uid).get();
    if (!snap.exists) return null;
    return Model.fromMap(snap.data()!);
  }

  @override
  Future<Model?> getUserById(String uid) async {
    final snap = await _firestore.collection('Users').doc(uid).get();
    if (!snap.exists) return null;
    return Model.fromMap(snap.data()!);
  }

  @override
  Stream<List<Model>> watchAllUsers() {
    return _firestore
        .collection('Users')
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => Model.fromMap(doc.data())).toList(),
        );
  }

  @override
  Future<List<Model>> searchUser(String value) async {
    final data = await _firestore
        .collection('Users')
        .where("name", isGreaterThanOrEqualTo: value)
        .where("name", isLessThan: '${value}z')
        .get();

    return data.docs.map((json) => Model.fromMap(json.data())).toList();
  }

  @override
  Future<void> updateUser(
    String uid, {
    required String name,
    required String email,
  }) async {
    await _firestore.collection('Users').doc(uid).update({
      'name': name,
      'email': email,
    });
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('Users').doc(uid).delete();
  }

  @override
  Future<void> followUser(String currentUid, String targetUid) async {
    await _firestore
        .collection("Users")
        .doc(targetUid)
        .collection("Followers")
        .doc(currentUid)
        .set({});
    await _firestore
        .collection("Users")
        .doc(currentUid)
        .collection("Following")
        .doc(targetUid)
        .set({});
  }

  @override
  Future<void> unfollowUser(String currentUid, String targetUid) async {
    await _firestore
        .collection("Users")
        .doc(targetUid)
        .collection("Followers")
        .doc(currentUid)
        .delete();
    await _firestore
        .collection("Users")
        .doc(currentUid)
        .collection("Following")
        .doc(targetUid)
        .delete();
  }

  @override
  Stream getFollowers(String uid) {
    return _firestore
        .collection("Users")
        .doc(uid)
        .collection("Followers")
        .snapshots();
  }

  @override
  Stream getFollowing(String uid) {
    return _firestore
        .collection("Users")
        .doc(uid)
        .collection("Following")
        .snapshots();
  }

  @override
  Future<String> uploadImage(File image, String uid) async {
    final ref = FirebaseStorage.instance.ref().child("Profile/$uid.jpg");

    await ref.putFile(image);

    String imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('Users').doc(uid).update({
      'imageUrl': imageUrl,
    });

    return imageUrl;
  }
}
