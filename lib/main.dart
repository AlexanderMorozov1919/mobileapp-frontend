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
          primaryColor: const Color(0xFF8B8B8B), // Серый
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: const MaterialColor(0xFF8B8B8B, {
              50: Color(0xFFF2F2F2),
              100: Color(0xFFE6E6E6),
              200: Color(0xFFD1D1D1),
              300: Color(0xFFBCBCBC),
              400: Color(0xFFA3A3A3),
              500: Color(0xFF8B8B8B),
              600: Color(0xFF737373),
              700: Color(0xFF5C5C5C),
              800: Color(0xFF454545),
              900: Color(0xFF2E2E2E),
            }),
            accentColor: const Color(0xFFD2B48C), // Бежевый
            backgroundColor: const Color(0xFFF5F5F5), // Светло-серый фон
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
            backgroundColor: Color(0xFF8B8B8B),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF8B8B8B), // Серый
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF8B8B8B), // Серовый
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF8B8B8B), // Серый
            selectedItemColor: const Color(0xFFD2B48C), // Бежевый
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: LoginPage(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/register': (context) => const RegisterPage(),
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