import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';

class CreateCallScreen extends StatefulWidget {
  const CreateCallScreen({super.key});

  @override
  State<CreateCallScreen> createState() => _CreateCallScreenState();
}

class _CreateCallScreenState extends State<CreateCallScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEmergency = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final currentDoctor = apiClient.currentDoctor;

      if (currentDoctor == null) {
        throw Exception("Доктор не авторизован");
      }

      await apiClient.createEmergencyCall(
        doctorId: currentDoctor.id,
        address: _addressController.text,
        phone: _phoneController.text,
        emergency: _isEmergency,
        description: _descriptionController.text,
      );

      Navigator.pop(context); // закрыть экран после успеха
    } catch (e) {
      setState(() {
        _errorMessage = "Ошибка: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Создать вызов")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Адрес
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Адрес",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Введите адрес" : null,
                  ),
                  const SizedBox(height: 16),

                  // Телефон
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: "Телефон",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Описание вызова",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Экстренный вызов
                  SwitchListTile.adaptive(
                    title: const Text("Экстренный вызов"),
                    subtitle: const Text("Включите, если требуется срочное реагирование"),
                    value: _isEmergency,
                    activeColor: Colors.red,
                    onChanged: (val) => setState(() => _isEmergency = val),
                  ),
                  const SizedBox(height: 24),

                  // Кнопка создать
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Align(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Создать"),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
