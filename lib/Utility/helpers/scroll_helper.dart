import 'package:flutter/material.dart';

/*
* Helper para manejo de scroll y focus de campos en formularios
* 
* Funcionalidades:
* - Configurar listeners para FocusNodes que detectan cuando se enfocan campos
* - Realizar scroll automático a posiciones específicas cuando cambia el focus
* - Animaciones suaves de scroll con duración y curva personalizables
* 
* @author Eliab
*/

class ScrollHelper {
  
  /*
   * Configura listeners para FocusNodes que realizan scroll automático
   * cuando los campos reciben focus
   * 
   * @param focusNodes Map con los FocusNode y sus posiciones de scroll correspondientes
   * @param scrollController ScrollController para manejar el scroll
   * @param duration Duración de la animación de scroll (opcional, por defecto 300ms)
   * @param curve Curva de animación (opcional, por defecto Curves.easeInOut)
   */
  static void setupFocusListeners({
    required Map<FocusNode, double> focusNodes,
    required ScrollController scrollController,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    focusNodes.forEach((focusNode, position) {
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          scrollToPosition(
            scrollController: scrollController,
            position: position,
            duration: duration,
            curve: curve,
          );
        }
      });
    });
  }
  
  /*
   * Realiza scroll a una posición específica con animación
   * 
   * @param scrollController ScrollController para manejar el scroll
   * @param position Posición en píxeles donde hacer scroll
   * @param duration Duración de la animación (opcional, por defecto 300ms)
   * @param curve Curva de animación (opcional, por defecto Curves.easeInOut)
   */
  static void scrollToPosition({
    required ScrollController scrollController,
    required double position,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    scrollController.animateTo(
      position,
      duration: duration,
      curve: curve,
    );
  }
  
  /*
   * Calcula una posición de scroll basada en porcentaje de la pantalla
   * 
   * @param context Contexto para obtener el tamaño de pantalla
   * @param percentage Porcentaje de la pantalla (0.0 a 1.0)
   * @return Posición calculada en píxeles
   */
  static double calculatePositionFromPercentage({
    required BuildContext context,
    required double percentage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * percentage;
  }
}
