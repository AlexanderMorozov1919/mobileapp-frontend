part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterRequested extends RegisterEvent {
  final String fullName;
  final String specialty;
  final String username;
  final String password;

  const RegisterRequested({
    required this.fullName,
    required this.specialty,
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [fullName, specialty, username, password];
}