import 'package:devtionary_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

void main() {
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
      home: RegisterScreen(), // Aquí llamamos a la pantalla de registro
    );
  }
}