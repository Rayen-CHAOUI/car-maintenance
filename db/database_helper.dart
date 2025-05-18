import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/voiture.dart';
import '../models/entretien.dart';

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
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE voitures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marque TEXT NOT NULL,
        modele TEXT NOT NULL,
        annee INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE entretien (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voiture_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        dateDebut TEXT NOT NULL,
        dateExpiration TEXT,
        prix REAL NOT NULL,
        kilometrageActuel INTEGER,
        prochainVidange INTEGER,
        FOREIGN KEY (voiture_id) REFERENCES voitures(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertVoiture(Voiture voiture) async {
    final db = await database;
    await db.insert('voitures', voiture.toMap());
  }

  Future<List<Voiture>> getAllVoitures() async {
    final db = await database;
    final result = await db.query('voitures');
    return result.map((map) => Voiture.fromMap(map)).toList();
  }

  Future<void> deleteVoiture(int id) async {
    final db = await database;
    await db.delete('voitures', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertEntretien(Entretien entretien) async {
    final db = await database;
    await db.insert('entretien', entretien.toMap());
  }

  Future<List<Entretien>> getEntretiensByVoiture(int voitureId) async {
    final db = await database;
    final result = await db.query(
      'entretien',
      where: 'voiture_id = ?',
      whereArgs: [voitureId],
    );
    return result.map((map) => Entretien.fromMap(map)).toList();
  }

  Future<void> deleteEntretien(int id) async {
    final db = await database;
    await db.delete('entretien', where: 'id = ?', whereArgs: [id]);
  }
}
