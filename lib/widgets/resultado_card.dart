import 'package:flutter/material.dart';

class ResultadoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List<IconData>? icons;
  final VoidCallback? onTap;

  const ResultadoCard({
    Key? key,
    required this.titulo,
    required this.subtitulo,
    this.icons,
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
          gradient: const LinearGradient(
            colors: [Color(0xFF00C6FB), Color(0xFF43E97B)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: icons != null
                    ? icons!.map((icon) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(icon, color: Colors.grey[400], size: 28),
                        )).toList()
                    : [
                        Icon(Icons.category, color: Colors.grey[400], size: 28),
                        Icon(Icons.star_border, color: Colors.grey[400], size: 28),
                        Icon(Icons.info_outline, color: Colors.grey[400], size: 28),
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
