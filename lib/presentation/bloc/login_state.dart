part of 'login_bloc.dart';

// Базовое состояние авторизации
abstract class LoginState extends Equatable {
  const LoginState();
  
  @override
  List<Object> get props => [];
}

// Начальное состояние
class LoginInitial extends LoginState {}

// Состояние загрузки
class LoginLoading extends LoginState {}

// Успешная авторизация
class LoginSuccess extends LoginState {
  final User user;
  
  const LoginSuccess({required this.user});
  
  @override
  List<Object> get props => [user];
}

// Ошибка авторизации
class LoginError extends LoginState {
  final String message;
  
  const LoginError({required this.message});
  
  @override
  List<Object> get props => [message];
}