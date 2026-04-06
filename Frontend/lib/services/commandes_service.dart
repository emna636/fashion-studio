import 'dart:convert';

import 'package:fashion_studio/models/commande.dart';
import 'package:fashion_studio/services/api_client.dart';

class CommandesService {
  CommandesService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Commande>> list() async {
    final res = await apiClient.get('/commandes');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data
            .map((e) => Commande.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Réponse invalide');
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Commande> create(Commande commande) async {
    final res = await apiClient.post('/commandes', commande.toRequestJson());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Commande.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<Commande> update(String id, Commande commande) async {
    final res = await apiClient.put('/commandes/$id', commande.toRequestJson());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Commande.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<void> delete(String id) async {
    final res = await apiClient.delete('/commandes/$id');
    if (res.statusCode == 204 ||
        (res.statusCode >= 200 && res.statusCode < 300)) {
      return;
    }
    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<({List<int> bytes, String? filename})> downloadFacturePdf(
    String id, {
    String? type,
  }) async {
    final suffix = (type == null || type.trim().isEmpty) ? '' : '?type=$type';
    final res = await apiClient.get('/commandes/$id/facture.pdf$suffix');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final cd = res.headers['content-disposition'];
      String? filename;
      if (cd != null) {
        final m = RegExp('filename="([^"]+)"').firstMatch(cd);
        filename = m?.group(1);
      }
      return (bytes: res.bodyBytes, filename: filename);
    }
    throw Exception('Erreur API (${res.statusCode})');
  }
}
