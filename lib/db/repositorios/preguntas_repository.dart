import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:devtionary_app/db/db_models/preguntas.dart';
import 'package:devtionary_app/db/database_helper.dart';

class PreguntasRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener las preguntas desde la API
  Future<List<Preguntas>> fetchPreguntas() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/preguntas'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Preguntas usando el método fromJson
        List<Preguntas> preguntas = jsonData
            .map((json) => Preguntas.fromJson(json as Map<String, dynamic>))
            .toList();

        return preguntas;
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

  // Método principal de sincronización de preguntas
  Future<void> sincronizarPreguntas() async {
    try {
      // Paso 1: Revisar la tabla de preguntas local
      List<Preguntas> preguntasLocales = await _getPreguntasLocales();

      // Obtener preguntas desde la API
      List<Preguntas> preguntasAPI = await fetchPreguntas();

      // Paso 2: Comparar e insertar/actualizar datos
      if (preguntasLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todas las preguntas de la API
        await _insertarTodasLasPreguntas(preguntasAPI);
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(preguntasLocales, preguntasAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener preguntas locales
  Future<List<Preguntas>> _getPreguntasLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('preguntas');

    return List.generate(maps.length, (i) {
      return Preguntas.fromJson(maps[i]);
    });
  }

  // Método auxiliar para insertar todas las preguntas
  Future<void> _insertarTodasLasPreguntas(List<Preguntas> preguntas) async {
    final db = await DatabaseHelper.database;

    for (Preguntas pregunta in preguntas) {
      await db.insert('preguntas', pregunta.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Preguntas> locales,
    List<Preguntas> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de preguntas locales
    Map<int, Preguntas> localesMap = {
      for (var pregunta in locales) pregunta.id_pregunta: pregunta,
    };

    // Revisar preguntas de la API
    for (Preguntas preguntaAPI in api) {
      Preguntas? preguntaLocal = localesMap[preguntaAPI.id_pregunta];

      if (preguntaLocal == null) {
        // Situación 3: Nueva pregunta en la API - insertarla
        await db.insert('preguntas', preguntaAPI.toJson());
      } else if (preguntaLocal.fecha_actualizacion !=
          preguntaAPI.fecha_actualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'preguntas',
          preguntaAPI.toJson(),
          where: 'id_pregunta = ?',
          whereArgs: [preguntaAPI.id_pregunta],
        );
      }
      // Situación 2.1: Fechas iguales - no hacer nada
    }
  }

  // Método para obtener todas las preguntas
  Future<List<Preguntas>> getPreguntas() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('preguntas');

    return List.generate(maps.length, (i) {
      return Preguntas.fromJson(maps[i]);
    });
  }

  // Método para obtener preguntas por categoría
  Future<List<Preguntas>> getPreguntasPorCategoria(
    String nombreCategoria,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT p.* FROM preguntas p
      INNER JOIN categorias c ON p.id_categoria = c.id_categoria
      WHERE c.nombre = ? 
      ORDER BY pregunta ASC
    ''',
      [nombreCategoria],
    );

    return List.generate(maps.length, (i) {
      return Preguntas.fromJson(maps[i]);
    });
  }

  // Método para obtener preguntas aleatorias por categoría
  Future<List<Preguntas>> getPreguntasAleatoriasPorCategoria(
    String nombreCategoria,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      //Cambiando el limit se puede cambiar la cantidad de preguntas
      '''
      SELECT p.pregunta, 
      p.respuesta_correcta, 
      p.respuesta_incorrecta_1, 
      p.respuesta_incorrecta_2, 
      p.respuesta_incorrecta_3, 
      sc.nombre FROM preguntas p
      inner join subcategorias sc ON p.id_subcategoria = sc.id_subcategoria
      inner join categorias c ON p.id_categoria = c.id_categoria
      WHERE nombre = ? 
      ORDER BY RANDOM() 
      LIMIT 10
    ''',
      [nombreCategoria],
    );

    return List.generate(maps.length, (i) {
      return Preguntas.fromJson(maps[i]);
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
