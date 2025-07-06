import 'package:flutter/material.dart';
import '../handlers/register_form_handler.dart';
import '../managers/register_ui_state_manager.dart';
import '../helpers/message_helper.dart';

/*
 * Coordinador principal para la pantalla de registro.
 * 
 * Esta clase actúa como un mediador entre la UI y toda la lógica
 * de negocio, proporcionando una interfaz limpia para el RegisterScreen.
 */
class RegisterCoordinator {
  final RegisterFormHandler _formHandler = RegisterFormHandler();
  final RegisterUIStateManager _uiStateManager;
  final BuildContext _context;

  RegisterCoordinator({
    required BuildContext context,
    VoidCallback? onStateChanged,
  }) : _context = context,
       _uiStateManager = RegisterUIStateManager(onStateChanged: onStateChanged);

  // Getters para acceder al estado de la UI
  RegisterUIStateManager get uiState => _uiStateManager;

  // Valida el email y actualiza el estado de la UI
  void validateEmail(String email) {
    final error = _formHandler.validateEmail(email);
    _uiStateManager.updateEmailValidation(error);
  }

  // Valida la contraseña y actualiza el estado de la UI
  void validatePassword(String password) {
    final error = _formHandler.validatePassword(password);
    _uiStateManager.updatePasswordValidation(error);
  }

  // Valida el nombre de usuario y actualiza el estado de la UI
  void validateUsername(String username) {
    final error = _formHandler.validateUsername(username);
    _uiStateManager.updateUsernameValidation(error);
  }

  /*
   * Procesa el registro con email completo
   * Incluye validación previa, manejo de estado de carga,
   * y mostrado de mensajes de resultado
   */
  Future<void> handleEmailRegister({
    required String email,
    required String password,
    required String username,
  }) async {
    // Validar todos los campos antes del envío
    final validation = _formHandler.validateFormBeforeSubmit(
      email: email,
      password: password,
      username: username,
    );

    // Actualizar estado de validación
    _uiStateManager.updateAllValidations(
      emailError: validation.errors['email'],
      passwordError: validation.errors['password'],
      usernameError: validation.errors['username'],
    );

    // Si hay errores, mostrar mensaje y salir
    if (!validation.isValid) {
      _showMessage(
        'Por favor, corrige los errores antes de continuar',
        isError: true,
      );
      return;
    }

    // Iniciar proceso de registro
    _uiStateManager.setLoading(true);

    try {
      final result = await _formHandler.handleEmailRegister(
        email: email,
        password: password,
        username: username,
      );

      _showMessage(result.message, isError: !result.success);

      if (result.success) {
        // TODO: Navegar a la pantalla principal cuando esté lista
        // Navigator.pushReplacementNamed(_context, '/main');
      }
    } finally {
      _uiStateManager.setLoading(false);
    }
  }

  // Procesa el registro con Google
  Future<void> handleGoogleRegister() async {
    _uiStateManager.setGoogleLoading(true);

    try {
      final result = await _formHandler.handleGoogleRegister();

      _showMessage(result.message, isError: !result.success);

      if (result.success) {
        // TODO: Navegar a la pantalla principal cuando esté lista
        // Navigator.pushReplacementNamed(_context, '/main');
      }
    } finally {
      _uiStateManager.setGoogleLoading(false);
    }
  }

  // Muestra un mensaje usando MessageHelper
  void _showMessage(String message, {bool isError = false}) {
    MessageHelper.showMessage(
      context: _context,
      message: message,
      isError: isError,
    );
  }

  /*
   * Verifica si todos los campos son válidos
   * Utiliza el estado actual de la UI y los valores de los campos
   */
  bool areAllFieldsValid({
    required String email,
    required String password,
    required String username,
  }) {
    return _formHandler.areAllFieldsValid(
      hasErrors: _uiStateManager.getErrorStates(),
      fieldValues: {
        'email': email,
        'password': password,
        'username': username,
      },
    );
  }

  // Limpia todos los errores de validación
  void clearAllErrors() {
    _uiStateManager.clearAllErrors();
  }

  // Resetea completamente el estado
  void resetState() {
    _uiStateManager.resetState();
  }
}
