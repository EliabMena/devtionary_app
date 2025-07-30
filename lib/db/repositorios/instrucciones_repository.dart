import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/instrucciones.dart';
import '../database_helper.dart';

class InstruccionesRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener las instrucciones desde la API
  Future<List<Instrucciones>> fetchInstrucciones() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/instrucciones'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Instrucciones usando el método fromJson
        List<Instrucciones> instrucciones = jsonData
            .map((json) => Instrucciones.fromJson(json as Map<String, dynamic>))
            .toList();

        return instrucciones;
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

  // Método principal de sincronización de instrucciones
  Future<void> sincronizarInstrucciones() async {
    try {
      // Paso 1: Revisar la tabla de instrucciones local
      List<Instrucciones> instruccionesLocales =
          await _getInstruccionesLocales();

      // Obtener instrucciones desde la API
      List<Instrucciones> instruccionesAPI = await fetchInstrucciones();

      // Paso 2: Comparar e insertar/actualizar datos
      if (instruccionesLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todas las instrucciones de la API
        await _insertarTodasLasInstrucciones(instruccionesAPI);
        print(
          '${instruccionesAPI.length} instrucciones insertadas desde la API',
        );
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(instruccionesLocales, instruccionesAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
      print('Sincronización de instrucciones completada');
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener instrucciones locales
  Future<List<Instrucciones>> _getInstruccionesLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('instrucciones');

    return List.generate(maps.length, (i) {
      return Instrucciones.fromJson(maps[i]);
    });
  }

  // Método auxiliar para insertar todas las instrucciones
  Future<void> _insertarTodasLasInstrucciones(
    List<Instrucciones> instrucciones,
  ) async {
    final db = await DatabaseHelper.database;

    for (Instrucciones instruccion in instrucciones) {
      await db.insert('instrucciones', instruccion.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Instrucciones> locales,
    List<Instrucciones> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de instrucciones locales
    Map<int, Instrucciones> localesMap = {
      for (var instruccion in locales) instruccion.id_instruccion: instruccion,
    };

    int actualizadas = 0;
    int insertadas = 0;

    // Revisar instrucciones de la API
    for (Instrucciones instruccionAPI in api) {
      Instrucciones? instruccionLocal =
          localesMap[instruccionAPI.id_instruccion];

      if (instruccionLocal == null) {
        // Situación 3: Nueva instrucción en la API - insertarla
        await db.insert('instrucciones', instruccionAPI.toJson());
        insertadas++;
      } else if (instruccionLocal.fecha_actualizacion !=
          instruccionAPI.fecha_actualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'instrucciones',
          instruccionAPI.toJson(),
          where: 'id_instruccion = ?',
          whereArgs: [instruccionAPI.id_instruccion],
        );
        actualizadas++;
      }
      // Situación 2.1: Fechas iguales - no hacer nada
    }

    print(
      'Sincronización completada: $insertadas insertadas, $actualizadas actualizadas',
    );
  }

  Future<List<Instrucciones>> getInstrucciones() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('instrucciones');

    return List.generate(maps.length, (i) {
      return Instrucciones.fromJson(maps[i]);
    });
  }

  // Método para obtener instrucciones por nombre de subcategoría
  Future<List<Instrucciones>> getInstruccionesPorSubcategoria(
    String nombreSubcategoria,
  ) async {
    final db = await DatabaseHelper.database;

    // Realizar JOIN entre las tablas instrucciones y subcategorias
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT i.* 
      FROM instrucciones i
      INNER JOIN subcategorias s ON i.id_subcategoria = s.id_subcategoria
      WHERE s.nombre = ?
      ORDER BY i.nombre_instruccion ASC
    ''',
      [nombreSubcategoria],
    );

    return List.generate(maps.length, (i) {
      return Instrucciones.fromJson(maps[i]);
    });
  }

  // Método para buscar instrucciones por nombre (búsqueda parcial)
  Future<List<Instrucciones>> buscarInstruccionesPorNombre(
    String nombre,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'instrucciones',
      where: 'nombre_instruccion LIKE ?',
      whereArgs: ['%$nombre%'],
      orderBy: 'nombre_instruccion ASC',
    );

    return List.generate(maps.length, (i) {
      return Instrucciones.fromJson(maps[i]);
    });
  }

  // Método para buscar instrucciones por palabras en la descripción
  Future<List<Instrucciones>> buscarInstruccionesPorDescripcion(
    String palabraClave,
  ) async {
    final db = await DatabaseHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'instrucciones',
      where: 'descripcion LIKE ?',
      whereArgs: ['%$palabraClave%'],
      orderBy: 'nombre_instruccion ASC',
    );

    return List.generate(maps.length, (i) {
      return Instrucciones.fromJson(maps[i]);
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
