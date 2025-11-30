import 'model.dart';

abstract class AuthRepository {
  Future<Model> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Model> login({required String email, required String password});

  Future<void> resetPassword(String email);

  Future<Model?> getCurrentUser();
}
