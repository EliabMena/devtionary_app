import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/comandos.dart';
import '../database_helper.dart';

class ComandosRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener los comandos desde la API
  Future<List<Comandos>> fetchComandos() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/comandos'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Comandos usando el método fromJson
        List<Comandos> comandos = jsonData
            .map((json) => Comandos.fromJson(json as Map<String, dynamic>))
            .toList();

        return comandos;
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

  // Método principal de sincronización de comandos
  Future<void> sincronizarComandos() async {
    try {
      // Paso 1: Revisar la tabla de comandos local
      List<Comandos> comandosLocales = await _getComandosLocales();

      // Obtener comandos desde la API
      List<Comandos> comandosAPI = await fetchComandos();

      // Paso 2: Comparar e insertar/actualizar datos
      if (comandosLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todos los comandos de la API
        await _insertarTodosLosComandos(comandosAPI);
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(comandosLocales, comandosAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener comandos locales
  Future<List<Comandos>> _getComandosLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('comandos');

    return List.generate(maps.length, (i) {
      return Comandos.fromJson(maps[i]);
    });
  }

  // Método auxiliar para insertar todos los comandos
  Future<void> _insertarTodosLosComandos(List<Comandos> comandos) async {
    final db = await DatabaseHelper.database;

    for (Comandos comando in comandos) {
      await db.insert('comandos', comando.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Comandos> locales,
    List<Comandos> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de comandos locales
    Map<int, Comandos> localesMap = {
      for (var comando in locales) comando.id_comando: comando,
    };

    // Revisar comandos de la API
    for (Comandos comandoAPI in api) {
      Comandos? comandoLocal = localesMap[comandoAPI.id_comando];

      if (comandoLocal == null) {
        // Situación 3: Nuevo comando en la API - insertarlo
        await db.insert('comandos', comandoAPI.toJson());
      } else if (comandoLocal.fecha_actualizacion !=
          comandoAPI.fecha_actualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'comandos',
          comandoAPI.toJson(),
          where: 'id_comando = ?',
          whereArgs: [comandoAPI.id_comando],
        );
      }
      // Situación 2.1: Fechas iguales - no hacer nada
    }
  }

  Future<List<Comandos>> getComandos() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('comandos');

    return List.generate(maps.length, (i) {
      return Comandos.fromJson(maps[i]);
    });
  }

  // Método para obtener comandos por nombre de subcategoría
  Future<List<Comandos>> getComandosPorSubcategoria(
    String nombreSubcategoria,
  ) async {
    final db = await DatabaseHelper.database;

    // Realizar JOIN entre las tablas comandos y subcategorias
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.* 
      FROM comandos c
      INNER JOIN subcategorias s ON c.id_subcategoria = s.id_subcategoria
      WHERE s.nombre = ?
      ORDER BY c.nombre_comando ASC
    ''',
      [nombreSubcategoria],
    );

    return List.generate(maps.length, (i) {
      return Comandos.fromJson(maps[i]);
    });
  }

  // Método para buscar comandos por nombre (búsqueda parcial)
  Future<List<Comandos>> buscarComandosPorNombre(String nombre) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'comandos',
      where: 'nombre_comando LIKE ?',
      whereArgs: ['%$nombre%'],
      orderBy: 'nombre_comando ASC',
    );

    return List.generate(maps.length, (i) {
      return Comandos.fromJson(maps[i]);
    });
  }

  // Método para buscar comandos por palabras en la descripción
  Future<List<Comandos>> buscarComandosPorDescripcion(
    String palabraClave,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'comandos',
      where: 'descripcion LIKE ?',
      whereArgs: ['%$palabraClave%'],
      orderBy: 'nombre_comando ASC',
    );

    return List.generate(maps.length, (i) {
      return Comandos.fromJson(maps[i]);
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
