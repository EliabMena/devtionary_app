import 'package:devtionary_app/services/api_service.dart';
import 'package:devtionary_app/services/auth_service.dart';

import '../controllers/auth_controller.dart';
import '../validations/email_vlitations.dart';
import '../validations/username_validations.dart';
import '../validations/password_validations.dart';
import '../helpers/form_helper.dart';

/*
 * Manejador de formulario de registro que contiene toda la lógica
 * de validación y procesamiento del formulario de registro.
 * 
 * Esta clase separa la lógica de negocio de la UI para mejorar
 * la mantenibilidad y testabilidad del código.
 */
class RegisterFormHandler {
  final AuthController _authController = AuthController();
  final ApiService apiService = ApiService();
  final AuthService _authService = AuthService();

  // Valida el email y retorna el mensaje de error si existe
  String? validateEmail(String email) {
    return EmailValidation.validateEmail(email);
  }

  // Valida el nombre de usuario y retorna el mensaje de error si existe
  String? validateUsername(String username) {
    return UsernameValidation.validateUsername(username);
  }

  // Valida la contraseña y retorna el mensaje de error si existe
  String? validatePassword(String password) {
    return PasswordValidation.validatePassword(password);
  }

  // Valida todos los campos del formulario
  bool areAllFieldsValid({
    required Map<String, bool> hasErrors,
    required Map<String, String> fieldValues,
  }) {
    return FormHelper.areAllFieldsValid(
      hasErrors: hasErrors,
      fieldValues: fieldValues,
    );
  }

  // Procesa el registro con email y contraseña
  Future<RegisterResult> handleEmailRegister({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final result = await _authController.registerWithEmail(
        email: email.trim(),
        password: password,
        username: username.trim(),
      );
      // Solo retorna el resultado del AuthController, que ya maneja el registro en backend
      if (result.success) {
        return RegisterResult(
          success: true,
          message: '¡Registro exitoso! Bienvenido a Devtionary',
        );
      } else {
        return RegisterResult(
          success: false,
          message: result.error ?? 'Error desconocido',
        );
      }
    } catch (e) {
      return RegisterResult(success: false, message: 'Error inesperado: $e');
    }
  }

  // Procesa el registro con Google
  Future<RegisterResult> handleGoogleRegister() async {
    try {
      final result = await _authController.signInWithGoogle();

      if (result.success) {
        return RegisterResult(
          success: true,
          message: '¡Inicio de sesión exitoso!',
        );
      } else {
        return RegisterResult(
          success: false,
          message: result.error ?? 'Error desconocido',
        );
      }
    } catch (e) {
      return RegisterResult(
        success: false,
        message: 'Error con Google Sign-In: $e',
      );
    }
  }

  /*
   * Realiza la validación completa del formulario antes del envío
   * Retorna un objeto ValidationResult con el estado de validación
   * y los errores encontrados en cada campo
   */
  ValidationResult validateFormBeforeSubmit({
    required String email,
    required String password,
    required String username,
  }) {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final usernameError = validateUsername(username);

    final hasErrors = {
      'email': emailError != null,
      'password': passwordError != null,
      'username': usernameError != null,
    };

    final fieldValues = {
      'email': email,
      'password': password,
      'username': username,
    };

    final isValid = areAllFieldsValid(
      hasErrors: hasErrors,
      fieldValues: fieldValues,
    );

    return ValidationResult(
      isValid: isValid,
      errors: {
        'email': emailError,
        'password': passwordError,
        'username': usernameError,
      },
    );
  }
}

/*
 * Resultado de una operación de registro
 * Contiene el estado de éxito y el mensaje correspondiente
 */
class RegisterResult {
  final bool success;
  final String message;

  RegisterResult({required this.success, required this.message});
}

/*
 * Resultado de validación del formulario
 * Contiene el estado de validación y los errores específicos
 */
class ValidationResult {
  final bool isValid;
  final Map<String, String?> errors;

  ValidationResult({required this.isValid, required this.errors});
}
