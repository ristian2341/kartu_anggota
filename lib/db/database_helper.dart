import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_anggota.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE setting (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        background TEXT,
        format_nomor TEXT
      )
    ''');
  }

  // 🔹 CEK DATA
  Future<List<Map<String, dynamic>>> getSetting() async {
    final db = await database;
    return await db.query('setting', limit: 1);
  }

  // 🔹 INSERT / UPDATE (UPSERT)
  Future<void> saveSetting(String background, String formatNomor) async {
    final db = await database;
    final data = await getSetting();

    if (data.isEmpty) {
      // INSERT
      await db.insert('setting', {
        'background': background,
        'format_nomor': formatNomor,
      });
    } else {
      // UPDATE
      await db.update(
        'setting',
        {
          'background': background,
          'format_nomor': formatNomor,
        },
        where: 'id = ?',
        whereArgs: [data.first['id']],
      );
    }
  }
}
