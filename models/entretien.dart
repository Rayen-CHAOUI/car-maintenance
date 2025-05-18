class Entretien {
  final int? id;
  final int voitureId;
  final String type;
  final String description;
  final DateTime dateDebut;
  final DateTime? dateExpiration;
  final double prix;
  final int? kilometrageActuel;
  final int? prochainVidange;

  Entretien({
    this.id,
    required this.voitureId,
    required this.type,
    required this.description,
    required this.dateDebut,
    this.dateExpiration,
    required this.prix,
    this.kilometrageActuel,
    this.prochainVidange,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voiture_id': voitureId,
      'type': type,
      'description': description,
      'dateDebut': dateDebut.toIso8601String(),
      'dateExpiration': dateExpiration?.toIso8601String(),
      'prix': prix,
      'kilometrageActuel': kilometrageActuel,
      'prochainVidange': prochainVidange,
    };
  }

  static Entretien fromMap(Map<String, dynamic> map) {
    return Entretien(
      id: map['id'],
      voitureId: map['voiture_id'],
      type: map['type'],
      description: map['description'],
      dateDebut: DateTime.parse(map['dateDebut']),
      dateExpiration:
          map['dateExpiration'] != null
              ? DateTime.parse(map['dateExpiration'])
              : null,
      prix: map['prix'],
      kilometrageActuel: map['kilometrageActuel'],
      prochainVidange: map['prochainVidange'],
    );
  }
}
