import 'package:devtionary_app/screens/favoritos_screen.dart';
import 'package:devtionary_app/screens/main_menu.dart';
import 'package:devtionary_app/screens/register_screen.dart';
import 'package:devtionary_app/screens/login_screen.dart';
import 'package:devtionary_app/screens/search_screen.dart';
import 'package:devtionary_app/screens/word_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con la configuración del proyecto
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Devtionary App',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/search': (context) => SearchScreen(),
        '/main_menu': (context) => MainMenu(),
        '/targetas': (context) => WordCardsScreen(),
        '/SearchScreen': (context) => SearchScreen(),
        '/favoritos': (context) => FavoritosScreen(),
      },
    );
  }
}
