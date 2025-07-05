import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/Utility/validations/email_vlitations.dart';
import 'package:devtionary_app/screens/register_screen.dart';
import 'package:devtionary_app/widgets/btn_basic.dart';
import 'package:devtionary_app/widgets/btn_google.dart';
import 'package:devtionary_app/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/*
 * Pantalla de inicio de sesión de la aplicación Devtionary.
 * Esta pantalla permite a los usuarios ingresar sus credenciales (email y contraseña)
 * para acceder a la aplicación.
 * 
 * Características principales:
 * - Validación de email en tiempo real
 * - Fondo con gradiente radial animado
 * - Scroll funcional que se adapta al teclado
 * - Navegación a la pantalla de registro
 * - Botón de Google para autenticación alternativa
 * 
 * @author Eliab
 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variables para validaciones
  // Email
  bool hasErrorEmail = false;
  String? errorMessageEmail;

  /*
   * Método para construir la interfaz de usuario de la pantalla de login.
   * 
   * Estructura del widget:
   * LoginScreen Widget
   *   │
   *   ├── Scaffold
   *   │   ├── resizeToAvoidBottomInset: false
   *   │   │
   *   │   └── AnimatedContainer
   *   │       ├── duration: 300ms
   *   │       ├── curve: Curves.easeInOut
   *   │       ├── decoration
   *   │       │   └── gradient: RadialGradient (animado según teclado)
   *   │       │
   *   │       └── SingleChildScrollView
   *   │           └── Padding
   *   │               └── Column
   *   │                   ├── Logo Devtionary
   *   │                   ├── Título "Log in"
   *   │                   ├── RichText (navegación a registro)
   *   │                   ├── TextInput (Email con validación)
   *   │                   ├── TextInput (Contraseña)
   *   │                   ├── BtnBasic (Crear cuenta)
   *   │                   ├── GoogleButton
   *   │                   └── SizedBox (espacio dinámico)
   *   
   * Funcionalidades:
   * - Gradiente radial que se expande cuando aparece el teclado
   * - Validación de email en tiempo real usando EmailValidation
   * - Navegación a RegisterScreen mediante TapGestureRecognizer
   * - Scroll automático con espacio dinámico según altura del teclado
   * - Botones personalizados para login y autenticación con Google
   * 
   * Los colores se obtienen de app_colors.dart y las validaciones de email_vlitations.dart
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ¡Ignora el teclado!
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300), // Duración de la animación
        curve: Curves.easeInOut, // Curva de animación suave
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [primaryGradientColor, secondaryGradientColor, Colors.black],
            stops: [0.2, 0.4, 0.7], // Ajuste de donde Inicia el degradado y termina
            center: Alignment.bottomCenter,
            radius: MediaQuery.of(context).viewInsets.bottom > 0
                ? 1.6 // Gradiente más grande cuando hay teclado
                : 1, // Gradiente normal sin teclado
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
              children: [
                Align(alignment: Alignment.topLeft),
                SizedBox(height: 0),
                // Logo de la aplicación Devtionary
                Image.asset(
                  'assets/imagenes/logo.png',
                  height: 100,
                  width: 140,
                ),
                SizedBox(height: 40),
                // Título principal de la pantalla
                Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 25),
                // Texto con enlace para navegar a la pantalla de registro
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    children: [
                      TextSpan(text: 'Usuario nuevo? '),
                      TextSpan(
                        text: 'Crea una cuenta',
                        style: TextStyle(
                          fontSize: 22,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navega a la pantalla de registro
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Campo de entrada para el email con validación en tiempo real
                TextInput(
                  inputController: _emailController,
                  promptText: 'Correo electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  hasValidationError: hasErrorEmail,
                  errorText: errorMessageEmail,
                  onChanged: (value) {
                    // Validación de email en tiempo real usando EmailValidation
                    String? error = EmailValidation.validateEmail(value);
                    setState(() {
                      errorMessageEmail = error;
                      hasErrorEmail = error != null;
                    });
                  },
                ),

                // Campo de entrada para la contraseña
                TextInput(
                  inputController: _passwordController,
                  promptText: 'Contraseña',
                  icon: Icons.lock,
                  hasValidationError: false,
                ),

                SizedBox(height: 38),
                // Botón principal para iniciar sesión
                BtnBasic(text: 'Crear cuenta'),
                SizedBox(height: 12),
                // Botón alternativo para autenticación con Google
                GoogleButton(
                  onPressed: () {
                    // Aquí se implementaría la lógica para el login con Google
                  },
                ),
                // Espacio dinámico que se ajusta según la altura del teclado
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}