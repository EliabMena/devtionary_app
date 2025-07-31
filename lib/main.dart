import 'package:devtionary_app/screens/favoritos_screen.dart';
import 'package:devtionary_app/screens/main_menu.dart';
import 'package:devtionary_app/screens/perfil_screen.dart';
import 'package:devtionary_app/screens/register_screen.dart';
import 'package:devtionary_app/screens/login_screen.dart';
import 'package:devtionary_app/screens/search_screen.dart';
import 'package:devtionary_app/screens/word_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';

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
      // Tema oscuro personalizado
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryGreen,
          background: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: AppColors.darkTextPrimary,
          onSurface: AppColors.darkTextPrimary,
        ),
        scaffoldBackgroundColor: AppColors.darkBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.darkInputFill,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryBlue),
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.darkIcon),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
      // Tema claro personalizado
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryGreen,
          background: AppColors.lightBackground,
          surface: AppColors.lightSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: AppColors.lightTextPrimary,
          onSurface: AppColors.lightTextPrimary,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: AppColors.lightInputFill,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryBlue),
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.lightIcon),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
        ),
      ),
      // Usar el tema del sistema automáticamente
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/search': (context) => SearchScreen(),
        '/main_menu': (context) => MainMenu(),
        '/targetas': (context) => WordCardsScreen(),
        '/SearchScreen': (context) => SearchScreen(),
        '/favoritos': (context) => FavoritosScreen(),
        '/perfil': (context) => PerfilScreen(),
      },
    );
  }
}
