import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/Utility/validations/email_vlitations.dart';
import 'package:devtionary_app/screens/register_screen.dart';
import 'package:devtionary_app/widgets/btn_basic.dart';
import 'package:devtionary_app/widgets/btn_google.dart';
import 'package:devtionary_app/widgets/text_input.dart';
import 'package:devtionary_app/services/auth_service.dart';
import 'package:devtionary_app/db/repositorios/terminos_repository.dart';
import 'package:devtionary_app/db/repositorios/comandos_repository.dart';
import 'package:devtionary_app/db/repositorios/instrucciones_repository.dart';
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
  bool hasErrorEmail = false;
  String? errorMessageEmail;
  bool hasErrorPassword = false;
  String? errorMessagePassword;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validación de email en tiempo real
  void _validateEmail(String email) {
    String? error = EmailValidation.validateEmail(email);
    setState(() {
      errorMessageEmail = error;
      hasErrorEmail = error != null;
    });
  }

  // Validación de contraseña
  void _validatePassword(String password) {
    setState(() {
      if (password.isEmpty) {
        errorMessagePassword = 'La contraseña es requerida';
        hasErrorPassword = true;
      } else if (password.length < 6) {
        errorMessagePassword = 'La contraseña debe tener al menos 6 caracteres';
        hasErrorPassword = true;
      } else {
        errorMessagePassword = null;
        hasErrorPassword = false;
      }
    });
  }

  // Verificar si todos los campos son válidos
  bool _areAllFieldsValid() {
    return !hasErrorEmail &&
        !hasErrorPassword &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  // Mostrar mensajes al usuario
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Navegación a la pantalla de registro
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    ).then((_) async {
      // Sincronizar términos después de registro
      await TerminosRepository().sincronizarTerminos();
    });
  }

  // Manejar el inicio de sesión con email y contraseña
  Future<void> _handleLogin() async {
    ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////
    // Forzar logout antes de login esto se tiene que quitar y remplazar por un
    //boton de logout
    await AuthService().signOut();
    ///////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    // Validar todos los campos
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (!_areAllFieldsValid()) {
      _showMessage(
        'Por favor, corrige los errores antes de continuar',
        isError: true,
      );
      return;
    }

    // Implementar lógica de autenticación con AuthService
    final authService = AuthService();
    final result = await authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (result.success) {
      _showMessage('¡Inicio de sesión exitoso!');
      // Verificar versión de API y sincronizar si es nueva
      try {
        final prefs = await SharedPreferences.getInstance();
        final response = await http.get(
          Uri.parse(
            'https://devtionary-api-production.up.railway.app/api/user/health',
          ),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final apiVersion = data['version'] ?? '';
          final localVersion = prefs.getString('api_version') ?? '';
          if (apiVersion != localVersion) {
            await TerminosRepository().sincronizarTerminos();
            await ComandosRepository().sincronizarComandos();
            await InstruccionesRepository().sincronizarInstrucciones();
            await prefs.setString('api_version', apiVersion);
            print('Sincronización realizada por nueva versión: $apiVersion');
          } else {
            print('Versión actual ($apiVersion) ya sincronizada.');
          }
        } else {
          print('No se pudo obtener la versión de la API.');
        }
      } catch (e) {
        print('Error al verificar versión y sincronizar: $e');
      }
      // Mostrar contenido de las tablas
      final terminos = await TerminosRepository().getTerminos();
      print('--- CONTENIDO DE TERMINOS ---');
      for (var t in terminos) {
        print(t.toJson());
      }
      final comandos = await ComandosRepository().getComandos();
      print('--- CONTENIDO DE COMANDOS ---');
      for (var c in comandos) {
        print(c.toJson());
      }
      final instrucciones = await InstruccionesRepository().getInstrucciones();
      print('--- CONTENIDO DE INSTRUCCIONES ---');
      for (var i in instrucciones) {
        print(i.toJson());
      }
      Navigator.pushReplacementNamed(context, '/SearchScreen');
    } else {
      _showMessage(
        result.error ?? 'Error en el inicio de sesión',
        isError: true,
      );
    }
  }

  // Manejar el inicio de sesión con Google
  Future<void> _handleGoogleLogin() async {
    ////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////
    // Forzar logout antes de login esto se tiene que quitar y remplazar por un
    //boton de logout
    await AuthService().signOut();
    ///////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////

    final authService = AuthService();
    final result = await authService.signInWithGoogle();

    if (result.success) {
      _showMessage('¡Inicio de sesión exitoso!');
      // Verificar versión de API y sincronizar si es nueva
      try {
        final prefs = await SharedPreferences.getInstance();
        final response = await http.get(
          Uri.parse(
            'https://devtionary-api-production.up.railway.app/api/user/health',
          ),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final apiVersion = data['version'] ?? '';
          final localVersion = prefs.getString('api_version') ?? '';
          if (apiVersion != localVersion) {
            print('Sincronizando datos por nueva versión: $apiVersion');
            try {
              print('Sincronizando términos...');
              await TerminosRepository().sincronizarTerminos();
              print('Sincronizando comandos...');
              await ComandosRepository().sincronizarComandos();
              print('Sincronizando instrucciones...');
              await InstruccionesRepository().sincronizarInstrucciones();
              await prefs.setString('api_version', apiVersion);
            } catch (e) {
              print('Error al sincronizar datos: $e');
            }
            print('Sincronización realizada por nueva versión: $apiVersion');
          } else {
            print('Versión actual ($apiVersion) ya sincronizada.');
          }
        } else {
          print('No se pudo obtener la versión de la API.');
        }
      } catch (e) {
        print('Error al verificar versión y sincronizar: $e');
      }
      Navigator.pushReplacementNamed(context, '/SearchScreen');
    } else {
      _showMessage(
        result.error ?? 'Error en el inicio de sesión con Google',
        isError: true,
      );
    }
  }

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
            colors: [
              primaryGradientColor,
              secondaryGradientColor,
              Colors.black,
            ],
            stops: [
              0.2,
              0.4,
              0.7,
            ], // Ajuste de donde Inicia el degradado y termina
            center: Alignment.bottomCenter,
            radius: MediaQuery.of(context).viewInsets.bottom > 0
                ? 1.5 // Gradiente más grande cuando hay teclado
                : 0.9, // Gradiente normal sin teclado
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinea a la izquierda
              children: [
                Align(alignment: Alignment.topLeft),
                SizedBox(height: 0),
                // Logo de la aplicación Devtionary
                Image.asset(
                  'assets/imagenes/logo.png',
                  height: 100,
                  width: 140,
                ),
                SizedBox(height: 100),
                // Título principal de la pantalla
                Text(
                  'Iniciar sesión',
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
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    children: [
                      TextSpan(text: 'Usuario nuevo? '),
                      TextSpan(
                        text: 'Crea una cuenta',
                        style: TextStyle(
                          fontSize: 19,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _navigateToRegister,
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
                  onChanged: _validateEmail,
                ),

                // Campo de entrada para la contraseña
                TextInput(
                  inputController: _passwordController,
                  promptText: 'Contraseña',
                  icon: Icons.lock,
                  hasValidationError: hasErrorPassword,
                  errorText: errorMessagePassword,
                  isPassword: true,
                  onChanged: _validatePassword,
                ),

                SizedBox(height: 38),
                // Botón principal para iniciar sesión
                BtnBasic(text: 'Iniciar sesión', onPressed: _handleLogin),
                SizedBox(height: 12),
                // Botón alternativo para autenticación con Google
                GoogleButton(onPressed: _handleGoogleLogin),
                // Espacio dinámico que se ajusta según la altura del teclado
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
