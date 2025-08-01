import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/Utility/coordinators/register_coordinator.dart';
import 'package:devtionary_app/Utility/helpers/scroll_helper.dart';
import 'package:devtionary_app/widgets/text_input.dart';
import 'package:devtionary_app/widgets/btn_basic.dart';
import 'package:devtionary_app/widgets/btn_google.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/db/database_helper.dart';
import 'package:flutter/gestures.dart';

/*
 * Pantalla de registro de la aplicación Devtionary.
 * Esta pantalla permite a los usuarios crear una nueva cuenta
 * proporcionando su nombre de usuario, correo electrónico y contraseña.
 * 
 * Características principales:
 * - Utiliza Autenticacion con google account
 * - Autentificacion con Firebase para crear cuenta
 * 
 * @author Eliab
 */
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores para los campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // FocusNodes para los inputs
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Coordinador que maneja toda la lógica
  late RegisterCoordinator _coordinator;

  @override
  void initState() {
    super.initState();

    // Inicializar coordinador con callback para actualizar el estado
    _coordinator = RegisterCoordinator(
      context: context,
      onStateChanged: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    // Configurar listeners de scroll usando ScrollHelper
    ScrollHelper.setupFocusListeners(
      focusNodes: {
        _usernameFocusNode: 100.0, // Posición aproximada del campo usuario
        _emailFocusNode: 150.0, // Posición aproximada del campo email
        _passwordFocusNode: 200.0, // Posición aproximada del campo contraseña
      },
      scrollController: _scrollController,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Métodos de validación que delegan al coordinador
  void _validateEmail(String email) {
    _coordinator.validateEmail(email);
  }

  void _validatePassword(String password) {
    _coordinator.validatePassword(password);
  }

  void _validateUsername(String username) {
    _coordinator.validateUsername(username);
  }

  // Métodos de manejo de formulario que delegan al coordinador
  Future<void> _handleRegister() async {
    print('PANTALLA: _handleRegister');
    // Deshabilitar el botón inmediatamente para evitar doble llamada
    if (_coordinator.uiState.isLoading) return;
    setState(() {
      _coordinator.uiState.setLoading(true);
    });
    try {
      await _coordinator.handleEmailRegister(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );
      // Guardar datos ingresados en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('fechaRegistro', DateTime.now().toIso8601String());
      // Sincronizar datos después de registro
      await DatabaseHelper.sincronizarDatos();
      // Navegar automáticamente al menú principal
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main_menu');
      }
    } catch (e) {
      setState(() {
        _coordinator.uiState.setLoading(false);
      });
      rethrow;
    }
  }

  // Navegacion Y sincronización de datos después de registro con Google
  Future<void> _handleGoogleSignIn() async {
    final result = await _coordinator.handleGoogleRegister();
    if (result != null && result.success && mounted) {
      await DatabaseHelper.sincronizarDatos();
      Navigator.pushReplacementNamed(context, '/main_menu');
    }
  }

  /*
   * Método para construir la interfaz de usuario de la pantalla de registro.
   * 
   * Estructura del widget:
   * RegisterScreen Widget
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
   *   │                   ├── Título "Crear cuenta"
   *   │                   ├── RichText (navegación a login)
   *   │                   ├── TextInput (Username con validación)
   *   │                   ├── TextInput (Email con validación)
   *   │                   ├── TextInput (Contraseña con validación)
   *   │                   ├── BtnBasic (Crear cuenta)
   *   │                   ├── GoogleButton
   *   │                   └── SizedBox (espacio dinámico)
   *   
   * Funcionalidades:
   * - Gradiente radial que se expande cuando aparece el teclado
   * - Validación de campos en tiempo real usando coordinador
   * - Navegación a LoginScreen mediante TapGestureRecognizer
   * - Scroll automático con espacio dinámico según altura del teclado
   * - Botones personalizados para registro y autenticación con Google
   * - Arquitectura modular con coordinador para lógica de negocio
   * 
   * Los colores se obtienen de app_colors.dart y la lógica del coordinador
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
          controller: _scrollController,
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
                SizedBox(height: 70),
                // Título principal de la pantalla
                Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 25),
                // Texto con enlace para navegar a la pantalla de login
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    children: [
                      TextSpan(text: '¿Ya tienes cuenta? '),
                      TextSpan(
                        text: 'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 19,
                          color: textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navega a la pantalla de login
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Campo de entrada para el nombre de usuario
                TextInput(
                  inputController: _usernameController,
                  promptText: 'Nombre de usuario',
                  icon: Icons.person,
                  hasValidationError: _coordinator.uiState.hasErrorUsername,
                  errorText: _coordinator.uiState.errorMessageUsername,
                  focusNode: _usernameFocusNode,
                  onChanged: _validateUsername,
                ),

                // Campo de entrada para el email con validación en tiempo real
                TextInput(
                  inputController: _emailController,
                  promptText: 'Correo electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  hasValidationError: _coordinator.uiState.hasErrorEmail,
                  errorText: _coordinator.uiState.errorMessageEmail,
                  focusNode: _emailFocusNode,
                  onChanged: _validateEmail,
                ),

                // Campo de entrada para la contraseña
                TextInput(
                  inputController: _passwordController,
                  promptText: 'Contraseña',
                  icon: Icons.lock,
                  hasValidationError: _coordinator.uiState.hasErrorPassword,
                  errorText: _coordinator.uiState.errorMessagePassword,
                  isPassword: true,
                  focusNode: _passwordFocusNode,
                  onChanged: _validatePassword,
                ),

                SizedBox(height: 38),
                // Botón principal para crear cuenta
                BtnBasic(
                  text: _coordinator.uiState.isLoading
                      ? 'Creando cuenta...'
                      : 'Crear cuenta',
                  onPressed: _coordinator.uiState.isLoading
                      ? null
                      : _handleRegister,
                ),
                SizedBox(height: 12),
                // Botón alternativo para autenticación con Google
                GoogleButton(
                  onPressed: _coordinator.uiState.isGoogleLoading
                      ? null
                      : _handleGoogleSignIn,
                  text: _coordinator.uiState.isGoogleLoading
                      ? 'Cargando...'
                      : 'Continuar con Google',
                  isEnabled:
                      !_coordinator.uiState.isGoogleLoading &&
                      !_coordinator.uiState.isLoading,
                ),
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
