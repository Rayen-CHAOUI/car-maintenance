class Voiture {
  final int? id;
  final String marque;
  final String modele;
  final int annee;

  Voiture({
    this.id,
    required this.marque,
    required this.modele,
    required this.annee,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'marque': marque, 'modele': modele, 'annee': annee};
  }

  static Voiture fromMap(Map<String, dynamic> map) {
    return Voiture(
      id: map['id'],
      marque: map['marque'],
      modele: map['modele'],
      annee: map['annee'],
    );
  }
}
