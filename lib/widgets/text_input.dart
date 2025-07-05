import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  //Atributos de la clase TextInput
  final TextEditingController inputController;
  final String promptText;
  final TextInputType? keyboardType;
  final IconData? icon;
  final bool hasValidationError;
  final String? errorText;
  final Function(String)? onChanged;
  final FocusNode? focusNode; // Agregar FocusNode

  /*
   * Este constructor inicializa los atributos de la clase TextInput.
   * @param "inputController" Controlador de texto para el campo de entrada.
   * @param "promptText" Texto que se muestra como etiqueta del campo de entrada.
   * @param "keyboardType" Tipo de teclado que se mostrará (opcional).
   * @param "icon" Icono que se muestra al inicio del campo de entrada (opcional
   * y puede ser nulo).
   * @param "hasValidationError" Indica si hay un error de validación (opcional).
   * @param "errorText" Texto del error de validación (opcional).
   * @param "onChanged" Función que se llama cuando el texto cambia (opcional).
   * @param "focusNode" Nodo de enfoque para detectar cuando se selecciona el input (opcional).
   *
   * Los parámetros opcionales no tienen que ser declarados al llamar al constructor.
   * Si no se proporcionan, se utilizarán los valores predeterminados.
   *
   * @author Eliab
   */
  const TextInput({
    Key? key,
    required this.inputController,
    required this.promptText,
    this.keyboardType,
    this.icon,
    this.hasValidationError = false,
    this.errorText,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  /* Método para construir el widget 
  * Este método es el encargado de construir el widget TextInput.
  *
  * Estructura del widget:
  TextInput Widget
    │
    ├── Container
    │   │
    │   └── TextField
    │       ├── controller
    │       ├── focusNode
    │       ├── style
    │       ├── onChanged
    │       │
    │       └── InputDecoration
    │           ├── prefixIcon(icon)
    │           ├── labelText(promptText)
    │           ├── errorText
    │           ├── fillColor
    │           │
    │           └── Borders (4 tipos):
    │               ├── enabledBorder
    │               ├── focusedBorder
    │               ├── errorBorder
    │               └── focusedErrorBorder
    *
    * Los bordes del campo de entrada cambian según el estado del campo:
    * - enabledBorder: Cuando el campo está habilitado y no tiene errores.
    * - focusedBorder: Cuando el campo está enfocado y no tiene errores.
    * - errorBorder: Cuando el campo tiene un error de validación.
    * - focusedErrorBorder: Cuando el campo está enfocado y tiene un error de validación.
  */
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: inputController,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.text,
        style: const TextStyle(fontSize: 20, color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
          labelText: promptText,
          labelStyle: TextStyle(color: hasValidationError ? Colors.red : Colors.grey),
          errorText: hasValidationError ? errorText : null,
          filled: true,
          fillColor: inputFillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: hasValidationError ? Colors.red : borderColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: hasValidationError ? Colors.red : const Color.fromARGB(255, 255, 255, 255),
              width: 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}