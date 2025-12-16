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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE setting (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        background TEXT NULL,
        format_nomor TEXT NULL 
      )
    ''');
  }

  // Insert data
  Future<int> insertItem(String background, String format_nomor) async {
    final db = await instance.database;
    return await db.insert('items', {
      'background': background,
      'format_nomor': format_nomor,
    });
  }

  // Get all data
  Future<List<Map<String, dynamic>>> getItems() async {
    final db = await instance.database;
    return await db.query('items');
  }

  // Update
  Future<int> updateItem(
    int id,
    String background,
    String format_number,
  ) async {
    final db = await instance.database;
    return await db.update(
      'items',
      {'background': background, 'format_number': format_number},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
