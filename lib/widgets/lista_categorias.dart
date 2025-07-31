import 'package:devtionary_app/db/db_models/subcategorias.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/tarjeta_categoria.dart';

class HorizontalCategoryList extends StatelessWidget {
  final List<Subcategorias> subcategorias;

  const HorizontalCategoryList({Key? key, required this.subcategorias}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
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
                iconWidget = Text(
                  'Docker',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '2':
                gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                iconWidget = Text(
                  'Git Bash',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '3':
                gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                iconWidget = Text(
                  'Linux',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '4':
                gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                iconWidget = Text(
                  'MacOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '5':
                gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                iconWidget = Text(
                  'Windows',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '6':
                gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                iconWidget = Text(
                  'C++',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '7':
                gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                iconWidget = Text(
                  'C#',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '8':
                gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                iconWidget = Text(
                  'Java',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '9':
                gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                iconWidget = Text(
                  'Javascript',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '10':
                gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                iconWidget = Text(
                  'Python',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '11':
                gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                iconWidget = Text(
                  'Desarrollo Web',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '12':
                gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                iconWidget = Text(
                  'Herramientas y Desarrollo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '13':
                gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)];
                iconWidget = Text(
                  'Paradigmas de Programación',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '14':
                gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)];
                iconWidget = Text(
                  'Programación de Sistemas',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              case '15':
                gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)];
                iconWidget = Text(
                  'Sistemas y Arquitectura',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
                break;
              default:
                gradient = [
                  Colors.grey.shade800,
                  Colors.grey.shade600,
                ];
                iconWidget = Icon(
                  Icons.code,
                  color: Colors.white,
                  size: 28,
                );
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
  }
}