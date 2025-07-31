import 'package:flutter/material.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';

class ResultadoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final int? idSubcategoria;
  final VoidCallback? onTap;

  const ResultadoCard({
    Key? key,
    required this.titulo,
    required this.subtitulo,
    this.idSubcategoria,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: textPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitulo,
                      style: TextStyle(color: textPrimaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: idSubcategoria != null
                    ? Image.asset(
                        'assets/SubLogos/${idSubcategoria}.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      )
                    : Icon(Icons.category, color: iconColor, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
