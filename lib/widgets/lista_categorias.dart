import 'package:devtionary_app/db/db_models/subcategorias.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/tarjeta_categoria.dart';

class HorizontalCategoryList extends StatelessWidget { 
  final Future<List<Subcategorias>> subcategoriasFuture; 
  const HorizontalCategoryList({ Key? key, required this.subcategoriasFuture, }) : super(key: key); 
  @override 
  Widget build(BuildContext context) { 
    return SizedBox( 
      width: 230, 
      height: 230, 
      child: FutureBuilder<List<Subcategorias>>( 
        future: subcategoriasFuture, 
        builder: (context, snapshot) { 
          if (snapshot.connectionState == ConnectionState.waiting) {
             return Center( 
              child: CircularProgressIndicator( 
                color: Colors.blue, 
              ), 
            ); 
          } 
          else if (snapshot.hasError) {
            return Center( 
              child: Text(
                'Error', 
                style: TextStyle(
                  color: Colors.red
                ), 
              ), 
            ); 
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center( 
              child: Text( 
                'Sin datos', 
                style: TextStyle(
                  color: Colors.grey
                ), 
              ), 
            ); 
          } // Si todo está bien, obtenemos la lista 
          
          final subcategorias = snapshot.data!; 
          return SingleChildScrollView( 
            scrollDirection: Axis.horizontal, 
            child: Row( 
              children: List.generate(subcategorias.length, (index) {
                final cat = subcategorias[index]; 
                List<Color> gradient; 
                Widget iconWidget; 
                switch (cat.id_subcategoria.toString()) {
                    case '1': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '2': 
                    gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '3': 
                    gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '4': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png',  
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '5': 
                    gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      color: Colors.white,
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '6': 
                    gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '7': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      color: Colors.white,
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '8': 
                    gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '9': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '10': 
                    gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '11': 
                    gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '12': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      color: Colors.white,
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '13': 
                    gradient = [Color(0xFF005BEA), Color(0xFF00C6FB)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '14': 
                    gradient = [Color(0xFF00C6FB), Color(0xFF43E97B)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  case '15': 
                    gradient = [Color(0xFF7F00FF), Color(0xFFE100FF)]; 
                    iconWidget = Image.asset(
                      'assets/SubLogos/${subcategorias[index].id_subcategoria}.png', 
                      width: 80, 
                      height: 80, 
                    );
                    break; 
                  default: 
                    gradient = [ Colors.grey.shade800, Colors.grey.shade600, ]; 
                    iconWidget = Icon(
                      Icons.code, 
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
                }
              ), 
            ), 
          ); 
        }, 
      ), 
    ); 
  } 
}