import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository repository;

  RegisterBloc({required this.repository}) : super(RegisterInitial()) {
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      await repository.register(
        fullName: event.fullName,
        specialty: event.specialty,
        username: event.username,
        password: event.password,
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterError(message: e.toString()));
    }
  }
}