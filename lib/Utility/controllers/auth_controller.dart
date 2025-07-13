import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/service_result.dart';

/// Resultado de una operación de autenticación
class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;

  AuthResult({required this.success, this.error, this.user, this.token});

  factory AuthResult.success(User user, String token) {
    return AuthResult(success: true, user: user, token: token);
  }

  factory AuthResult.error(String error) {
    return AuthResult(success: false, error: error);
  }
}

/// Estados de carga para las operaciones de autenticación
enum AuthState { idle, loading, success, error }

/// Controlador principal para manejar toda la lógica de autenticación
///
/// Este controller actúa como intermediario entre las pantallas de UI
/// y los servicios de autenticación (Firebase + Backend)
class AuthController {
  final AuthService _authService;
  final ApiService _apiService;

  // Estado actual del controller
  AuthState _state = AuthState.idle;
  String? _errorMessage;
  User? _currentUser;
  String? _currentToken;

  // Getters para acceder al estado desde las pantallas
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;
  bool get isLoading => _state == AuthState.loading;
  bool get isAuthenticated => _currentUser != null;

  AuthController({AuthService? authService, ApiService? apiService})
    : _authService = authService ?? AuthService(),
      _apiService = apiService ?? ApiService();

  /// Registra un nuevo usuario con email, contraseña y nombre de usuario
  ///
  /// Flujo:
  /// 1. Valida que el email no esté registrado en Firebase
  /// 2. Crea la cuenta en Firebase
  /// 3. Registra el usuario en el backend
  /// 4. Actualiza el perfil con el nombre de usuario
  ///
  /// Returns: AuthResult con el resultado de la operación
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _setState(AuthState.loading);

      // 1. Verificar si el usuario ya existe
      final userExists = await checkUserExists(email);
      if (userExists) {
        _setState(AuthState.error, 'El usuario ya está registrado');
        return AuthResult.error('El usuario ya está registrado');
      }

      // 2. Crear cuenta en Firebase
      final firebaseResult = await _authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (!firebaseResult.success || firebaseResult.user == null) {
        _setState(
          AuthState.error,
          firebaseResult.error ?? 'Error al crear cuenta',
        );
        return AuthResult.error(
          firebaseResult.error ?? 'Error al crear cuenta',
        );
      }

      // 3. Obtener token de Firebase
      final token = await firebaseResult.user!.getIdToken(true);
      print('DEBUG TOKEN (registerWithEmail): $token');
      if (token == null || token.isEmpty) {
        _setState(
          AuthState.error,
          'No se pudo obtener el token de autenticación',
        );
        return AuthResult.error('No se pudo obtener el token de autenticación');
      }

      // 4. Registrar usuario en el backend
      final backendResult = await _apiService.registerUser(
        email: email,
        username: username,
        firebaseToken: token,
      );

      if (!backendResult.success) {
        // Si falla el backend, eliminar cuenta de Firebase
        await _authService.deleteCurrentUser();
        _setState(
          AuthState.error,
          backendResult.error ?? 'Error al registrar en el servidor',
        );
        return AuthResult.error(
          backendResult.error ?? 'Error al registrar en el servidor',
        );
      }

      // 5. Actualizar perfil de Firebase con username
      await _authService.updateProfile(displayName: username);

      // 6. Configurar estado exitoso
      _currentUser = firebaseResult.user;
      _currentToken = token;
      _setState(AuthState.success);

