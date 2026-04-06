import 'dart:convert';

import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/services/api_client.dart';

class ClientsService {
  ClientsService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Client>> list() async {
    final res = await apiClient.get('/clients');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Client.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Réponse invalide');
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Client> create({
    required String prenom,
    required String nom,
    required String telephone,
    String? email,
    required int taille,
    required int poitrine,
    required int tourDeTaille,
    required int hanches,
  }) async {
    final res = await apiClient.post(
      '/clients',
      {
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'email': (email != null && email.trim().isNotEmpty) ? email : null,
        'taille': taille,
        'poitrine': poitrine,
        'tourDeTaille': tourDeTaille,
        'hanches': hanches,
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Client.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Client> update({
    required String id,
    required String prenom,
    required String nom,
    required String telephone,
    String? email,
    required int taille,
    required int poitrine,
    required int tourDeTaille,
    required int hanches,
  }) async {
    final res = await apiClient.put(
      '/clients/$id',
      {
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'email': (email != null && email.trim().isNotEmpty) ? email : null,
        'taille': taille,
        'poitrine': poitrine,
        'tourDeTaille': tourDeTaille,
        'hanches': hanches,
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Client.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<void> delete(String id) async {
    final res = await apiClient.delete('/clients/$id');
    if (res.statusCode == 204 || (res.statusCode >= 200 && res.statusCode < 300)) {
      return;
    }
    throw Exception('Erreur API (${res.statusCode})');
  }
}
