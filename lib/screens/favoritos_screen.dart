import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:devtionary_app/db/database_helper.dart';
import 'dart:convert';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({Key? key}) : super(key: key);
  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  // Para mostrar el subtitle dinámico
  Future<String> obtenerDescripcion(String nombre) async {
    final resultado = await DatabaseHelper.buscarPorNombre(nombre);
    if (resultado == null) return '';
    if (resultado['tabla'] == 'terminos') {
      return resultado['descripcion']?.toString() ?? '';
    } else {
      return resultado['descripcion']?.toString() ?? '';
    }
  }

  Future<void> deleteFavorito(String termino) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    final url = Uri.parse(
      'https://devtionary-api-production.up.railway.app/api/user/favoritos',
    );
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'termino': termino}),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchFavoritos();
      }
    } catch (e) {}
  }

  int _currentIndex = 0;

  List<String> favoritos = [];
  List<String> filteredFavoritos = [];
  bool isLoading = true;
  String searchQuery = '';
  bool isAlphabetical = false;

  @override
  void initState() {
    super.initState();
    fetchFavoritos();
  }

  void applyFilters() {
    List<String> temp = List.from(favoritos);
    if (searchQuery.isNotEmpty) {
      temp = temp
          .where((fav) => fav.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    if (isAlphabetical) {
      temp.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    setState(() {
      filteredFavoritos = temp;
    });
  }

  Future<void> fetchFavoritos() async {
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        favoritos = [];
        filteredFavoritos = [];
        isLoading = false;
      });
      return;
    }
    final url = Uri.parse(
      'https://devtionary-api-production.up.railway.app/api/user/favoritos',
    );
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        favoritos = data.map((e) => e.toString()).toList();
      } else {
        favoritos = [];
      }
    } catch (e) {
      favoritos = [];
    }
    applyFilters();
    setState(() {
      isLoading = false;
    });
  }
  // ...existing code...
  // Eliminar duplicación y corregir cierre de clase

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primaryGradientColor,
              secondaryGradientColor,
              Colors.black,
            ],
            stops: [0.2, 0.4, 0.7],
            center: Alignment.bottomLeft,
            radius: 1.7,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Logo
              Image.asset('assets/imagenes/logo.png', height: 60),
              const SizedBox(height: 8),
              // Corazón con degradado rojo-morado
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE040FB), // Morado
                      Color(0xFFD500F9), // Morado fuerte
                      Color(0xFFF50057), // Rojo fuerte
                      Color(0xFFFF4081), // Rosa
                    ],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.favorite,
                  size: 74,
                  color: Colors.white,
                ),
              ),
              // Título y corazón
              const SizedBox(height: 16),
              const Text(
                'Tus Favoritos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Filtros de búsqueda y orden
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        onChanged: (value) {
                          searchQuery = value;
                          applyFilters();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: isAlphabetical
                          ? 'Quitar orden alfabético'
                          : 'Ordenar alfabéticamente',
                      child: IconButton(
                        icon: Icon(
                          Icons.sort_by_alpha,
                          color: isAlphabetical
                              ? Colors.purpleAccent
                              : Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isAlphabetical = !isAlphabetical;
                          });
                          applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Lista de favoritos
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredFavoritos.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes favoritos aún.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredFavoritos.length,
                        itemBuilder: (context, index) {
                          final fav = filteredFavoritos[index];
                          return FutureBuilder<String>(
                            future: obtenerDescripcion(fav),
                            builder: (context, snapshot) {
                              final descripcion =
                                  (snapshot.hasData && snapshot.data != null)
                                  ? snapshot.data!
                                  : '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.tealAccent,
                                    width: 2,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () async {
                                    final resultado =
                                        await DatabaseHelper.buscarPorNombre(
                                          fav,
                                        );
                                    if (resultado != null) {
                                      Navigator.pushNamed(
                                        context,
                                        '/targetas',
                                        arguments: resultado,
                                      );
                                    }
                                  },
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        0,
                                        66,
                                        66,
                                        66,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Color.fromARGB(255, 212, 111, 111),
                                      size: 28,
                                    ),
                                  ),
                                  title: Text(
                                    fav,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    descripcion,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: 'Eliminar favorito',
                                    onPressed: () async {
                                      await deleteFavorito(fav);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navegación automática
        },
      ),
    );
  }
}
