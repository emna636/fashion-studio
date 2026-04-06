import 'dart:convert';

import 'package:fashion_studio/services/api_client.dart';
import 'package:fashion_studio/services/token_storage.dart';

class AuthResult {
  AuthResult({required this.success, this.token, this.message});

  final bool success;
  final String? token;
  final String? message;
}

class AuthService {
  AuthService({required this.apiClient, required this.tokenStorage});

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  Future<bool> hasToken() async {
    final t = await tokenStorage.getToken();
    return t != null && t.isNotEmpty;
  }

  Future<void> logout() async {
    await tokenStorage.clearToken();
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      final res = await apiClient.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
        auth: false,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token == null || token.isEmpty) {
          return AuthResult(
              success: false, message: "Token manquant dans la réponse");
        }
        await tokenStorage.saveToken(token);
        return AuthResult(success: true, token: token);
      }

      String? message;
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        message = data['message'] as String?;
      } catch (_) {
        message = null;
      }

      return AuthResult(
          success: false,
          message: message ?? 'Email ou mot de passe incorrect');
    } catch (e) {
      return AuthResult(success: false, message: 'Une erreur est survenue');
    }
  }

  Future<AuthResult> signup(
      String nom, String email, String password, String atelier) async {
    try {
      final res = await apiClient.post(
        '/auth/signup',
        {
          'nom': nom,
          'atelier': atelier,
          'email': email,
          'password': password,
        },
        auth: false,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        if (token == null || token.isEmpty) {
          return AuthResult(
              success: false, message: "Token manquant dans la réponse");
        }
        await tokenStorage.saveToken(token);
        return AuthResult(success: true, token: token);
      }

      String? message;
      try {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        message = data['message'] as String?;
      } catch (_) {
        message = null;
      }

      return AuthResult(
          success: false, message: message ?? 'Impossible de créer le compte');
    } catch (e) {
      return AuthResult(success: false, message: 'Une erreur est survenue');
    }
  }
}
