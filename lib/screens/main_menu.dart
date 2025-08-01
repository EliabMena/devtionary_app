import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/db/repositorios/subcategorias_repository.dart';
import 'package:devtionary_app/widgets/lista_categorias.dart';
import 'package:devtionary_app/db/database_helper.dart';

// ✅ Funciones fuera de la clase
Future<List<String>> obtenerRecientes() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('recientes') ?? [];
}

Future<Map<String, dynamic>?> obtenerInfoPalabra(String palabra) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('info_palabra_$palabra');
  if (jsonString == null) return null;
  try {
    return Map<String, dynamic>.from(json.decode(jsonString));
  } catch (e) {
    print('Error al decodificar info_palabra_$palabra: $e');
    return null;
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Menú Principal'),
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primaryGradientColor,
              secondaryGradientColor,
              Colors.black,
            ],
            stops: [0.2, 0.4, 0.7],
            center: Alignment.centerLeft,
            radius: MediaQuery.of(context).viewInsets.bottom > 0 ? 1.4 : 0.7,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Sección Recientemente
            Text(
              'Recientemente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            FutureBuilder<List<String>>(
              future: obtenerRecientes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final recientes = snapshot.data ?? [];
                if (recientes.isEmpty) {
                  return Text(
                    'No hay actividades recientes',
                    style: TextStyle(color: Colors.white70),
                  );
                }
                return Column(
                  children: List.generate(recientes.length, (index) {
                    final palabra = recientes[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C6FB), Color(0xFF43E97B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        title: Text(
                          palabra,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          final resultado = await DatabaseHelper.buscarPorNombre(palabra);
                          if (resultado != null) {
                            Navigator.pushNamed(
                              context,
                              '/targetas',
                              arguments: resultado,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('No se encontró información para "$palabra"'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }),
                );
              },
            ),
            SizedBox(height: 32),

            // Sección Categorías
            Text(
              'Categorías',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Column(
              children: [
                Text('Comandos'),
                SizedBox(
                  width: double.infinity,
                  child: HorizontalCategoryList(
                    subcategoriasFuture: SubcategoriasRepository().getSubcategoriasByCategoryId(1),
                    cardSize: 230,
                    iconSize: 80,
                  ),
                ),
                SizedBox(height: 15),
                Text('Instrucciones'),
                SizedBox(
                  width: double.infinity,
                  child: HorizontalCategoryList(
                    subcategoriasFuture: SubcategoriasRepository().getSubcategoriasByCategoryId(2),
                    cardSize: 190,
                    iconSize: 66,
                  ),
                ),
                SizedBox(height: 15),
                Text('Términos'),
                SizedBox(
                  width: double.infinity,
                  child: HorizontalCategoryList(
                    subcategoriasFuture: SubcategoriasRepository().getSubcategoriasByCategoryId(3),
                    cardSize: 182,
                    iconSize: 59,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/favoritos');
              break;
            case 1:
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              // Evita bucle si ya estás aquí
              break;
            case 3:
              Navigator.pushNamed(context, '/quizz');
              break;
            case 4:
              Navigator.pushNamed(context, '/perfil');
              break;
          }
        },
      ),
    );
  }
}