import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Domain Layer
import 'domain/entities/user.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';

// Data Layer
import 'data/datasources/auth_remote_data_source.dart';
import 'data/models/user_model.dart';
import 'data/repositories/auth_repository_impl.dart';

// Presentation Layer
import 'presentation/pages/login_page.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/pages/register_page.dart'; // Добавлен импорт
import 'presentation/bloc/login_bloc.dart';
import 'presentation/bloc/register_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(),
    );
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(
            loginUseCase: LoginUseCase(authRepository),
          ),
        ),
        BlocProvider(
          create: (context) => RegisterBloc(
            repository: authRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Медицинская информационная система',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: LoginPage(),
        routes: {
          '/main': (context) => MainScreen(),
          '/register': (context) => const RegisterPage(), // Добавлен маршрут
        },
      ),
    );
  }
}

// Реализация удаленного источника данных
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (username == 'admin' && password == '123456') {
      return UserModel(token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
    } else {
      throw Exception('Неверные учетные данные');
    }
  }

  @override
  Future<void> register(Map<String, dynamic> userData) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (userData['username'] == 'admin') {
      throw Exception('Пользователь с таким логином уже существует');
    }
    
    print('Регистрация пользователя: $userData');
  }
}