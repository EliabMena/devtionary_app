import 'package:flutter/material.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';

/// Widget personalizado para barra de navegación inferior con círculo flotante
/// Replica exactamente el diseño con degradado azul-verde
///
/// ARCHIVO: lib/widgets/nav_button.dart
class CustomBottomNavBar extends StatelessWidget {
  /// Índice de la pestaña actualmente seleccionada
  final int currentIndex;

  /// Función que se ejecuta cuando se toca una pestaña
  final Function(int) onTap;

  /// Íconos exactos como en tu diseño original
  final List<IconData> icons;

  /// Etiquetas exactas como en tu diseño original
  final List<String> labels;

  static const List<String?> routes = [
    '/favoritos',
    '/SearchScreen',
    '/main_menu',
    null, // Quizzes
    null, // Perfil
  ];

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.icons = const [
      Icons.favorite_border_sharp, // Favoritos
      Icons.search, // Búsqueda
      Icons.home_outlined, // Inicio
      Icons.schedule, // Quizzes
      Icons.person_outline, // Perfil
    ],
    this.labels = const [
      'Favoritos',
      'Búsqueda',
      'Inicio',
      'Quizzes',
      'Perfil',
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none, // Permite que elementos sobresalgan
        children: [
          // ===== BARRA DE NAVEGACIÓN BASE =====
          Container(
            height: 65, // Altura fija y compacta
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                onTap(index);
                final route = routes[index];
                if (route != null &&
                    ModalRoute.of(context)?.settings.name != route) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,

              // Colores del texto más claros para mejor legibilidad
              selectedItemColor: Colors.grey[300],
              unselectedItemColor: Colors.grey[300],

              // Tamaño del texto
              selectedFontSize: 14,
              unselectedFontSize: 14,

              // Solo muestra labels en íconos inactivos
              showSelectedLabels: false,
              showUnselectedLabels: true,

              // Íconos sin el círculo (solo íconos normales)
              items: List.generate(icons.length, (index) {
                return BottomNavigationBarItem(
                  icon: currentIndex == index
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                        ) // Espacio vacío para el activo
                      : Icon(icons[index], color: Colors.grey[400], size: 24),
                  label: labels[index],
                );
              }),
            ),
          ),

          // ===== CÍRCULO FLOTANTE CON DEGRADADO =====
          // Este círculo sobresale hacia arriba del navbar gris
          Positioned(
            top: -20, // Sobresale hacia arriba del contenedor gris
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                // Solo muestra el círculo para el elemento activo
                if (currentIndex == index) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // DEGRADADO EXACTO: Azul claro a verde
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.lightBlueAccent, // Color inicial
                          Colors.green, // Color final
                        ],
                        stops: [0.0, 1.0], // Distribución del degradado
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(
                            0.3,
                          ), // Sombra con color del degradado
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icons[index],
                      color: Colors.white,
                      size: 32, // Tamaño del ícono dentro del círculo
                    ),
                  );
                } else {
                  // Espacio vacío para mantener el espaciado
                  return const SizedBox(width: 40);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}