      return AuthResult.success(firebaseResult.user!, token);
    } catch (e) {
      _setState(AuthState.error, 'Error inesperado: ${e.toString()}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Inicia sesión con Google
  ///
  /// Flujo:
  /// 1. Autentica con Google a través de Firebase
  /// 2. Verifica si el usuario existe en el backend
  /// 3. Si no existe, lo registra automáticamente
  /// 4. Obtiene el token y configura el estado
  ///
  /// Returns: AuthResult con el resultado de la operación
  Future<AuthResult> signInWithGoogle() async {
    try {
      _setState(AuthState.loading);

      //////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////

      // Quitar este signOut si no quieres cerrar sesión antes de Google Sign-In
      await _authService
          .signOut(); // <-- Quitar si no quieres forzar logout previo

      //////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////////////////////////

      // 1. Autenticar con Google
      final googleResult = await _authService.signInWithGoogle();

      if (!googleResult.success || googleResult.user == null) {
        _setState(
          AuthState.error,
          googleResult.error ?? 'Error al iniciar sesión con Google',
        );
        return AuthResult.error(
          googleResult.error ?? 'Error al iniciar sesión con Google',
        );
      }

      // 2. Obtener token
      final token = await googleResult.user!.getIdToken();
      print('DEBUG TOKEN (signInWithGoogle): $token');
      if (token == null || token.isEmpty) {
        _setState(
          AuthState.error,
          'No se pudo obtener el token de autenticación',
        );
        return AuthResult.error('No se pudo obtener el token de autenticación');
      }

      // 3. Verificar si el usuario existe en el backend
      final userProfile = await _apiService.getUserProfile(
        firebaseToken: token,
      );

      // 4. Si no existe, registrarlo automáticamente
      if (!userProfile.success) {
        final registerResult = await _apiService.registerUser(
          email: googleResult.user!.email!,
          username: googleResult.user!.displayName ?? 'Usuario Google',
          firebaseToken: token,
        );

        if (!registerResult.success) {
          _setState(AuthState.error, 'Error al registrar usuario de Google');
          return AuthResult.error('Error al registrar usuario de Google');
        }
      }

      // 5. Configurar estado exitoso
      _currentUser = googleResult.user;
      _currentToken = token;
      _setState(AuthState.success);

      return AuthResult.success(googleResult.user!, token);
    } catch (e) {
      _setState(AuthState.error, 'Error inesperado: ${e.toString()}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Inicia sesión con email y contraseña
  ///
  /// Flujo:
  /// 1. Autentica con Firebase
  /// 2. Obtiene el token
  /// 3. Verifica que el usuario exista en el backend
  ///
  /// Returns: AuthResult con el resultado de la operación
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);

      // 1. Autenticar con Firebase
      final firebaseResult = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (!firebaseResult.success || firebaseResult.user == null) {
        _setState(
          AuthState.error,
          firebaseResult.error ?? 'Credenciales incorrectas',
        );
        return AuthResult.error(
          firebaseResult.error ?? 'Credenciales incorrectas',
        );
      }

      // 2. Obtener token
      final token = await firebaseResult.user!.getIdToken();
      if (token == null || token.isEmpty) {
        _setState(
          AuthState.error,
          'No se pudo obtener el token de autenticación',
        );
        return AuthResult.error('No se pudo obtener el token de autenticación');
      }

      // 3. Verificar usuario en backend
      final userProfile = await _apiService.getUserProfile(
        firebaseToken: token,
      );

      if (!userProfile.success) {
        _setState(AuthState.error, 'Usuario no encontrado en el servidor');
        return AuthResult.error('Usuario no encontrado en el servidor');
      }

      // 4. Configurar estado exitoso
      _currentUser = firebaseResult.user;
      _currentToken = token;
      _setState(AuthState.success);

      return AuthResult.success(firebaseResult.user!, token);
    } catch (e) {
      _setState(AuthState.error, 'Error inesperado: ${e.toString()}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Verifica si un usuario existe en Firebase
  ///
  /// Returns: true si el usuario existe, false si no
  Future<bool> checkUserExists(String email) async {
    try {
      final methods = await _authService.fetchSignInMethods(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Cierra la sesión actual
  ///
  /// Limpia tanto Firebase como el estado local
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _currentToken = null;
      _setState(AuthState.idle);
    } catch (e) {
      _setState(AuthState.error, 'Error al cerrar sesión');
    }
  }

  /// Envía un email de recuperación de contraseña
  ///
  /// Returns: AuthResult con el resultado de la operación
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      _setState(AuthState.loading);

      final result = await _authService.sendPasswordResetEmail(email);

      if (result.success) {
        _setState(AuthState.success);
        // Para reset de contraseña, no necesitamos un user específico
        return AuthResult(success: true, error: null, user: null, token: null);
      } else {
        _setState(AuthState.error, result.error ?? 'Error al enviar email');
        return AuthResult.error(result.error ?? 'Error al enviar email');
      }
    } catch (e) {
      _setState(AuthState.error, 'Error inesperado: ${e.toString()}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Actualiza el perfil del usuario current
  ///
  /// Returns: AuthResult con el resultado de la operación
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setState(AuthState.loading);

      final result = await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (result.success) {
        _currentUser = result.user;
        _setState(AuthState.success);
        return AuthResult.success(result.user!, _currentToken ?? '');
      } else {
        _setState(
          AuthState.error,
          result.error ?? 'Error al actualizar perfil',
        );
        return AuthResult.error(result.error ?? 'Error al actualizar perfil');
      }
    } catch (e) {
      _setState(AuthState.error, 'Error inesperado: ${e.toString()}');
      return AuthResult.error('Error inesperado: ${e.toString()}');
    }
  }

  /// Refresca el token actual de Firebase
  ///
  /// Returns: El nuevo token o null si hay error
  Future<String?> refreshToken() async {
    try {
      if (_currentUser != null) {
        final token = await _currentUser!.getIdToken(true);
        _currentToken = token;
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Inicializa el controller verificando si hay un usuario autenticado
  ///
  /// Debe llamarse al iniciar la aplicación
  Future<void> initialize() async {
    try {
      _setState(AuthState.loading);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          _currentUser = user;
          _currentToken = token;
          _setState(AuthState.success);
        } else {
          _setState(AuthState.idle);
        }
      } else {
        _setState(AuthState.idle);
      }
    } catch (e) {
      _setState(AuthState.error, 'Error al inicializar: ${e.toString()}');
    }
  }

  /// Métodos privados para manejo de estado
  void _setState(AuthState newState, [String? error]) {
    _state = newState;
    _errorMessage = error;
  }

  /// Limpia el estado de error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.idle;
    }
  }

  /// Verifica si el token actual es válido
  bool isTokenValid() {
    if (_currentUser == null || _currentToken == null) return false;

    try {
      // Verificar si el token no ha expirado
      // Los tokens de Firebase duran 1 hora
      final tokenParts = _currentToken!.split('.');
      if (tokenParts.length != 3) return false;

      // Aquí podrías decodificar el JWT y verificar la fecha de expiración
      // Por simplicidad, asumimos que es válido si existe
      return true;
    } catch (e) {
      return false;
    }
  }
}
