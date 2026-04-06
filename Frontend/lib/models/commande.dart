enum StatutCommande {
  enAttente,
  enCours,
  enCouture,
  paye,
  termine,
  livre,
}

StatutCommande statutCommandeFromApi(dynamic v) {
  final s = (v as String).toUpperCase();
  return switch (s) {
    'EN_ATTENTE' => StatutCommande.enAttente,
    'EN_COURS' => StatutCommande.enCours,
    'EN_COUTURE' => StatutCommande.enCouture,
    'PAYE' => StatutCommande.paye,
    'TERMINE' => StatutCommande.termine,
    'LIVRE' => StatutCommande.livre,
    _ => StatutCommande.enAttente,
  };
}

String statutCommandeToApi(StatutCommande statut) {
  return switch (statut) {
    StatutCommande.enAttente => 'EN_ATTENTE',
    StatutCommande.enCours => 'EN_COURS',
    StatutCommande.enCouture => 'EN_COUTURE',
    StatutCommande.paye => 'PAYE',
    StatutCommande.termine => 'TERMINE',
    StatutCommande.livre => 'LIVRE',
  };
}

class Commande {
  Commande({
    required this.id,
    required this.clientId,
    required this.designId,
    required this.statut,
    required this.prixTotal,
    required this.montantPaye,
    required this.dateCommande,
    required this.dateLivraison,
    this.notes,
  });

  final String id;
  final String clientId;
  final String designId;
  final StatutCommande statut;
  final num prixTotal;
  final num montantPaye;
  final DateTime dateCommande;
  final DateTime dateLivraison;
  final String? notes;

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      designId: json['designId'] as String,
      statut: statutCommandeFromApi(json['statut']),
      prixTotal: (json['prixTotal'] as num?) ?? 0,
      montantPaye: (json['montantPaye'] as num?) ?? 0,
      dateCommande: DateTime.parse(json['dateCommande'] as String),
      dateLivraison: DateTime.parse(json['dateLivraison'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'clientId': clientId,
      'designId': designId,
      'statut': statutCommandeToApi(statut),
      'prixTotal': prixTotal,
      'montantPaye': montantPaye,
      'dateCommande': dateCommande.toIso8601String().substring(0, 10),
      'dateLivraison': dateLivraison.toIso8601String().substring(0, 10),
      'notes': (notes != null && notes!.trim().isNotEmpty) ? notes : null,
    };
  }

  num get resteAPayer => prixTotal - montantPaye;
}
