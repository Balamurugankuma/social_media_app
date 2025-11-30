import '../data/firebase_auth_repository.dart';
import '../data/firebase_user_repository.dart';
import '../data/post_firebase_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/post_repository.dart';
import '../domain/user_repository.dart';

final AuthRepository authRepository = FirebaseAuthRepository();
final UserRepository userRepository = FirebaseUserRepository();
final PostRepository postRepository = FirebasePostRepository();
