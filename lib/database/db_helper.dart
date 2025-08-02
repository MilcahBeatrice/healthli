import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'healthli.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users_local (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        age INTEGER,
        gender TEXT,
        profile_image TEXT,
        is_synced INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE symptoms (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        name TEXT,
        uses TEXT,
        side_effects TEXT,
        dosage TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE cached_doctors (
        id TEXT PRIMARY KEY,
        name TEXT,
        specialization TEXT,
        location TEXT,
        contact TEXT,
        last_viewed TEXT,
        interaction_type TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        content TEXT,
        comments TEXT,
        saved_by TEXT,
        tags TEXT,
        likes INTEGER,
        is_synced INTEGER,
        created_at TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        post_id TEXT,
        user_id TEXT,
        text TEXT,
        created_at TEXT,
        is_synced INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE interactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        interaction_type TEXT,
        value TEXT,
        timestamp TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        name TEXT,
        phone TEXT,
        relationship TEXT,
        is_synced INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE records (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      title TEXT,
      description TEXT,
      timestamp TEXT,
      is_synced INTEGER
    )
  ''');
  }
}
