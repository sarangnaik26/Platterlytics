import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('platterlytics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported for File Database');
    }

    // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //   sqfliteFfiInit();
    //   databaseFactory = databaseFactoryFfi;
    // }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        priority INTEGER NOT NULL
      )
    ''');

    // Insert Default Category
    // Using integer value for color (0xFF6A1B9A)
    await db.insert('categories', {
      'name': 'Menu',
      'color': 4285143962, // 0xFF6A1B9A as int
      'priority': 1,
    });

    // Menu Table
    await db.execute('''
      CREATE TABLE menu (
        menu_id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Menu Prices Table
    await db.execute('''
      CREATE TABLE menu_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id INTEGER NOT NULL,
        unit TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (menu_id) REFERENCES menu (menu_id) ON DELETE CASCADE
      )
    ''');

    // Bill Table
    await db.execute('''
      CREATE TABLE bill (
        bill_id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_price REAL NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL
      )
    ''');

    // Bill Items Table
    await db.execute('''
      CREATE TABLE bill_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bill_id INTEGER NOT NULL,
        menu_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        unit TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total_item_price REAL NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bill (bill_id) ON DELETE CASCADE,
        FOREIGN KEY (menu_id) REFERENCES menu (menu_id)
      )
    ''');

    // Bill Settings Table
    await db.execute('''
      CREATE TABLE bill_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_name TEXT,
        address TEXT,
        contact_info TEXT,
        footer_enabled INTEGER NOT NULL DEFAULT 0,
        footer_text TEXT
      )
    ''');

    // Insert Default Bill Settings
    await db.insert('bill_settings', {
      'business_name': 'My Restaurant',
      'address': '123 Food Street',
      'contact_info': '123-456-7890',
      'footer_enabled': 0,
      'footer_text': 'Thank you for dining with us!',
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
