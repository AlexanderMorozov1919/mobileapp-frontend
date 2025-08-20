import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _doctorIdKey = 'doctor_id';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  /// Сохраняем токен
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _setCookie('token', token);
      await _prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  /// Сохраняем doctorId
  Future<void> saveDoctorId(String doctorId) async {
    if (kIsWeb) {
      _setCookie('doctor_id', doctorId);
      await _prefs.setString(_doctorIdKey, doctorId);
    } else {
      await _secureStorage.write(key: _doctorIdKey, value: doctorId);
    }
  }

  /// Получаем токен
  Future<String?> getToken() async {
    if (kIsWeb) {
      return _getCookie('token') ?? _prefs.getString(_tokenKey);
    } else {
      return await _secureStorage.read(key: _tokenKey);
    }
  }

  /// Получаем doctorId
  Future<String?> getDoctorId() async {
    if (kIsWeb) {
      return _getCookie('doctor_id') ?? _prefs.getString(_doctorIdKey);
    } else {
      return await _secureStorage.read(key: _doctorIdKey);
    }
  }

  /// Удаляем токен
  Future<void> deleteToken() async {
    if (kIsWeb) {
      _deleteCookie('token');
      await _prefs.remove(_tokenKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
    }
  }

  /// Удаляем doctorId
  Future<void> deleteDoctorId() async {
    if (kIsWeb) {
      _deleteCookie('doctor_id');
      await _prefs.remove(_doctorIdKey);
    } else {
      await _secureStorage.delete(key: _doctorIdKey);
    }
  }

  /// Полный выход
  Future<void> clearAll() async {
    await deleteToken();
    await deleteDoctorId();
  }

  // ===== Вспомогательные методы для работы с cookie на Web =====

  void _setCookie(String key, String value) {
    final expiration = DateTime.now().add(const Duration(days: 30));
    final cookie =
        "$key=$value; expires=${expiration.toUtc().toIso8601String()}; path=/";
    html.document.cookie = cookie;
  }

  String? _getCookie(String key) {
    final cookies = html.document.cookie?.split(';') ?? [];
    for (final cookie in cookies) {
      final parts = cookie.split('=');
      if (parts.length == 2 && parts[0].trim() == key) {
        return parts[1].trim();
      }
    }
    return null;
  }

  void _deleteCookie(String key) {
    html.document.cookie =
        "$key=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
  }
}
