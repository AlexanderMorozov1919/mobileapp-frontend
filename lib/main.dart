import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Domain Layer
import 'domain/usecases/login_usecase.dart';
import 'domain/repositories/auth_repository.dart';

// Data Layer
import 'data/datasources/auth_remote_data_source.dart';
import 'data/models/user_model.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/models/doctor_model.dart';

// Presentation Layer
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/main_screen.dart';
import 'presentation/bloc/login_bloc.dart';

// Services
import 'services/auth_service.dart'; // Добавляем импорт AuthService
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();

  final authService = AuthService(prefs);
  final apiClient = ApiClient(authService);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  
  runApp(MyApp(
    apiClient: apiClient,
    authRepository: authRepository,
    authService: authService
  ));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final AuthService authService;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        Provider.value(value: apiClient),
        Provider.value(value: this.authService),
        BlocProvider(
          create: (context) => LoginBloc(
            loginUseCase: LoginUseCase(authRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Медицинская информационная система',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
        ],
        theme: ThemeData(
          primaryColor: const Color(0xFF5F9EA0), // Основной цвет (для кнопок и акцентов)
          scaffoldBackgroundColor: const Color(0xFFFFF0F5), // Фон всего приложения
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: const MaterialColor(0xFF5F9EA0, {
              50: Color(0xFFE0F2F1),
              100: Color(0xFFB2DFDB),
              200: Color(0xFF80CBC4),
              300: Color(0xFF4DB6AC),
              400: Color(0xFF26A69A),
              500: Color(0xFF5F9EA0), // кнопки
              600: Color(0xFF00897B),
              700: Color(0xFF00796B),
              800: Color(0xFF00695C),
              900: Color(0xFF004D40),
            }),
            accentColor: const Color(0xFF4682B4), // Нижнее меню, выделенная дата
            backgroundColor: const Color(0xFFFFF0F5),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 1,
            backgroundColor: Color(0xFF5F9EA0), // Верхняя панель
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
              foregroundColor: Colors.white, // Текст на кнопках
              backgroundColor: const Color(0xFF5F9EA0), // Цвет кнопок
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5F9EA0),
            ),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: const Color(0xFF4682B4), // Нижнее меню
            selectedItemColor: Colors.white, // Выбранный элемент меню
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
        home: FutureBuilder<String?>(
          future: authService.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasData && snapshot.data != null) {
              // Если данные доктора уже загружены
              if (apiClient.currentDoctor != null) {
                return const MainScreen();
              }
              
              // Загружаем данные доктора если есть ID
              return FutureBuilder<void>(
                future: _loadDoctorData(context),
                builder: (context, doctorSnapshot) {
                  if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const MainScreen();
                },
              );
            }
            
            return LoginScreen();
          },
        ),
      ),
    );
  }

  Future<void> _loadDoctorData(BuildContext context) async {
    try {
      final doctorId = await context.read<AuthService>().getDoctorId();
      if (doctorId != null) {
        final doctorData = await context.read<ApiClient>().getDoctorById(doctorId);
        final doctor = Doctor.fromJson(doctorData); // Преобразование
        context.read<ApiClient>().setCurrentDoctor(doctor);
      }
    } catch (e) {
      debugPrint('Ошибка загрузки данных доктора: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
}

// main.dart (измененная реализация AuthRemoteDataSourceImpl)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await apiClient.loginDoctor({
        'phone': phone,
        'password': password,
      });
      
      // Проверяем структуру ответа
      if (response.containsKey('token') && response.containsKey('id')) {
        // Преобразуем ID в int
        final userId = response['id'] is int 
            ? response['id'] 
            : int.tryParse(response['id'].toString());
        
        if (userId == null) {
          throw Exception('Неверный формат ID пользователя');
        }
        
        return UserModel(
          token: response['token'],
          userId: userId,
        );
      } else {
        throw Exception('Неверный формат ответа сервера: отсутствует токен или id');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка сети: ${e.message}');
    } on ApiError catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Неизвестная ошибка: ${e.toString()}');
    }
  }
}