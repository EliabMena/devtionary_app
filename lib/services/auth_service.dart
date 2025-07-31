import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/service_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Instancia singleton de Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Registra un nuevo usuario con email y contraseña
  Future<ServiceResult<User>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Guardar token en SharedPreferences
      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      // Retornar resultado exitoso
      return ServiceResult.success(
        userCredential.user!,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print('Error en registro: ${e.code} - ${e.message}');
      return ServiceResult.error(errorMessage);
    } catch (e) {
      // Manejar otros errores
      print('Error inesperado en registro: $e');
      return ServiceResult.error('Error inesperado en el registro');
    }
  }

  // Implementa el inicio de sesión con email y contraseña
  Future<ServiceResult<User>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Limpiar email antes de login
      final emailClean = email.trim();
      // Autenticar con Firebase Auth
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: emailClean, password: password);

      // Guardar token en SharedPreferences
      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      // Retornar resultado exitoso
      return ServiceResult.success(
        userCredential.user!,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print('Error en login: ${e.code} - ${e.message}');
      return ServiceResult.error(errorMessage);
    } catch (e) {
      // Manejar otros errores
      print('Error inesperado en login: $e');
      return ServiceResult.error('Error inesperado en el inicio de sesión');
    }
  }

  // Autentica usuario con Google Sign-In
  Future<ServiceResult<User>> signInWithGoogle() async {
    try {
      // Paso 1: Iniciar flujo de Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Usuario canceló el flujo
      if (googleUser == null) {
        return ServiceResult.error('El usuario canceló el inicio de sesión');
      }

      // Paso 2: Obtener credenciales de autenticación
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Paso 3: Crear credenciales de Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Paso 4: Autenticar con Firebase usando credenciales de Google
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Guardar token en SharedPreferences
      String? token = await userCredential.user?.getIdToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
      }
      // Retornar resultado exitoso
      return ServiceResult.success(
        userCredential.user!,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos de Firebase Auth
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print('Error en Google Sign-In: ${e.code} - ${e.message}');
      return ServiceResult.error(errorMessage);
    } catch (e) {
      // Manejar otros errores
      print('Error inesperado en Google Sign-In: $e');
      return ServiceResult.error(
        'Error inesperado en el inicio de sesión con Google',
      );
    }
  }

  // Métodos para obtener métodos de autenticación disponibles
  Future<List<String>> fetchSignInMethods(String email) async {
    try {
      return await _firebaseAuth.fetchSignInMethodsForEmail(email);
    } catch (e) {
      print('Error obteniendo métodos de autenticación: $e');
      return [];
    }
  }

  // Envía email de restablecimiento de contraseña
  Future<ServiceResult<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return ServiceResult.success(null);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print(
        'Error enviando email de restablecimiento: ${e.code} - ${e.message}',
      );
      return ServiceResult.error(errorMessage);
    } catch (e) {
      print('Error inesperado enviando email: $e');
      return ServiceResult.error('Error inesperado al enviar el email');
    }
  }

  // Actualiza el perfil del usuario
  Future<ServiceResult<User>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return ServiceResult.error('No hay usuario autenticado');
      }

      await user.updateDisplayName(displayName);
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      User? updatedUser = _firebaseAuth.currentUser;

      return ServiceResult.success(updatedUser!, user: updatedUser);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print('Error actualizando perfil: ${e.code} - ${e.message}');
      return ServiceResult.error(errorMessage);
    } catch (e) {
      print('Error inesperado actualizando perfil: $e');
      return ServiceResult.error('Error inesperado al actualizar el perfil');
    }
  }

  // Elimina el usuario actual
  Future<ServiceResult<void>> deleteCurrentUser() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        return ServiceResult.success(null);
      }
      return ServiceResult.error('No hay usuario autenticado');
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);
      print('Error eliminando usuario: ${e.code} - ${e.message}');
      return ServiceResult.error(errorMessage);
    } catch (e) {
      print('Error inesperado eliminando usuario: $e');
      return ServiceResult.error('Error inesperado al eliminar el usuario');
    }
  }

  // Convierte códigos de error de Firebase a mensajes amigables
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email';
      case 'invalid-email':
        return 'El email no es válido';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'requires-recent-login':
        return 'Es necesario iniciar sesión nuevamente';
      default:
        return 'Error de autenticación: $code';
    }
  }

  // Obtiene el token ID del usuario actualmente autenticado
  Future<String?> getCurrentToken() async {
    try {
      // Verificar si hay usuario autenticado
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Obtener token ID (Firebase puede renovarlo automáticamente)
      String? token = await user.getIdToken();
      return token;
    } catch (e) {
      print('Error obteniendo token: $e');
      return null;
    }
  }

  // Cierra la sesión del usuario actual
  Future<void> signOut() async {
    try {
      // Cerrar sesión en Firebase Auth
      await _firebaseAuth.signOut();

      // Cerrar sesión en Google Sign-In (si se usó)
      await _googleSignIn.signOut();

      print('Sesión cerrada exitosamente');
    } catch (e) {
      print('Error cerrando sesión: $e');
    }
  }

  // MÉTODOS ADICIONALES ÚTILES

  // Usuario actualmente autenticado
  // ÚTIL PARA: Verificar si hay usuario logueado sin async
  User? get currentUser => _firebaseAuth.currentUser;

  // Verifica si hay un usuario autenticado
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Fuerza la renovación del token actual
  // Cuando el backend retorna 401 (token expirado)
  Future<String?> refreshToken() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }

      // Forzar renovación del token
      String? token = await user.getIdToken(true);
      return token;
    } catch (e) {
      print('Error renovando token: $e');
      return null;
    }
  }

  /// Obtiene información del usuario actual de forma síncrona
  /// ÚTIL PARA: Mostrar datos del usuario en UI (nombre, email, etc.)
  Map<String, dynamic>? getCurrentUserInfo() {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }

    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'emailVerified': user.emailVerified,
    };
  }

  /// Verifica si el email del usuario actual está verificado
  /// ÚTIL PARA: Mostrar avisos de verificación de email
  bool isEmailVerified() {
    User? user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  /// Envía email de verificación al usuario actual
  /// ÚTIL PARA: Después de registro con email/contraseña, algunos usuarios
  /// pueden querer verificar su email para mayor seguridad
  Future<void> sendEmailVerification() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Email de verificación enviado');
      }
    } catch (e) {
      print('Error enviando email de verificación: $e');
    }
  }

  /// Elimina la cuenta del usuario actual
  /// ÚTIL PARA: Función de "eliminar cuenta" en configuraciones
  /// PRECAUCIÓN: Esta acción es irreversible
  Future<bool> deleteAccount() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        print('Cuenta eliminada exitosamente');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('Se requiere login reciente para eliminar cuenta');
      }
      return false;
    } catch (e) {
      print('Error eliminando cuenta: $e');
      return false;
    }
  }
}
