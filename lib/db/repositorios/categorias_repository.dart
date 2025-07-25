import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/categorias.dart';
import '../database_helper.dart';

class CategoriasRepository {
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  //Método para obtener las categorías desde la API
  Future<List<Categorias>> fetchCategorias() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/categorias'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonData = json.decode(response.body) as List;

        // Convertir el JSON a una lista de objetos Categorias usando el método fromJson
        List<Categorias> categorias = jsonData
            .map((json) => Categorias.fromJson(json as Map<String, dynamic>))
            .toList();

        return categorias;
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

  // Método principal de sincronización de categorías
  Future<void> sincronizarCategorias() async {
    try {
      // Paso 1: Revisar la tabla de categorías local
      List<Categorias> categoriasLocales = await _getCategoriasLocales();

      // Obtener categorías desde la API
      List<Categorias> categoriasAPI = await fetchCategorias();

      // Paso 2: Comparar e insertar/actualizar datos
      if (categoriasLocales.isEmpty) {
        // Situación 1: La tabla está vacía - insertar todas las categorías de la API
        await _insertarTodasLasCategorias(categoriasAPI);
        print('${categoriasAPI.length} categorías insertadas desde la API');
      } else {
        // Situación 2 y 3: Comparar y sincronizar
        await _compararYSincronizar(categoriasLocales, categoriasAPI);
      }

      // Paso 3: La conexión se cierra automáticamente
      print('Sincronización de categorías completada');
    } catch (e) {
      throw Exception('Error durante la sincronización: $e');
    }
  }

  // Método auxiliar para obtener categorías locales
  Future<List<Categorias>> _getCategoriasLocales() async {
    final db = await DatabaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categorias');

    return List.generate(maps.length, (i) {
      return Categorias.fromJson(maps[i]);
    });
  }

  // Método auxiliar para insertar todas las categorías
  Future<void> _insertarTodasLasCategorias(List<Categorias> categorias) async {
    final db = await DatabaseHelper.database;

    for (Categorias categoria in categorias) {
      await db.insert('categorias', categoria.toJson());
    }
  }

  // Método auxiliar para comparar y sincronizar
  Future<void> _compararYSincronizar(
    List<Categorias> locales,
    List<Categorias> api,
  ) async {
    final db = await DatabaseHelper.database;

    // Crear mapa para búsqueda rápida de categorías locales
    Map<int, Categorias> localesMap = {
      for (var cat in locales) cat.id_categoria: cat,
    };

    int actualizadas = 0;
    int insertadas = 0;

    // Revisar categorías de la API
    for (Categorias categoriaAPI in api) {
      Categorias? categoriaLocal = localesMap[categoriaAPI.id_categoria];

      if (categoriaLocal == null) {
        // Situación 3: Nueva categoría en la API - insertarla
        await db.insert('categorias', categoriaAPI.toJson());
        insertadas++;
      } else if (categoriaLocal.fechaActualizacion !=
          categoriaAPI.fechaActualizacion) {
        // Situación 2.2: Fechas diferentes - actualizar
        await db.update(
          'categorias',
          categoriaAPI.toJson(),
          where: 'id_categoria = ?',
          whereArgs: [categoriaAPI.id_categoria],
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
}
