class Categorias {
  final int id_categoria;
  final String nombre;
  final String fechaCreacion;
  final String fechaActualizacion;

  // Método Constructor
  const Categorias({
    required this.id_categoria,
    required this.nombre,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Categorias.fromJson(Map<String, dynamic> json) {
    return Categorias(
      id_categoria: json['id_categoria'] as int,
      nombre: json['nombre'] as String,
      fechaCreacion: json['fecha_creacion'] as String,
      fechaActualizacion: json['fecha_actualizacion'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_categoria': id_categoria,
      'nombre': nombre,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }
}
