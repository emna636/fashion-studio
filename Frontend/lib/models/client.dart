class Client {
  Client({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    this.email,
    required this.taille,
    required this.poitrine,
    required this.tourDeTaille,
    required this.hanches,
    required this.createdAt,
  });

  final String id;
  final String prenom;
  final String nom;
  final String telephone;
  final String? email;
  final int? taille;
  final int? poitrine;
  final int? tourDeTaille;
  final int? hanches;
  final DateTime createdAt;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String,
      prenom: (json['prenom'] as String?) ?? '',
      nom: (json['nom'] as String?) ?? '',
      telephone: (json['telephone'] as String?) ?? '',
      email: json['email'] as String?,
      taille: json['taille'] as int?,
      poitrine: json['poitrine'] as int?,
      tourDeTaille: json['tourDeTaille'] as int?,
      hanches: json['hanches'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'prenom': prenom,
      'nom': nom,
      'telephone': telephone,
      'email': (email != null && email!.trim().isNotEmpty) ? email : null,
      'taille': taille,
      'poitrine': poitrine,
      'tourDeTaille': tourDeTaille,
      'hanches': hanches,
    };
  }
}
