import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password);
  Future<void> register({
    required String fullName,
    required String specialty,
    required String username,
    required String password,
  });
}