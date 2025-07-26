import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:devtionary_app/widgets/search_bar.dart';

class WordCardsScreen extends StatefulWidget {
  @override
  _WordCardsScreenState createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends State<WordCardsScreen> {
  // Índice actual del navbar (1 = Búsqueda activa)
  int _currentIndex = 1;

  // Controlador para la barra de búsqueda
  final TextEditingController _searchController = TextEditingController();

  // Datos de la palabra
  Map<String, dynamic> wordData = {
    'word': 'Palabra',
    'subtitle': 'A que pertenece',
    'description':
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
    'isFavorite': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FONDO CON DEGRADADO
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-1.0, 0.4),
            radius: 0.4,
            colors: [
              Color.fromARGB(255, 1, 84, 95),
              Color.fromARGB(255, 8, 71, 29),
              Color.fromARGB(255, 5, 41, 17),
              Color.fromARGB(255, 1, 8, 3),
            ],
            stops: [0.0, 0.3, 0.6, 1.0], // Distribución de colores
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== APP BAR PERSONALIZADO CON BARRA DE BÚSQUEDA =====
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(
                          context,
                        ); // Regresar a la pantalla anterior
                      },
                    ),
                    Expanded(
                      child: CustomSearchBar(
                        controller: _searchController,
                        hintText: 'Buscar término',
                        onChanged: (value) {
                          // implementar la lógica de búsqueda
                          print('Buscando: $value');
                        },
                        onSubmitted: (value) {
                          // Cuando el usuario presiona Enter
                          print('Búsqueda enviada: $value');
                        },
                      ),
                    ),
                  ],
                ),
              ),

              //  CONTENIDO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [const SizedBox(height: 40), _buildWordCard()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      //  NAVBAR
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Navegación entre pantallas
          _navigateToScreen(index);
        },
      ),
    );
  }

  //  MÉTODO PARA CREAR LA TARJETA DE PALABRA
  Widget _buildWordCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //  HEADER CON COLOR SÓLIDO
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 1, 84, 95),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Círculo con letra inicial
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      wordData['word'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Información de la palabra
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wordData['word'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        wordData['subtitle'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ===== ÁREA GRIS PARA IMAGEN =====
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.settings_outlined,
                    size: 30,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.description_outlined,
                    size: 30,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

          // ÁREA DE CONTENIDO CON GRADIENTE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 1, 84, 95),
                  Color.fromARGB(255, 20, 170, 70),
                ],
                stops: [0.0, 1.0],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título en área con gradiente
                Text(
                  wordData['word'],
                  style: const TextStyle(
                    color: Colors.white, // TEXTO BLANCO PARA CONTRASTE
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  wordData['subtitle'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Descripción
                Text(
                  wordData['description'],
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de favorito
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        wordData['isFavorite'] = !wordData['isFavorite'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: wordData['isFavorite']
                            ? Colors.red.withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        wordData['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: wordData['isFavorite']
                            ? Colors.red[200]
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  NAVEGACIÓN ENTRE PANTALLAS
  void _navigateToScreen(int index) {
    // Solo navega si NO está ya en la pantalla actual
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Favoritos
        print('Navegar a Favoritos');
        break;
      case 1: // Búsqueda (esta pantalla)
        break;
      case 2: // Inicio
        print('Navegar a Inicio');
        break;
      case 3: // Quizzes
        print('Navegar a Quizzes');
        break;
      case 4: // Perfil
        print('Navegar a Perfil');
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PerfilScreen()));
        break;
    }
  }

  @override
  void dispose() {
    _searchController
        .dispose(); // Limpia el controlador cuando se destruye la pantalla
    super.dispose();
  }
}
