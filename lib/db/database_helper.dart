import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:devtionary_app/db/repositorios/comandos_repository.dart';
import 'package:devtionary_app/db/repositorios/terminos_repository.dart';
import 'package:devtionary_app/db/repositorios/instrucciones_repository.dart';
import 'package:devtionary_app/db/repositorios/preguntas_repository.dart';
import 'package:devtionary_app/db/repositorios/subcategorias_repository.dart';
import 'package:devtionary_app/db/repositorios/categorias_repository.dart';

class DatabaseHelper {
  // Buscar palabra por nombre en terminos, comandos e instrucciones

  static Future<Map<String, dynamic>?> buscarPorNombre(String nombre) async {
    // Crear instancias de los repositorios
    final terminosRepo = TerminosRepository();
    final comandosRepo = ComandosRepository();
    final instruccionesRepo = InstruccionesRepository();

    // Buscar en terminos usando el repositorio
    final terminos = await terminosRepo.buscarTerminosPorNombre(nombre);
    if (terminos.isNotEmpty) {
      // Convertir el objeto Terminos a Map y agregar info de tabla
      return {'tabla': 'terminos', ...terminos.first.toJson()};
    }

    // Buscar en comandos usando el repositorio
    final comandos = await comandosRepo.buscarComandosPorNombre(nombre);
    if (comandos.isNotEmpty) {
      return {'tabla': 'comandos', ...comandos.first.toJson()};
    }

    // Buscar en instrucciones usando el repositorio
    final instrucciones = await instruccionesRepo.buscarInstruccionesPorNombre(
      nombre,
    );
    if (instrucciones.isNotEmpty) {
      return {'tabla': 'instrucciones', ...instrucciones.first.toJson()};
    }

    return null;
  }

  // Método para sincronizar todos los datos
  static Future<void> sincronizarDatos() async {
    CategoriasRepository CatRepo = CategoriasRepository();
    SubcategoriasRepository SubCatRepo = SubcategoriasRepository();
    TerminosRepository TermRepo = TerminosRepository();
    ComandosRepository ComRepo = ComandosRepository();
    InstruccionesRepository InstruRepo = InstruccionesRepository();
    PreguntasRepository PregRepo = PreguntasRepository();
    try {
      // Sincronizar categorías
      await CatRepo.sincronizarCategorias();
      // Sincronizar subcategorías
      await SubCatRepo.sincronizarSubcategorias();
      // Sincronizar términos
      await TermRepo.sincronizarTerminos();
      // Sincronizar comandos
      await ComRepo.sincronizarComandos();
      // Sincronizar instrucciones
      await InstruRepo.sincronizarInstrucciones();
      // Sincronizar preguntas
      await PregRepo.sincronizarPreguntas();
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

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

  // Crear las tablas
  static Future _createDB(Database db, int version) async {
    await db.transaction((txn) async {
      //Crear la tabla de categorías
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS categorias (
          id_categoria INTEGER PRIMARY KEY,
          nombre TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL
        )
      ''');
      //Crear la tabla de subcategorías
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS subcategorias(
          id_subcategoria INTEGER PRIMARY KEY,
          id_categoria INTEGER,
          nombre TEXT NOT NULL,
          fecha_creacion TEXT,
          fecha_actualizacion TEXT,
          FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
          )
        ''');
      //Crear la tabla de términos
      await txn.execute('''
      CREATE TABLE IF NOT EXISTS terminos (
          id_termino INTEGER PRIMARY KEY,
          id_subcategoria INTEGER,
          nombre_termino TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          ejemplo TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
          )
      ''');
      //Crear la tabla de comandos
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS comandos (
          id_comando INTEGER PRIMARY KEY,
          id_subcategoria INTEGER,
          nombre_comando TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          ejemplo TEXT NOT NULL,
          ejemplo_2 TEXT NOT NULL,
          ejemplo_3 TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
          )
        ''');
      //Crear la tabla de instrucciones
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS instrucciones (
          id_instruccion INTEGER PRIMARY KEY,
          id_subcategoria INTEGER,
          nombre_instruccion TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          ejemplo TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
          )
      ''');
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS preguntas (
          id_pregunta INTEGER PRIMARY KEY,
          id_categoria INTEGER,
          id_subcategoria INTEGER,
          pregunta TEXT NOT NULL,
          respuesta_correcta TEXT NOT NULL,
          respuesta_incorrecta_1 TEXT NOT NULL,
          respuesta_incorrecta_2 TEXT NOT NULL,
          respuesta_incorrecta_3 TEXT NOT NULL,
          fecha_creacion TEXT NOT NULL,
          fecha_actualizacion TEXT NOT NULL,
          FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
          FOREIGN KEY (id_subcategoria) REFERENCES subcategorias(id_subcategoria)
        )
      ''');
    });
  }
}
