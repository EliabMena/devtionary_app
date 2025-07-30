// lib/widgets/categoria_card.dart
import 'package:flutter/material.dart';

class TarjetaCategoria extends StatelessWidget {
  final String nombre;
  final List<Color> gradient;
  final Widget icono;

  const TarjetaCategoria({
    required this.nombre,
    required this.gradient,
    required this.icono,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Center(child: icono),
          ),
          SizedBox(height: 8),
          Text(
            nombre,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}