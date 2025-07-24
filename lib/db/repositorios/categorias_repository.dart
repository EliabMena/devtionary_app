/*import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db_models/categorias.dart';
import '../../models/service_result.dart';
class CategoriasRepository {

  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app/api/ReDatabase';
  static const Duration _timeout = Duration(seconds: 50);

  Future<ServiceResult<Map<String, dynamic>>> fetchCategorias() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      http.Response response = await http
          .get(Uri.parse('$_baseUrl/categorias'))
          .timeout(_timeout);
// Aún no se bien como se trabaja esta parte, por lo que la dejaré comentada
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        return ServiceResult.success(userData);
      } else {
        String errorMessage = _getErrorMessage(response.statusCode);
        return ServiceResult.error(errorMessage);
      }
    } on TimeoutException {
      return ServiceResult.error('Tiempo de espera agotado');
    } catch (e) {
      return ServiceResult.error('Error de conexión: $e');
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401: return 'No autorizado';
      case 403: return 'Acceso denegado';
      case 404: return 'Endpoint no encontrado';
      case 500: return 'Error interno del servidor';
      default: return 'Error del servidor: $statusCode';
    }
  }
}*/