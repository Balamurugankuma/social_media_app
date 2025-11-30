import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/auth_repository.dart';
import '../domain/model.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Model> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    await _firestore.collection('Users').doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return Model(
      uid: uid,
      name: name,
      email: email,
      password: null,
      imageUrl: null,
    );
  }

  @override
  Future<Model> login({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    final snap = await _firestore.collection('Users').doc(uid).get();
    final data = snap.data();

    return Model.fromMap(data!);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<Model?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _firestore.collection('Users').doc(user.uid).get();
    if (!snap.exists) return null;
    return Model.fromMap(snap.data()!);
  }
}
