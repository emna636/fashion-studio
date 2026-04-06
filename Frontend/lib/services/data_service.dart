import 'dart:convert';

import 'package:fashion_studio/models/client.dart';
import 'package:fashion_studio/models/commande.dart';
import 'package:fashion_studio/models/design.dart';
import 'package:fashion_studio/models/paiement.dart';
import 'package:fashion_studio/services/api_client.dart';

class DashboardData {
  DashboardData({
    required this.clients,
    required this.designs,
    required this.commandes,
    required this.paiements,
  });

  final List<Client> clients;
  final List<Design> designs;
  final List<Commande> commandes;
  final List<Paiement> paiements;
}

class DataService {
  DataService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<T>> _getList<T>(String path, T Function(Map<String, dynamic>) fromJson) async {
    final res = await apiClient.get(path);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Réponse invalide');
    }

    throw Exception('Erreur API (${res.statusCode})');
  }

  Future<DashboardData> fetchDashboard() async {
    final clients = await _getList('/clients', (j) => Client.fromJson(j));
    final designs = await _getList('/designs', (j) => Design.fromJson(j));
    final commandes = await _getList('/commandes', (j) => Commande.fromJson(j));
    final paiements = await _getList('/paiements', (j) => Paiement.fromJson(j));

    return DashboardData(
      clients: clients,
      designs: designs,
      commandes: commandes,
      paiements: paiements,
    );
  }
}
