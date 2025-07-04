import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/register_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'fullName': TextEditingController(),
    'specialty': TextEditingController(),
    'username': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Регистрация успешна!')),
            );
            Navigator.pop(context);
          }
          if (state is RegisterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  _buildTextField('ФИО', 'fullName', icon: Icons.person),
                  const SizedBox(height: 20),
                  
                  _buildTextField('Специальность', 'specialty', icon: Icons.work),
                  const SizedBox(height: 20),
                  
                  _buildTextField('Логин', 'username', icon: Icons.alternate_email),
                  const SizedBox(height: 20),
                  
                  _buildTextField('Пароль', 'password', 
                    icon: Icons.lock_outline, 
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      }
                      if (value.length < 6) {
                        return 'Пароль должен быть не менее 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildTextField('Подтверждение пароля', 'confirmPassword', 
                    icon: Icons.lock, 
                    isPassword: true,
                    validator: (value) {
                      if (value != _controllers['password']?.text) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: state is RegisterLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is RegisterLoading
                        ? const CircularProgressIndicator()
                        : const Text('Зарегистрироваться', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String key, {
    IconData? icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      obscureText: isPassword,
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterBloc>().add(RegisterRequested(
        fullName: _controllers['fullName']!.text,
        specialty: _controllers['specialty']!.text,
        username: _controllers['username']!.text,
        password: _controllers['password']!.text,
      ));
    }
  }
}