class Terminos {
  final int id_termino;
  final int id_subcategoria;
  final String nombre_termino;
  final String descripcion;
  final String? ejemplo;
  final String fecha_creacion;
  final String fecha_actualizacion;

  // Método Constructor
  const Terminos({
    required this.id_termino,
    required this.id_subcategoria,
    required this.nombre_termino,
    required this.descripcion,
    this.ejemplo,
    required this.fecha_creacion,
    required this.fecha_actualizacion,
  });

  factory Terminos.fromJson(Map<String, dynamic> json) {
    return Terminos(
      id_termino: json['id_termino'] as int,
      id_subcategoria: json['id_subcategoria'] as int,
      nombre_termino: json['nombre_termino'] as String,
      descripcion: json['descripcion'] as String,
      ejemplo: json['ejemplo'] as String?,
      fecha_creacion: json['fecha_creacion'] as String,
      fecha_actualizacion: json['fecha_actualizacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_termino': id_termino,
      'id_subcategoria': id_subcategoria,
      'nombre_termino': nombre_termino,
      'descripcion': descripcion,
      'ejemplo': ejemplo,
      'fecha_creacion': fecha_creacion,
      'fecha_actualizacion': fecha_actualizacion,
    };
  }
}
