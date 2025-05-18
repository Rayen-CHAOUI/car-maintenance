import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/voiture.dart';
import 'home_page.dart';

class SelectVoiturePage extends StatefulWidget {
  @override
  _SelectVoiturePageState createState() => _SelectVoiturePageState();
}

class _SelectVoiturePageState extends State<SelectVoiturePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Voiture> voitures = [];

  @override
  void initState() {
    super.initState();
    _loadVoitures();
  }

  Future<void> _loadVoitures() async {
    final data = await dbHelper.getAllVoitures();
    setState(() => voitures = data);
  }

  void _selectVoiture(Voiture voiture) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(voiture: voiture)),
    );
  }

  void _showAddCarDialog() {
    final marqueController = TextEditingController();
    final modeleController = TextEditingController();
    final anneeController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter une voiture'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: marqueController,
              decoration: const InputDecoration(labelText: 'Marque'),
            ),
            TextField(
              controller: modeleController,
              decoration: const InputDecoration(labelText: 'Modèle'),
            ),
            TextField(
              controller: anneeController,
              decoration: const InputDecoration(labelText: 'Année'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (marqueController.text.isEmpty ||
                  modeleController.text.isEmpty ||
                  anneeController.text.isEmpty) {
                return;
              }

              final voiture = Voiture(
                marque: marqueController.text,
                modele: modeleController.text,
                annee: int.parse(anneeController.text),
              );

              await dbHelper.insertVoiture(voiture);
              _loadVoitures();
              Navigator.pop(dialogContext);
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVoiture(int id) async {
    bool confirm = await _showConfirmationDialog(
        "Supprimer cette voiture ?", "Voulez-vous vraiment supprimer cette voiture et tous ses entretiens ?");
    if (confirm) {
      await dbHelper.deleteVoiture(id);
      _loadVoitures();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélectionnez une voiture')),
      body: ListView.builder(
        itemCount: voitures.length,
        itemBuilder: (context, index) {
          final voiture = voitures[index];
          return ListTile(
            title: Text('${voiture.marque} ${voiture.modele} (${voiture.annee})'),
            onTap: () => _selectVoiture(voiture),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDeleteVoiture(voiture.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: _showAddCarDialog,
      ),
    );
  }
}
