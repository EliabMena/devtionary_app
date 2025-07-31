import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/db/repositorios/subcategorias_repository.dart';
import 'package:devtionary_app/widgets/lista_categorias.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  Future<List<String>> obtenerRecientes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recientes') ?? [];
  }
  
  // Recupera la información de la palabra desde SharedPreferences (puedes guardar más info si lo necesitas)
  Future<Map<String, dynamic>?> obtenerInfoPalabra(String palabra) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('info_palabra_$palabra');
    if (jsonString == null) return null;
    return Map<String, dynamic>.from(json.decode(jsonString));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo oscuro
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
                          recientes[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          final info = await obtenerInfoPalabra(
                            recientes[index],
                          );
                          if (info != null) {
                            Navigator.pushNamed(
                              context,
                              '/targetas',
                              arguments: info,
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
                  ), 
                ),
                SizedBox(height: 15),
                Text('Instrucciones'),
                SizedBox( 
                  width: double.infinity, 
                  child: HorizontalCategoryList(
                    subcategoriasFuture: SubcategoriasRepository().getSubcategoriasByCategoryId(2), 
                  ), 
                ),
                SizedBox(height: 15),
                Text('Términos'),
                SizedBox( 
                  width: double.infinity, 
                  child: HorizontalCategoryList(
                    subcategoriasFuture: SubcategoriasRepository().getSubcategoriasByCategoryId(3), 
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
              Navigator.pushNamed(
                context,
                '/favoritos',
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/search');
              break;
            case 2:
              Navigator.pushNamed(context, '/main_menu');
              break;
            case 3:
              Navigator.pushNamed(
                context,
                '',
              ); //falta implementación de la pantalla de quizzes
              break;
            case 4:
              Navigator.pushNamed(
                context,
                '/perfil',
              ); //falta implementación de la pantalla de perfil
              break;
          }
        },
      ),
    );
  }
}

class Categoria {
  final String nombre;

  Categoria({required this.nombre});
}
