import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/entretien.dart';
import '../models/voiture.dart';

class HomePage extends StatefulWidget {
  final Voiture voiture;

  const HomePage({super.key, required this.voiture});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Entretien> entretiens = [];

  @override
  void initState() {
    super.initState();
    _loadEntretiens();
  }

  Future<void> _loadEntretiens() async {
    final data = await dbHelper.getEntretiensByVoiture(widget.voiture.id!);
    setState(() => entretiens = data);
  }

  Future<void> _confirmDeleteEntretien(int id) async {
    bool confirm = await _showConfirmationDialog(
        "Supprimer cet entretien ?", "Voulez-vous vraiment supprimer cet entretien ?");
    if (confirm) {
      await dbHelper.deleteEntretien(id);
      _loadEntretiens();
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showAddEntretienDialog() {
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final prixController = TextEditingController();
    final kmActuelController = TextEditingController();
    final prochainVidangeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    DateTime? expirationDate;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter un entretien'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Type')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: prixController, decoration: const InputDecoration(labelText: 'Prix'), keyboardType: TextInputType.number),
              TextField(controller: kmActuelController, decoration: const InputDecoration(labelText: 'Kilométrage Actuel'), keyboardType: TextInputType.number),
              TextField(controller: prochainVidangeController, decoration: const InputDecoration(labelText: 'Prochain Vidange'), keyboardType: TextInputType.number),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
                child: Text('Date de début: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => expirationDate = date);
                },
                child: Text(expirationDate == null ? 'Choisir la date d\'expiration' : 'Expire le: ${DateFormat('dd/MM/yyyy').format(expirationDate!)}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              if (typeController.text.isEmpty || prixController.text.isEmpty || kmActuelController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.')));
                return;
              }
              await dbHelper.insertEntretien(
                Entretien(
                  voitureId: widget.voiture.id!,
                  type: typeController.text,
                  description: descriptionController.text,
                  dateDebut: selectedDate,
                  dateExpiration: expirationDate,
                  prix: double.parse(prixController.text),
                  kilometrageActuel: int.tryParse(kmActuelController.text),
                  prochainVidange: int.tryParse(prochainVidangeController.text),
                ),
              );
              Navigator.pop(dialogContext);
              _loadEntretiens();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entretien - ${widget.voiture.marque} ${widget.voiture.modele}')),
      body: entretiens.isEmpty
          ? const Center(child: Text('Aucun entretien enregistré.'))
          : ListView.builder(
              itemCount: entretiens.length,
              itemBuilder: (context, index) {
                final entretien = entretiens[index];
                return ListTile(
                  title: Text('${entretien.type} - ${entretien.description}'),
                  subtitle: Text(
                    'Prix: ${entretien.prix} DA | Début: ${DateFormat('dd/MM/yyyy').format(entretien.dateDebut)}'
                    '${entretien.dateExpiration != null ? ' | Expire: ${DateFormat('dd/MM/yyyy').format(entretien.dateExpiration!)}' : ''}'
                    '${entretien.kilometrageActuel != null ? ' | Km: ${entretien.kilometrageActuel}' : ''}'
                    '${entretien.prochainVidange != null ? ' | Prochain vidange: ${entretien.prochainVidange} km' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteEntretien(entretien.id!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntretienDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
