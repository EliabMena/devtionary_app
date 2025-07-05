import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  //Atributos de la clase GoogleButton
  final VoidCallback? onPressed;
  final String text;
  final bool isEnabled;

  /*
   * Este constructor inicializa los atributos de la clase GoogleButton.
   * @param "onPressed" Función que se ejecuta cuando se presiona el botón (opcional).
   * @param "text" Texto que se muestra en el botón (opcional, por defecto "Continuar con Google").
   * @param "isEnabled" Indica si el botón está habilitado (opcional, por defecto true).
   *
   * Los parámetros opcionales no tienen que ser declarados al llamar al constructor.
   * Si no se proporcionan, se utilizarán los valores predeterminados.
   *
   * @author Eliab
   */
  const GoogleButton({
    Key? key,
    this.onPressed,
    this.text = "Continuar con Google",
    this.isEnabled = true,
  }) : super(key: key);

  /* Método para construir el widget 
  * Este método es el encargado de construir el widget GoogleButton.
  *
  * Estructura del widget:
  GoogleButton Widget
    │
    ├── Container
    │   ├── width: double.infinity
    │   ├── height: 60
    │   │
    │   └── ElevatedButton
    │       ├── onPressed (función condicional según isEnabled)
    │       ├── style
    │       │   ├── backgroundColor: negro semi-transparente
    │       │   ├── foregroundColor: blanco
    │       │   ├── elevation: 0 (sin sombra modificar de ser necesario)
    │       │   ├── shape: RoundedRectangleBorder
    │       │   │   └── side: BorderSide (borde con borderColor)
    │       │   └── padding: horizontal 20, vertical 12
    │       │
    │       └── Row
    │           ├── mainAxisAlignment: center
    │           ├── mainAxisSize: min
    │           │
    │           ├── Container (Logo de Google)
    │           │   ├── width: 40
    │           │   ├── height: 40
    │           │   └── decoration: AssetImage
    │           │
    │           ├── SizedBox (espacio entre logo y texto)
    │           │
    │           └── Text (texto del botón)
    *
    * El botón tiene un fondo negro semi-transparente y un borde definido.
    * El logo de Google se carga desde assets/imagenes/logoGoogle.png.
    * El Row centra el contenido y usa mainAxisSize.min para ajustar el tamaño.
    * El botón se deshabilita cuando isEnabled es false.
    *
    * Los colores se obtienen de la clase AppColors del archivo app_colors.dart.
  */
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(168, 0, 0, 0),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de Google
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/imagenes/logoGoogle.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texto
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
