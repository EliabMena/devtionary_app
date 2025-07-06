import 'package:flutter/material.dart';

/*
* Helper para manejo de mensajes y notificaciones en la aplicación
* 
* Funcionalidades:
* - Mostrar SnackBars con diferentes tipos de mensajes (éxito, error, info)
* - Configuración consistente de estilos y comportamiento de mensajes
* - Métodos utilitarios para diferentes tipos de notificaciones
* 
* @author Eliab
*/

class MessageHelper {
  
  /*
   * Muestra un mensaje general usando SnackBar
   * 
   * @param context Contexto de la aplicación
   * @param message Texto del mensaje a mostrar
   * @param isError Indica si es un mensaje de error (cambia el color)
   * @param duration Duración del mensaje (opcional, por defecto 4 segundos)
   */
  static void showMessage({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  /*
   * Muestra un mensaje de éxito
   * 
   * @param context Contexto de la aplicación
   * @param message Texto del mensaje de éxito
   */
  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    showMessage(
      context: context,
      message: message,
      isError: false,
    );
  }
  
  /*
   * Muestra un mensaje de error
   * 
   * @param context Contexto de la aplicación
   * @param message Texto del mensaje de error
   */
  static void showError({
    required BuildContext context,
    required String message,
  }) {
    showMessage(
      context: context,
      message: message,
      isError: true,
    );
  }
  
  /*
   * Muestra un mensaje informativo (color azul)
   * 
   * @param context Contexto de la aplicación
   * @param message Texto del mensaje informativo
   */
  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
