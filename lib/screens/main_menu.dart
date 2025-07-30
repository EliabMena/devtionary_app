import 'package:devtionary_app/widgets/tarjeta_categoria.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/db/db_models/subcategorias.dart';
import 'dart:convert';
import 'package:devtionary_app/screens/word_cards_screen.dart';
//import 'package:devtionary_app/db/database_helper.dart';
import 'package:devtionary_app/db/repositorios/subcategorias_repository.dart';

class MainMenu extends StatelessWidget {

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
      body: ListView(
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
                return Text('No hay actividades recientes', style: TextStyle(color: Colors.white70));
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
                      leading: Icon(Icons.arrow_forward_ios, color: Colors.white),
                      title: Text(
                        recientes[index],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    onTap: () async {
                      final info = await obtenerInfoPalabra(recientes[index]);
                      if (info != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordCardsScreen(
                              wordData: info,
                            ),
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
          FutureBuilder<List<Subcategorias>>(
            future: SubcategoriasRepository().getSubcategoriasLocales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No hay categorías', style: TextStyle(color: Colors.white70)));
              }
              final subcategorias = snapshot.data!;
              return SizedBox(
                height: 140,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(subcategorias.length, (index) {
                      final cat = subcategorias[index];
                      List<Color> gradient;
                      Widget iconWidget;
                      switch (cat.id_subcategoria.toString()) {
                        case '1':
                          gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                          iconWidget = Text('Docker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        case '2':
                          gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                          iconWidget = Text('Git Bash', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        case '3':
                          gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                          iconWidget = Text('Linux', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        case '4':
                          gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                          iconWidget = Text('Docker', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        case '5':
                          gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                          iconWidget = Text('Git Bash', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        case '6':
                          gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                          iconWidget = Text('Linux', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 22));
                          break;
                        default:
                          gradient = [Colors.grey.shade800, Colors.grey.shade600];
                          iconWidget = Icon(Icons.code, color: Colors.white, size: 28);
                      }
                      return Container(
                        width: 140,
                        margin: EdgeInsets.only(right: 12),
                        child: TarjetaCategoria(
                          nombre: cat.nombre,
                          gradient: gradient,
                          icono: iconWidget,
                        ),
                      );
                    }),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class Categoria {
  final String nombre;

  Categoria({required this.nombre});
}