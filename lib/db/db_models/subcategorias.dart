class Subcategorias {
  final int id_subcategoria;
  final int id_categoria;
  final String nombre;
  final String fecha_creacion;
  final String fecha_actualizacion;

  // Método Constructor
  const Subcategorias({
    required this.id_subcategoria,
    required this.id_categoria,
    required this.nombre,
    required this.fecha_creacion,
    required this.fecha_actualizacion,

  });

  factory Subcategorias.fromJson(Map<String, dynamic> json) {
    return Subcategorias(
      id_subcategoria: json['id_subcategoria'] as int,
      id_categoria: json['id_categoria'] as int,
      nombre: json['nombre'] as String,
      fecha_creacion: json['fecha_creacion'] as String,
      fecha_actualizacion: json['fecha_actualizacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_subcategoria': id_subcategoria,
      'id_categoria': id_categoria,
      'nombre': nombre,
      'fecha_creacion': fecha_creacion,
      'fecha_actualizacion': fecha_actualizacion,
    };
  }
}