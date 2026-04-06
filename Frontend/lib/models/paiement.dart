class Paiement {
  Paiement({
    required this.id,
    required this.commandeId,
    required this.montant,
    required this.methodePaiement,
    this.notes,
    required this.datePaiement,
    required this.createdAt,
  });

  final String id;
  final String commandeId;
  final num montant;
  final String methodePaiement;
  final String? notes;
  final DateTime datePaiement;
  final DateTime createdAt;

  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'] as String,
      commandeId: json['commandeId'] as String,
      montant: (json['montant'] as num?) ?? 0,
      methodePaiement: (json['methodePaiement'] as String?) ?? 'ESPECES',
      notes: json['notes'] as String?,
      datePaiement: DateTime.parse(json['datePaiement'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'commandeId': commandeId,
      'montant': montant,
      'methodePaiement': methodePaiement,
      'notes': (notes != null && notes!.trim().isNotEmpty) ? notes : null,
      'datePaiement': datePaiement.toIso8601String().substring(0, 10),
    };
  }
}
