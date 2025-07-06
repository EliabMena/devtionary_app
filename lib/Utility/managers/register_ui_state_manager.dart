import 'package:flutter/material.dart';

/*
 * Manejador de estado de la UI del registro que gestiona
 * el estado de validación, carga y mensajes de error.
 * 
 * Esta clase permite separar la lógica de manejo de estado
 * de la UI principal para mejorar la mantenibilidad.
 */
class RegisterUIStateManager {
  // Estados de validación
  bool _hasErrorEmail = false;
  String? _errorMessageEmail;
  bool _hasErrorPassword = false;
  String? _errorMessagePassword;
  bool _hasErrorUsername = false;
  String? _errorMessageUsername;

  // Estados de carga
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  // Callbacks para notificar cambios de estado
  VoidCallback? _onStateChanged;

  // Constructor que opcionalmente acepta un callback para notificar cambios
  RegisterUIStateManager({VoidCallback? onStateChanged}) 
      : _onStateChanged = onStateChanged;

  // Getters para acceder al estado
  bool get hasErrorEmail => _hasErrorEmail;
  String? get errorMessageEmail => _errorMessageEmail;
  bool get hasErrorPassword => _hasErrorPassword;
  String? get errorMessagePassword => _errorMessagePassword;
  bool get hasErrorUsername => _hasErrorUsername;
  String? get errorMessageUsername => _errorMessageUsername;
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;

  // Actualiza el estado de validación del email
  void updateEmailValidation(String? errorMessage) {
    _hasErrorEmail = errorMessage != null;
    _errorMessageEmail = errorMessage;
    _notifyStateChange();
  }

  // Actualiza el estado de validación de la contraseña
  void updatePasswordValidation(String? errorMessage) {
    _hasErrorPassword = errorMessage != null;
    _errorMessagePassword = errorMessage;
    _notifyStateChange();
  }

  // Actualiza el estado de validación del nombre de usuario
  void updateUsernameValidation(String? errorMessage) {
    _hasErrorUsername = errorMessage != null;
    _errorMessageUsername = errorMessage;
    _notifyStateChange();
  }

  // Establece el estado de carga del registro
  void setLoading(bool loading) {
    _isLoading = loading;
    _notifyStateChange();
  }

  // Establece el estado de carga de Google
  void setGoogleLoading(bool loading) {
    _isGoogleLoading = loading;
    _notifyStateChange();
  }

  /*
   * Actualiza múltiples estados de validación a la vez
   * Útil para actualizar todos los errores después de validar el formulario
   */
  void updateAllValidations({
    String? emailError,
    String? passwordError,
    String? usernameError,
  }) {
    _hasErrorEmail = emailError != null;
    _errorMessageEmail = emailError;
    _hasErrorPassword = passwordError != null;
    _errorMessagePassword = passwordError;
    _hasErrorUsername = usernameError != null;
    _errorMessageUsername = usernameError;
    _notifyStateChange();
  }

  // Limpia todos los errores de validación
  void clearAllErrors() {
    _hasErrorEmail = false;
    _errorMessageEmail = null;
    _hasErrorPassword = false;
    _errorMessagePassword = null;
    _hasErrorUsername = false;
    _errorMessageUsername = null;
    _notifyStateChange();
  }

  // Limpia todos los estados de carga
  void clearLoadingStates() {
    _isLoading = false;
    _isGoogleLoading = false;
    _notifyStateChange();
  }

  // Resetea completamente el estado
  void resetState() {
    clearAllErrors();
    clearLoadingStates();
  }

  // Retorna un mapa con todos los estados de error actuales
  Map<String, bool> getErrorStates() {
    return {
      'email': _hasErrorEmail,
      'password': _hasErrorPassword,
      'username': _hasErrorUsername,
    };
  }

  // Retorna un mapa con todos los mensajes de error actuales
  Map<String, String?> getErrorMessages() {
    return {
      'email': _errorMessageEmail,
      'password': _errorMessagePassword,
      'username': _errorMessageUsername,
    };
  }

  // Verifica si hay algún error de validación
  bool hasAnyValidationError() {
    return _hasErrorEmail || _hasErrorPassword || _hasErrorUsername;
  }

  // Verifica si hay algún proceso de carga activo
  bool hasAnyLoadingState() {
    return _isLoading || _isGoogleLoading;
  }

  // Notifica cambios de estado si hay un callback configurado
  void _notifyStateChange() {
    _onStateChanged?.call();
  }
}
