import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Entretien Voiture',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
} 

// Modèle d'entretien
class Entretien {
  final int? id;
  final String type;
  final String description;
  final DateTime dateDebut;
  final DateTime? dateExpiration;
  final double prix;
  final int? kilometrageActuel;
  final int? prochainVidange;

  Entretien({
    this.id,
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

// Base de données
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('entretien.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entretien(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        dateDebut TEXT NOT NULL,
        dateExpiration TEXT,
        prix REAL NOT NULL,
        kilometrageActuel INTEGER,
        prochainVidange INTEGER
      )
    ''');
  }

  Future<void> insertEntretien(Entretien entretien) async {
    final db = await database;
    await db.insert('entretien', entretien.toMap());
  }

  Future<List<Entretien>> getAllEntretiens() async {
    final db = await database;
    final result = await db.query('entretien');
    return result.map((map) => Entretien.fromMap(map)).toList();
  }

  Future<void> deleteEntretien(int id) async {
    final db = await database;
    await db.delete('entretien', where: 'id = ?', whereArgs: [id]);
  }
}

// Page principale
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Entretien> entretienList = [];

  @override
  void initState() {
    super.initState();
    _loadEntretiens();
  }

  Future<void> _loadEntretiens() async {
    final data = await dbHelper.getAllEntretiens();
    setState(() => entretienList = data);
  }

  Future<void> _addEntretien(Entretien entretien) async {
    await dbHelper.insertEntretien(entretien);
    _loadEntretiens();
  }

  Future<void> _deleteEntretien(int id) async {
    bool confirm = await _showConfirmationDialog();
    if (confirm) {
      await dbHelper.deleteEntretien(id);
      _loadEntretiens();
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmer la suppression'),
                content: const Text(
                  'Voulez-vous vraiment supprimer cet entretien ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showAddDialog() {
    final typeController = TextEditingController();
    final descriptionController = TextEditingController();
    final prixController = TextEditingController();
    final kmActuelController = TextEditingController();
    final prochainVidangeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    DateTime? expirationDate; // Variable correctement utilisée ici

    void _showError(String message) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Erreur'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Ajouter un entretien'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: prixController,
                    decoration: const InputDecoration(labelText: 'Prix'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: kmActuelController,
                    decoration: const InputDecoration(
                      labelText: 'Kilométrage Actuel',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: prochainVidangeController,
                    decoration: const InputDecoration(
                      labelText: 'Prochain Vidange (si applicable)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
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
                    child: Text(
                      'Date de début: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => expirationDate = date);
                      }
                    },
                    child: Text(
                      expirationDate == null
                          ? 'Choisir la date d\'expiration'
                          : 'Expire le: ${DateFormat('dd/MM/yyyy').format(expirationDate!)}',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  if (typeController.text.isEmpty) {
                    _showError('Le type est requis.');
                    return;
                  }
                  if (prixController.text.isEmpty ||
                      double.tryParse(prixController.text) == null) {
                    _showError('Le prix doit être un nombre valide.');
                    return;
                  }
                  if (kmActuelController.text.isEmpty ||
                      int.tryParse(kmActuelController.text) == null) {
                    _showError(
                      'Le kilométrage actuel doit être un nombre valide.',
                    );
                    return;
                  }

                  _addEntretien(
                    Entretien(
                      type: typeController.text,
                      description: descriptionController.text,
                      dateDebut: selectedDate,
                      dateExpiration:
                          expirationDate, // Ajout de la date d'expiration
                      prix: double.parse(prixController.text),
                      kilometrageActuel: int.parse(kmActuelController.text),
                      prochainVidange:
                          prochainVidangeController.text.isNotEmpty
                              ? int.parse(prochainVidangeController.text)
                              : null,
                    ),
                  );
                  Navigator.pop(dialogContext);
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
      appBar: AppBar(title: const Text('Gestion d\'entretien voiture')),
      body: ListView.builder(
        itemCount: entretienList.length,
        itemBuilder: (context, index) {
          final entretien = entretienList[index];
          return ListTile(
            title: Text('${entretien.type} - ${entretien.description}'),
            subtitle: Text(
              'Prix: ${entretien.prix} DA | Début: ${DateFormat('dd/MM/yyyy').format(entretien.dateDebut)}'
              '${entretien.dateExpiration != null ? ' | Expire: ${DateFormat('dd/MM/yyyy').format(entretien.dateExpiration!)}' : ''}'
              '${entretien.kilometrageActuel != null ? ' | Km: ${entretien.kilometrageActuel}' : ''}'
              '${entretien.prochainVidange != null ? ' | Prochain vidange: ${entretien.prochainVidange} km' : ''}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () => _deleteEntretien(entretien.id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
