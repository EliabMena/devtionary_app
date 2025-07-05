import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/Utility/validations/email_vlitations.dart';
import 'package:devtionary_app/screens/login_screen.dart';
import 'package:devtionary_app/widgets/btn_basic.dart';
import 'package:devtionary_app/widgets/btn_google.dart';
import 'package:devtionary_app/widgets/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // ScrollController para controlar el scroll
  final ScrollController _scrollController = ScrollController();
  
  // FocusNodes para detectar cuando se selecciona cada input
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  //Variables para validaciones
  //Email
  bool hasErrorEmail = false;
  String? errorMessageEmail;
  /*
    FocusNodes:
      ├── _usernameFocusNode → scroll a posición 100.0
      ├── _emailFocusNode → scroll a posición 150.0
      └── _passwordFocusNode → scroll a posición 200.0

  * Se le agrega un listener (_usernameFocusNode.addListener) a cada
  * FocusNode para detectar cuando se enfoca el campo
  * y hacer scroll a la posición correspondiente.
  * Puedes ajustar las posiciones con los valores de posición en la siguiente línea
  * "_scrollToField(VALOR A MODIFICAR)" para que se ajusten a tu diseño.
  *
  * @author Eliab
  */
  @override
  void initState() {
    super.initState();
    // Listeners para detectar cuando se enfocan los campos
    _usernameFocusNode.addListener(() {
      if (_usernameFocusNode.hasFocus) {
        _scrollToField(100.0); // Posición aproximada del campo usuario
      }
    });
    
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        _scrollToField(150.0); // Posición aproximada del campo email
      }
    });
    
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _scrollToField(200.0); // Posición aproximada del campo contraseña
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /*
  * Función para hacer scroll a un campo específico
  * Recibe la posición a la que se debe desplazar el scroll
  * y se usa Future.delayed para esperar un poco antes de hacer el scroll
  */
  void _scrollToField(double position) {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          position,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  /*
  *Estructura del widget RegisterScreen

  RegisterScreen Widget
      │
      ├── Scaffold
      │   ├── resizeToAvoidBottomInset: false
      │   │
      │   └── AnimatedContainer
      │       ├── duration: 300ms
      │       ├── curve: Curves.easeInOut
      │       ├── width: double.infinity
      │       ├── height: MediaQuery.size.height
      │       ├── decoration
      │       │   └── gradient: RadialGradient
      │       │       ├── colors: [primaryGradientColor, secondaryGradientColor, Colors.black]
      │       │       ├── stops: [0.2, 0.4, 0.7]
      │       │       ├── center: Alignment.bottomCenter
      │       │       └── radius: dinamico (1.6 con teclado, 1 sin teclado)
      │       │
      │       └── SingleChildScrollView
      │           ├── controller: _scrollController
      │           │
      │           └── Padding
      │               ├── padding: EdgeInsets.all(25.0)
      │               │
      │               └── Column
      │                   ├── crossAxisAlignment: CrossAxisAlignment.start│
      │                   │
      │                   ├── Image.asset (Logo Devtionary)
      │                   │
      │                   ├── SizedBox (height: 40)
      │                   │
      │                   ├── Text ('Sing up')
      │                   │
      │                   ├── SizedBox (height: 25)
      │                   │
      │                   ├── RichText (Ya tienes una cuenta? + Inicia sesión)
      │                   │   ├── TextSpan (Ya tienes una cuenta?)
      │                   │   └── TextSpan (Inicia sesión)
      │                   │
      │                   ├── SizedBox (height: 20)
      │                   │
      │                   ├── TextInput (Usuario)
      │                   │   ├── inputController: _usernameController
      │                   │   ├── promptText: 'Nombre de usuario'
      │                   │   ├── icon: Icons.person
      │                   │   └── focusNode: _usernameFocusNode
      │                   │
      │                   ├── TextInput (Email)
      │                   │   ├── inputController: _emailController
      │                   │   ├── promptText: 'Correo electrónico'
      │                   │   ├── icon: Icons.email
      │                   │   ├── keyboardType: TextInputType.emailAddress
      │                   │   ├── hasValidationError: hasErrorEmail
      │                   │   ├── errorText: errorMessageEmail
      │                   │   ├── focusNode: _emailFocusNode
      │                   │   └── onChanged: EmailValidation.validateEmail
      │                   │
      │                   ├── TextInput (Contraseña)
      │                   │   ├── inputController: _passwordController
      │                   │   ├── promptText: 'Contraseña'
      │                   │   ├── icon: Icons.lock
      │                   │   └── focusNode: _passwordFocusNode
      │                   │
      │                   ├── SizedBox (height: 38)
      │                   │
      │                   ├── BtnBasic
      │                   │   └── text: 'Crear cuenta'
      │                   │
      │                   ├── SizedBox (height: 12)
      │                   │
      │                   ├── GoogleButton
      │                   │   └── onPressed: AUN POR ACTULIZAR
      │                   │
      │                   └── SizedBox (height: MediaQuery.viewInsets.bottom)

  * MediaQuery. es una propiedad que permite obtener información sobre el tamaño de la pantalla y el estado del teclado.
  * MediaQuery.of(context).size.height, es la altura total de la pantalla.
  * MediaQuery.viewInsets.bottom es la altura del teclado cuando está visible.
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // No cambia el tamaño del widget al mostrar el teclado
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
          controller: _scrollController, // Agregar el controller
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
              children: [
                SizedBox(height: 0),
                    // Logo Devtionary
                    Image.asset(
                      'assets/imagenes/logo.png',
                      height: 100,
                      width: 140,
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Sing up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 25),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(text: 'Ya tienes una cuenta? '),
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              fontSize: 22,
                              color: textPrimaryColor,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                              },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    TextInput(
                      inputController: _usernameController,
                      promptText: 'Nombre de usuario',
                      icon: Icons.person,
                      hasValidationError: false,
                      focusNode: _usernameFocusNode,
                    ),
                    TextInput(
                      inputController: _emailController,
                      promptText: 'Correo electrónico',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      hasValidationError: hasErrorEmail,
                      errorText: errorMessageEmail,
                      focusNode: _emailFocusNode,
                      onChanged: (value) {
                        String? error = EmailValidation.validateEmail(value);
                        setState(() {
                          errorMessageEmail = error;
                          hasErrorEmail = error != null;
                        });
                      },
                    ),
                    TextInput(
                      inputController: _passwordController,
                      promptText: 'Contraseña',
                      icon: Icons.lock,
                      hasValidationError: false,
                      focusNode: _passwordFocusNode,
                    ),
                    SizedBox(height: 38),
                    BtnBasic(text: 'Crear cuenta'),
                    SizedBox(height: 12),
                    GoogleButton(
                      onPressed: () {
                        // VACIO POR EL MOMENTO
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom,),
                    // Espacio para el teclado
              ],
            ),
          ),
        ),
      ),
    );
  }
}