import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WordCardsScreen extends StatefulWidget {
  const WordCardsScreen({Key? key}) : super(key: key);
  @override
  _WordCardsScreenState createState() => _WordCardsScreenState();
}

class _WordCardsScreenState extends State<WordCardsScreen> {
  // Índice actual del navbar (1 = Búsqueda activa)
  int _currentIndex = 1;

  // Controlador para la barra de búsqueda
  final TextEditingController _searchController = TextEditingController();

  late Map<String, dynamic> wordData;

  // --- FAVORITOS API ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> addFavorite(String termino) async {
    final token = await _getToken();
    print('[addFavorite] token: $token');
    if (token == null) {
      print('[addFavorite] No token found');
      return false;
    }
    final url = Uri.parse(
      'https://devtionary-api-production.up.railway.app/api/user/favoritos',
    );
    print('[addFavorite] url: $url');
    final body = jsonEncode({'termino': termino});
    print('[addFavorite] body: $body');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('[addFavorite] statusCode: ${response.statusCode}');
      print('[addFavorite] response.body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 404 &&
          response.body.contains('Usuario no encontrado')) {
        // Intentar crear el usuario en el backend y reintentar
        final prefs = await SharedPreferences.getInstance();
        final username = prefs.getString('username') ?? 'Usuario Google';
        final email = prefs.getString('email') ?? 'Sin correo';
        final fechaRegistro =
            prefs.getString('fechaRegistro') ??
            DateTime.now().toIso8601String();
        final createUserUrl = Uri.parse(
          'https://devtionary-api-production.up.railway.app/api/user/create',
        );
        final createUserBody = jsonEncode({
          'username': username,
          'email': email,
          'fechaRegistro': fechaRegistro,
        });
        final createUserResponse = await http.post(
          createUserUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: createUserBody,
        );
        print(
          '[addFavorite] createUser status: ${createUserResponse.statusCode}',
        );
        print('[addFavorite] createUser body: ${createUserResponse.body}');
        if (createUserResponse.statusCode == 201 ||
            createUserResponse.statusCode == 200) {
          // Reintentar agregar favorito
          final retryResponse = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: body,
          );
          print('[addFavorite] retry status: ${retryResponse.statusCode}');
          print('[addFavorite] retry body: ${retryResponse.body}');
          return retryResponse.statusCode == 200 ||
              retryResponse.statusCode == 201;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('[addFavorite] error: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String termino) async {
    final token = await _getToken();
    print('[removeFavorite] token: $token');
    if (token == null) {
      print('[removeFavorite] No token found');
      return false;
    }
    final url = Uri.parse(
      'https://devtionary-api-production.up.railway.app/api/user/favoritos',
    );
    print('[removeFavorite] url: $url');
    final body = jsonEncode({'termino': termino});
    print('[removeFavorite] body: $body');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      print('[removeFavorite] statusCode: ${response.statusCode}');
      print('[removeFavorite] response.body: ${response.body}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[removeFavorite] error: $e');
      return false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Mapear los campos esperados desde la base de datos
      wordData = {
        'word':
            args['nombre_termino'] ??
            args['nombre_comando'] ??
            args['nombre_instruccion'] ??
            'Palabra',
        'subtitle': args['tabla'] ?? 'Desconocido',
        'description': args['descripcion']?.toString() ?? '',
        'isFavorite': false,
        ...args,
      };
    } else {
      wordData = {
        'word': 'Palabra',
        'subtitle': 'A que pertenece',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
        'isFavorite': false,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
            radius: MediaQuery.of(context).viewInsets.bottom > 0 ? 1 : 1.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== APP BAR SOLO CON BOTÓN DE REGRESO =====
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
          _navigateToScreen(index);
        },
      ),
    );
  }

  //  MÉTODO PARA CREAR LA TARJETA DE PALABRA
  Widget _buildWordCard() {
    return GestureDetector(
      child: Container(
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

                  // ===== EJEMPLOS =====
                  ..._buildExamples(),

                  // Botón de favorito
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        bool success = false;
                        if (!wordData['isFavorite']) {
                          success = await addFavorite(wordData['word']);
                        } else {
                          success = await removeFavorite(wordData['word']);
                        }
                        if (success) {
                          setState(() {
                            wordData['isFavorite'] = !wordData['isFavorite'];
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al actualizar favorito'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
      ),
    );
  }

  //  MÉTODO PARA CONSTRUIR LOS EJEMPLOS
  List<Widget> _buildExamples() {
    final List<Widget> exampleWidgets = [];
    final List<String> examples = [];

    // Recolectar todos los ejemplos no nulos
    if (wordData['ejemplo'] != null && wordData['ejemplo'].isNotEmpty) {
      examples.add(wordData['ejemplo']);
    }
    if (wordData['ejemplo_2'] != null && wordData['ejemplo_2'].isNotEmpty) {
      examples.add(wordData['ejemplo_2']);
    }
    if (wordData['ejemplo_3'] != null && wordData['ejemplo_3'].isNotEmpty) {
      examples.add(wordData['ejemplo_3']);
    }

    if (examples.isNotEmpty) {
      // Título para la sección de ejemplos
      exampleWidgets.add(
        const Text(
          'Ejemplo(s):',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      exampleWidgets.add(const SizedBox(height: 8));

      // Contenedor para los ejemplos
      exampleWidgets.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examples.map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '• $example', // Viñeta para cada ejemplo
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
      exampleWidgets.add(const SizedBox(height: 16));
    }

    return exampleWidgets;
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
