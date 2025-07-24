import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  // Obtener la base de datos (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Inicializar base de datos
    _database = await _initDB('base_datos.db');
    return _database!;
  }
  // Crear la base de datos
  static Future<Database> _initDB(String fileName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  // Crear tabla
  static Future _createDB(Database db, int version) async {
    await db.transaction((txn) async {
      //Crear la tabla de categorías
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS categorias (
          id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
        )
      ''');
      //Crear la tabla de subcategorías
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS subcategorias(
          id_subcategoria INTEGER PRIMARY KEY AUTOINCREMENT,
          id_categoria INTEGER,
          nombre TEXT NOT NULL,
          fecha_creacion TEXT,
          fecha_actualizacion TEXT,
          FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
          )
        ''');
      //Crear la tabla de términos
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS terminos ()
          id_termino INTEGER PRIMARY KEY AUTOINCREMENT,
          id_subcategoria INTEGER,
          nombre_termino TEXT NOT NULL,
          descripcion REAL NOT NULL,
          ejemplo INTEGER NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria
        )
      ''');
      //Crear la tabla de comandos
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS comandos (
          id_comando INTEGER PRIMARY KEY AUTOINCREMENT,
          id_subcategoria INTEGER,
          nombre_comando TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          ejemplo TEXT NOT NULL,
          ejemplo_2 TEXT NOT NULL,
          ejemplo_3 TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
      )''');
      //Crear la tabla de instrucciones
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS instrucciones (
          id_instruccion INTEGER PRIMARY KEY AUTOINCREMENT,
          id_subcategoria INTEGER,
          nombre_instruccion TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          ejemplo TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
      )''');
    });
  }

  }
