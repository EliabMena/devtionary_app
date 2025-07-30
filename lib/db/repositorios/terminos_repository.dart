import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/terminos.dart';
import '../database_helper.dart';

class TerminosRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener los términos desde la API
  Future<List<Terminos>> fetchTerminos() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/terminos'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Terminos usando el método fromJson
        List<Terminos> terminos = jsonData
            .map((json) => Terminos.fromJson(json as Map<String, dynamic>))
            .toList();

        return terminos;
      } else {
        String errorMessage = _getErrorMessage(response.statusCode);
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión: $e');
    }
  }

  // Método principal de sincronización de términos
  Future<void> sincronizarTerminos() async {
    try {
      // Paso 1: Revisar la tabla de términos local
      List<Terminos> terminosLocales = await _getTerminosLocales();

      // Obtener términos desde la API
      List<Terminos> terminosAPI = await fetchTerminos();

      // Paso 2: Comparar e insertar/actualizar datos
      if (terminosLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todos los términos de la API
        await _insertarTodosLosTerminos(terminosAPI);
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(terminosLocales, terminosAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener términos locales
  Future<List<Terminos>> _getTerminosLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('terminos');

    return List<Terminos>.from(maps.map((m) => Terminos.fromJson(m)));
  }

  // Método auxiliar para insertar todos los términos
  Future<void> _insertarTodosLosTerminos(List<Terminos> terminos) async {
    final db = await DatabaseHelper.database;

    for (Terminos termino in terminos) {
      await db.insert('terminos', termino.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Terminos> locales,
    List<Terminos> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de términos locales
    Map<int, Terminos> localesMap = {
      for (var termino in locales) termino.id_termino: termino,
    };

    int actualizadas = 0;
    int insertadas = 0;

    // Revisar términos de la API
    for (Terminos terminoAPI in api) {
      Terminos? terminoLocal = localesMap[terminoAPI.id_termino];

      if (terminoLocal == null) {
        // Situación 3: Nuevo término en la API - insertarlo
        await db.insert('terminos', terminoAPI.toJson());
        insertadas++;
      } else if (terminoLocal.fecha_actualizacion !=
          terminoAPI.fecha_actualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'terminos',
          terminoAPI.toJson(),
          where: 'id_termino = ?',
          whereArgs: [terminoAPI.id_termino],
        );
        actualizadas++;
      }
      // Situación 2.1: Fechas iguales - no hacer nada
    }
  }

  Future<List<Terminos>> getTerminos() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('terminos');

    return List<Terminos>.from(maps.map((m) => Terminos.fromJson(m)));
  }

  // Método para obtener términos por nombre de subcategoría
  Future<List<Terminos>> getTerminosPorSubcategoria(
    String nombreSubcategoria,
  ) async {
    final db = await DatabaseHelper.database;

    // Realizar JOIN entre las tablas terminos y subcategorias
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT t.* 
      FROM terminos t
      INNER JOIN subcategorias s ON t.id_subcategoria = s.id_subcategoria
      WHERE s.nombre = ?
      ORDER BY t.nombre_termino ASC
    ''',
      [nombreSubcategoria],
    );

    return List.generate(maps.length, (i) {
      return Terminos.fromJson(maps[i]);
    });
  }

  // Método para buscar términos por nombre (búsqueda exacta o parcial)
  Future<List<Terminos>> buscarTerminosPorNombre(String nombre) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'terminos',
      where: 'nombre_termino LIKE ?',
      whereArgs: ['%$nombre%'],
      orderBy: 'nombre_termino ASC',
    );

    return List.generate(maps.length, (i) {
      return Terminos.fromJson(maps[i]);
    });
  }

  // Método para buscar términos por palabras en la descripción
  Future<List<Terminos>> buscarTerminosPorDescripcion(
    String palabraClave,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'terminos',
      where: 'descripcion LIKE ?',
      whereArgs: ['%$palabraClave%'],
      orderBy: 'nombre_termino ASC',
    );

    return List.generate(maps.length, (i) {
      return Terminos.fromJson(maps[i]);
    });
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'No autorizado';
      case 403:
        return 'Acceso denegado';
      case 404:
        return 'Endpoint no encontrado';
      case 500:
        return 'Error interno del servidor';
      default:
        return 'Error del servidor: $statusCode';
    }
  }
}
