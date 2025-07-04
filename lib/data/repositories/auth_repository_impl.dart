import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String username, String password) async {
    final userModel = await remoteDataSource.login(username, password);
    return userModel; // UserModel наследуется от User, поэтому преобразование не нужно
  }

  @override
  Future<void> register({
    required String fullName,
    required String specialty,
    required String username,
    required String password,
  }) async {
    await remoteDataSource.register({
      'fullName': fullName,
      'specialty': specialty,
      'username': username,
      'password': password,
    });
  }
}