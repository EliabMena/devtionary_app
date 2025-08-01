import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/screens/juego_screen.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/nav_button.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

final List<Map<String, dynamic>> Categorias = [
      {
        'id_categoria': 1,
        'nombre': 'comandos',
        'colorStart': Color(0xFF7F00FF),
        'colorEnd': Color(0xFFE100FF),
        'logo': 'assets/SubLogos/1.png',
      },
      {
        'id_categoria': 2,
        'nombre': 'instrucciones',
        'colorStart': Color(0xFF005BEA),
        'colorEnd': Color(0xFF00C6FB),
        'logo': 'assets/SubLogos/2.png',
      },
      {
        'id_categoria': 3,
        'nombre': 'terminos',
        'colorStart': Color(0xFF00C6FB),
        'colorEnd': Color(0xFF43E97B),
        'logo': 'assets/SubLogos/3.png',
      },
    ];

class _SelectionScreenState extends State<SelectionScreen> {
  final int puntuacion = 125;
  var _selectedCategoria = 1;

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
            center: Alignment.bottomCenter,
            radius: MediaQuery.of(context).viewInsets.bottom > 0 ? 1.4 : 0.7,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Mejor puntuación en:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '$puntuacion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
              ),
            ),
            SizedBox(height: 32),
            // --- Selector deslizable de subcategorías (más grande y visible) ---
            Row(
              children: [
                // Selector horizontal deslizable (más alto y con más espacio)
                Expanded(
                  child: Container(
                    height: 230, // Más alto
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.shade900.withOpacity(0.8),
                          Colors.grey.shade800.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: Categorias.length,
                      separatorBuilder: (_, __) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final cat = Categorias[index];
                        final isSelected = cat['id_categoria'] == _selectedCategoria;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategoria = cat['id_categoria'];
                            });
                          },
                          child: Container(
                            width: 130, // Más ancho
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(colors: [cat['colorStart'], cat['colorEnd']]),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  cat['logo'],
                                  width: 80,
                                  height: 80,
                                  color: [5, 7, 12].contains(cat['id_categoria']) ? Colors.white : null,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  cat['nombre'].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 32),
            Center(
              child: _buildDurationButton(
                'Empezar',
                'Tema: ${Categorias.firstWhere((cat) => cat['id_categoria'] == _selectedCategoria)['nombre']}',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
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
                '/quizz',
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

  Widget _buildDurationButton(String duration, String questions) {
    return OutlinedButton(
      onPressed: () {
        if (_selectedCategoria != null) {
          final String categoriaNombre = Categorias.firstWhere(
            (cat) => cat['id_categoria'] == _selectedCategoria)['nombre'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JuegoScreen(categoria: categoriaNombre),
            )
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Por favor, selecciona una subcategoría')),
          );
        }
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
              duration,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              questions,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}