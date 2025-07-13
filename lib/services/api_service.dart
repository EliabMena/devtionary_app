import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/service_result.dart';

class ApiService {
  // URL para las solicitudes a la API
  //Por el momento, se usa localhost para pruebas
  static const String _baseUrl =
      'https://devtionary-api-production.up.railway.app';

  // Instancia del AuthService para obtener tokens
  final AuthService _authService = AuthService();

  // Timeout para peticiones HTTP (30 segundos)
  static const Duration _timeout = Duration(seconds: 50);

  // HEADERS Y UTILIDADES

  // Obtiene headers con token de autorización
  Future<Map<String, String>?> _getHeaders() async {
    try {
      String? token = await _authService.getCurrentToken();
      if (token == null) {
        print('No hay token disponible');
        return null;
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error obteniendo headers: $e');
      return null;
    }
  }

  // Obtiene headers con token personalizado
  Map<String, String> _getHeadersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.trim()}',
    };
  }

  // Registra un nuevo usuario en el backend
  Future<ServiceResult<Map<String, dynamic>>> registerUser({
    required String email,
    required String username,
    required String firebaseToken,
  }) async {
    try {
      // Preparar headers con token
      Map<String, String> headers = _getHeadersWithToken(firebaseToken);

      // Preparar body de la petición
      Map<String, dynamic> body = {'email': email, 'username': username};

      // Hacer petición POST
      http.Response response = await http
          .post(
            Uri.parse('$_baseUrl/api/user/create'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 201) {
        // Usuario registrado exitosamente
        Map<String, dynamic> responseData = json.decode(response.body);
        return ServiceResult.success(responseData);
      } else if (response.statusCode == 409) {
        // Usuario ya existe
        return ServiceResult.error('Ya existe un usuario con este email');
      } else {
        _handleHttpError(response, 'registerUser');
        return ServiceResult.error(
          'Error del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en registerUser: $e');
      return ServiceResult.error('Error de conexión: $e');
    }
  }

  // Obtiene el perfil del usuario con token personalizado
  Future<ServiceResult<Map<String, dynamic>>> getUserProfile({
    required String firebaseToken,
  }) async {
    try {
      // Preparar headers con token
      Map<String, String> headers = _getHeadersWithToken(firebaseToken);

      // Hacer petición GET
      http.Response response = await http
          .get(Uri.parse('$_baseUrl/api/user/profile'), headers: headers)
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        return ServiceResult.success(userData);
      } else if (response.statusCode == 404) {
        return ServiceResult.error('Perfil de usuario no encontrado');
      } else {
        _handleHttpError(response, 'getUserProfile');
        return ServiceResult.error(
          'Error del servidor: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error en getUserProfile: $e');
      return ServiceResult.error('Error de conexión: $e');
    }
  }

  // Maneja errores HTTP comunes
  void _handleHttpError(http.Response response, String endpoint) {
    switch (response.statusCode) {
      case 401:
        print('Error 401 en $endpoint: Token inválido o expirado');
        break;
      case 403:
        print('Error 403 en $endpoint: Acceso denegado');
        break;
      case 404:
        print('Error 404 en $endpoint: Endpoint no encontrado');
        break;
      case 409:
        print('Error 409 en $endpoint: Conflicto (usuario ya existe)');
        break;
      case 500:
        print('Error 500 en $endpoint: Error interno del servidor');
        break;
      default:
        print('Error ${response.statusCode} en $endpoint: ${response.body}');
    }
  }

  // Verifica si el usuario actual tiene perfil creado
  Future<bool> userExists() async {
    try {
      // Obtener headers con token
      Map<String, String>? headers = await _getHeaders();
      if (headers == null) {
        return false;
      }

      // Hacer petición GET
      http.Response response = await http
          .get(Uri.parse('$_baseUrl/api/user/exists'), headers: headers)
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['exists'] ?? false;
      } else {
        _handleHttpError(response, 'userExists');
        return false;
      }
    } catch (e) {
      print('Error en userExists: $e');
      return false;
    }
  }

  // Crea un nuevo perfil de usuario en el backend
  Future<Map<String, dynamic>> createUserProfile({String? username}) async {
    try {
      // Obtener headers con token
      Map<String, String>? headers = await _getHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'No se pudo obtener token de autenticación',
        };
      }

      // Preparar body de la petición
      Map<String, dynamic> body = {};
      if (username != null && username.isNotEmpty) {
        body['username'] = username;
      }

      // Hacer petición POST
      http.Response response = await http
          .post(
            Uri.parse('$_baseUrl/api/user/create'),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 201) {
        // Usuario creado exitosamente
        return {
          'success': true,
          'message': response.body,
          'data': response.body,
        };
      } else if (response.statusCode == 409) {
        // Usuario ya existe
        return {
          'success': false,
          'error': 'Ya existe un perfil para este usuario',
        };
      } else {
        _handleHttpError(response, 'createUserProfile');
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error en createUserProfile: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  //Obtiene el perfil completo del usuario autenticado (método legacy)
  Future<Map<String, dynamic>> getUserProfileLegacy() async {
    try {
      // Obtener headers con token
      Map<String, String>? headers = await _getHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'No se pudo obtener token de autenticación',
        };
      }

      // Hacer petición GET
      http.Response response = await http
          .get(Uri.parse('$_baseUrl/api/user/profile'), headers: headers)
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 200) {
        Map<String, dynamic> userData = json.decode(response.body);
        return {'success': true, 'data': userData};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'Perfil de usuario no encontrado'};
      } else {
        _handleHttpError(response, 'getUserProfile');
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error en getUserProfile: $e');
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  // Verifica que la API esté funcionando correctamente
  Future<bool> checkApiHealth() async {
    try {
      // Hacer petición GET sin autenticación
      http.Response response = await http
          .get(
            Uri.parse('$_baseUrl/api/user/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      // Verificar código de estado
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == 'OK';
      } else {
        _handleHttpError(response, 'checkApiHealth');
        return false;
      }
    } catch (e) {
      print('Error en checkApiHealth: $e');
      return false;
    }
  }

  // Refresca el token y reintenta una petición fallida
  Future<Map<String, dynamic>> _retryWithRefreshToken(
    Future<Map<String, dynamic>> Function() apiCall,
  ) async {
    try {
      // Intentar refrescar token
      String? newToken = await _authService.refreshToken();
      if (newToken != null) {
        // Reintentar la petición original
        return await apiCall();
      } else {
        return {'success': false, 'error': 'No se pudo refrescar el token'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error refrescando token: $e'};
    }
  }

  // Obtiene información de conectividad de la API
  // Mostrar estado de conexión en UI
  Future<Map<String, dynamic>> getApiStatus() async {
    try {
      DateTime startTime = DateTime.now();

      bool isHealthy = await checkApiHealth();

      DateTime endTime = DateTime.now();
      int responseTime = endTime.difference(startTime).inMilliseconds;

      return {
        'isHealthy': isHealthy,
        'responseTime': responseTime,
        'timestamp': DateTime.now().toIso8601String(),
        'baseUrl': _baseUrl,
      };
    } catch (e) {
      return {
        'isHealthy': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'baseUrl': _baseUrl,
      };
    }
  }
}
