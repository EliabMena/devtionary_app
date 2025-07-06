import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  //Atributos de la clase TextInput
  final TextEditingController inputController;
  final String promptText;
  final TextInputType? keyboardType;
  final IconData? icon;
  final bool hasValidationError;
  final String? errorText;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

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
   * @param "isPassword" Indica si el campo es para ingresar una contraseña (opcional).
   * @param "textInputAction" Acción del botón en el teclado (opcional).
   * @param "onSubmitted" Función que se llama cuando se presiona el botón de acción del teclado (opcional).
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
    this.isPassword = false,
    this.textInputAction,
    this.onSubmitted,
  }) : super(key: key);

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool _obscurePassword = true; // Estado para mostrar/ocultar contraseña

  /* Método para construir el widget 
  * Este método es el encargado de construir el widget TextInput.
  *
  * Estructura del widget:
  TextInput Widget (StatefulWidget)
    │
    ├── Container
    │   ├── margin: EdgeInsets.symmetric(vertical: 8.0)
    │   │
    │   └── TextField
    │       ├── controller: widget.inputController
    │       ├── focusNode: widget.focusNode
    │       ├── keyboardType: widget.keyboardType
    │       ├── obscureText: dinámico (solo para contraseñas)
    │       ├── style: TextStyle(fontSize: 20, color: Colors.white)
    │       ├── onChanged: widget.onChanged
    │       │
    │       └── InputDecoration
    │           ├── prefixIcon: Icon(widget.icon)
    │           ├── labelText: widget.promptText
    │           ├── errorText: widget.errorText
    │           ├── fillColor: inputFillColor
    │           ├── suffixIcon: IconButton (solo para contraseñas)
    │           │   ├── icon: Icons.visibility / Icons.visibility_off
    │           │   └── onPressed: toggle _obscurePassword
    │           │
    │           └── Borders (4 tipos):
    │               ├── enabledBorder: BorderRadius.circular(25)
    │               ├── focusedBorder: BorderRadius.circular(25)
    │               ├── errorBorder: BorderRadius.circular(25)
    │               └── focusedErrorBorder: BorderRadius.circular(25)
    *
    * Estados del widget:
    * - _obscurePassword: Controla si la contraseña está oculta (solo para isPassword: true)
    * 
    * Funcionalidades especiales:
    * - Campo de contraseña: Cuando isPassword=true, muestra asteriscos y botón de ojo
    * - Toggle de visibilidad: El suffixIcon permite mostrar/ocultar la contraseña
    * - Estados dinámicos: Los iconos cambian entre visibility y visibility_off
    * 
    * Los bordes del campo de entrada cambian según el estado del campo:
    * - enabledBorder: Cuando el campo está habilitado y no tiene errores.
    * - focusedBorder: Cuando el campo está enfocado y no tiene errores.
    * - errorBorder: Cuando el campo tiene un error de validación.
    * - focusedErrorBorder: Cuando el campo está enfocado y tiene un error de validación.
    * 
    * Las validaciones de email se realizan con EmailValidation del archivo email_vlitations.dart.
  */
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: widget.inputController,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType ?? TextInputType.text,
        obscureText: widget.isPassword ? _obscurePassword : false, // Agregar esta línea
        style: const TextStyle(fontSize: 20, color: Colors.white),
        onChanged: widget.onChanged,
        textInputAction: widget.textInputAction,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          prefixIcon: widget.icon != null ? Icon(widget.icon, color: iconColor) : null,
          labelText: widget.promptText,
          labelStyle: TextStyle(color: widget.hasValidationError ? Colors.red : Colors.grey),
          errorText: widget.hasValidationError ? widget.errorText : null,
          filled: true,
          fillColor: inputFillColor,
          // Botón para mostrar/ocultar contraseña
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: widget.hasValidationError ? Colors.red : borderColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: widget.hasValidationError ? Colors.red : const Color.fromARGB(255, 255, 255, 255),
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