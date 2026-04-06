import 'dart:convert';

import 'package:fashion_studio/models/paiement.dart';
import 'package:fashion_studio/services/api_client.dart';

class PaiementsService {
  PaiementsService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Paiement>> list() async {
    final res = await apiClient.get('/paiements');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => Paiement.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Réponse invalide');
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Paiement> create(Paiement paiement) async {
    final res = await apiClient.post('/paiements', paiement.toRequestJson());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Paiement.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }
}
