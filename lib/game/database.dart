import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final _databaseName = "game_data.db";
  static final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Определяем путь к базе данных для web
    String dbPath = '';
    if (kIsWeb) {
      dbPath = 'web/game_data.db';
    } else {
      dbPath = await getDatabasesPath();
      dbPath = join(dbPath, _databaseName);
    }

    // Проверяем, существует ли файл базы данных в папке приложения
    if (!File(dbPath).existsSync()) {
      // Читаем файл базы данных из ресурсов приложения
      final data = await rootBundle.load('assets/$_databaseName');
      final buffer = data.buffer;

      // Создаем файл базы данных и пишем в него данные из ресурсов
      await File(dbPath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        flush: true,
      );
    }

    // Используем sqflite_common_ffi_web для web
    final factory = kIsWeb ? databaseFactoryFfiWeb : databaseFactory;

    return await factory.openDatabase(dbPath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: (db, version) async {
          // Создание таблиц при создании базы данных
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          // Обновление таблиц при обновлении базы данных
        },
      ),
    );
  }
}
