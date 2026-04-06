class Design {
  Design({
    required this.id,
    required this.nom,
    required this.description,
    required this.type,
    required this.prix,
    required this.imageUrl,
    required this.createdAt,
  });

  final String id;
  final String nom;
  final String description;
  final String type;
  final num prix;
  final String imageUrl;
  final DateTime createdAt;

  factory Design.fromJson(Map<String, dynamic> json) {
    return Design(
      id: json['id'] as String,
      nom: (json['nom'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      prix: (json['prix'] as num?) ?? 0,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'nom': nom,
      'description': description.trim().isEmpty ? null : description,
      'type': type,
      'prix': prix,
      'imageUrl': imageUrl.trim().isEmpty ? null : imageUrl,
    };
  }
}
