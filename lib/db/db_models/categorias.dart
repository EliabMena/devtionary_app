class Categorias{
  final int idCategoria;
  final String nombre;
  final String fechaCreacion;
  final String fechaActualizacion;

  // Método Constructor
  const Categorias({
    required this.idCategoria,
    required this.nombre,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Categorias.fromMap(Map<String, dynamic> map) {
    return Categorias(
      idCategoria: map['id_categoria'] as int,
      nombre: map['nombre'] as String,
      fechaCreacion: map['fecha_creacion'] as String,
      fechaActualizacion: map['fecha_actualizacion'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'fecha_creacion': fechaCreacion,
      'fecha_actualizacion': fechaActualizacion,
    };
  }
}