import 'dart:convert';

import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/services/api_client.dart';

class DesignsService {
  DesignsService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Design>> list() async {
    final res = await apiClient.get('/designs');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .map((e) => Design.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Réponse invalide');
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Design> create(Design design) async {
    final res = await apiClient.post('/designs', design.toRequestJson());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Design.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Design> update(String id, Design design) async {
    final res = await apiClient.put('/designs/$id', design.toRequestJson());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Design.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<void> delete(String id) async {
    final res = await apiClient.delete('/designs/$id');
    if (res.statusCode == 204 ||
        (res.statusCode >= 200 && res.statusCode < 300)) {
      return;
    }
    throw Exception('Erreur API (${res.statusCode})');
  }
}
