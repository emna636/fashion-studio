import 'dart:convert';

import 'package:fashion_studio/services/token_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStorage});

  final String baseUrl;
  final TokenStorage tokenStorage;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    return http.get(_uri(path), headers: await _headers());
  }

  Future<http.Response> post(String path, Object body, {bool auth = true}) async {
    return http.post(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body));
  }

  Future<http.Response> put(String path, Object body) async {
    return http.put(_uri(path), headers: await _headers(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    return http.delete(_uri(path), headers: await _headers());
  }
}
