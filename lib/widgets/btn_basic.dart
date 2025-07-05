import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';

class BtnBasic extends StatelessWidget {
  //Atributos de la clase BtnBasic
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  /*
   * Este constructor inicializa los atributos de la clase BtnBasic.
   * @param "text" Texto que se muestra en el botón.
   * @param "onPressed" Función que se ejecuta cuando se presiona el botón (opcional).
   * @param "width" Ancho del botón (opcional, por defecto ocupa todo el ancho disponible).
   * @param "height" Alto del botón (opcional, por defecto 60).
   *
   * Los parámetros opcionales no tienen que ser declarados al llamar al constructor.
   * Si no se proporcionan, se utilizarán los valores predeterminados.
   *
   * @author Eliab
   */
  const BtnBasic({
    Key? key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 60, // tamaño del boton
  }) : super(key: key);

  /* Método para construir el widget 
  * Este método es el encargado de construir el widget BtnBasic.
  *
  * Estructura del widget:
  BtnBasic Widget
    │
    ├── Container
    │   ├── width (ancho del botón)
    │   ├── height (alto del botón)
    │   ├── margin (márgenes verticales)
    │   ├── decoration
    │   │   ├── gradient (degradado lineal)
    │   │   │   ├── colors: [secondaryColor, primaryColor]
    │   │   │   ├── begin: Alignment.centerLeft
    │   │   │   └── end: Alignment.centerRight
    │   │   ├── borderRadius: 25
    │   │   └── boxShadow (sombra del botón)
    │   │
    │   └── Material
    │       └── InkWell
    │           ├── onTap (función onPressed)
    │           ├── borderRadius: 25
    │           │
    │           └── Container
    │               └── Text (texto del botón)
    *
    * El botón tiene un gradiente lineal que va del color secundario al primario.
    * El Material e InkWell proporcionan el efecto de "ripple" cuando se presiona.
    * La sombra le da profundidad visual al botón.
    *
    * Los colores se obtienen de la clase AppColors del archivo app_colors.dart.
  */
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            secondaryColor,
            primaryColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
