import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/subcategorias.dart';
import '../database_helper.dart';

class SubcategoriasRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener las subcategorías desde la API
  Future<List<Subcategorias>> fetchSubcategorias() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/subcategorias'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Subcategorias usando el método fromJson
        List<Subcategorias> subcategorias = jsonData
            .map((json) => Subcategorias.fromJson(json as Map<String, dynamic>))
            .toList();

        return subcategorias;
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

  // Método principal de sincronización de subcategorías
  Future<void> sincronizarSubcategorias() async {
    try {
      // Paso 1: Revisar la tabla de subcategorías local
      List<Subcategorias> subcategoriasLocales =
          await _getSubcategoriasLocales();

      // Obtener subcategorías desde la API
      List<Subcategorias> subcategoriasAPI = await fetchSubcategorias();

      // Paso 2: Comparar e insertar/actualizar datos
      if (subcategoriasLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todas las subcategorías de la API
        await _insertarTodasLasSubcategorias(subcategoriasAPI);
        print(
          '${subcategoriasAPI.length} subcategorías insertadas desde la API',
        );
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(subcategoriasLocales, subcategoriasAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
      print('Sincronización de subcategorías completada');
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener subcategorías locales
  Future<List<Subcategorias>> _getSubcategoriasLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('subcategorias');

    return List.generate(maps.length, (i) {
      return Subcategorias.fromJson(maps[i]);
    });
  }

  // Método auxiliar para insertar todas las subcategorías
  Future<void> _insertarTodasLasSubcategorias(
    List<Subcategorias> subcategorias,
  ) async {
    final db = await DatabaseHelper.database;

    for (Subcategorias subcategoria in subcategorias) {
      await db.insert('subcategorias', subcategoria.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Subcategorias> locales,
    List<Subcategorias> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de subcategorías locales
    Map<int, Subcategorias> localesMap = {
      for (var subcat in locales) subcat.id_subcategoria: subcat,
    };

    int actualizadas = 0;
    int insertadas = 0;

    // Revisar subcategorías de la API
    for (Subcategorias subcategoriaAPI in api) {
      Subcategorias? subcategoriaLocal =
          localesMap[subcategoriaAPI.id_subcategoria];

      if (subcategoriaLocal == null) {
        // Situación 3: Nueva subcategoría en la API - insertarla
        await db.insert('subcategorias', subcategoriaAPI.toJson());
        insertadas++;
      } else if (subcategoriaLocal.fecha_actualizacion !=
          subcategoriaAPI.fecha_actualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'subcategorias',
          subcategoriaAPI.toJson(),
          where: 'id_subcategoria = ?',
          whereArgs: [subcategoriaAPI.id_subcategoria],
        );
        actualizadas++;
      }
      // Situación 2.1: Fechas iguales - no hacer nada
    }

    print(
      'Sincronización completada: $insertadas insertadas, $actualizadas actualizadas',
    );
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

  /// Método público para obtener subcategorías locales
  Future<List<Subcategorias>> getSubcategoriasLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('subcategorias');
    return List.generate(maps.length, (i) {
      return Subcategorias.fromJson(maps[i]);
    });
  }
}
