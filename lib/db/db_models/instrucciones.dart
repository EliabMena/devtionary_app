class Instrucciones {
  final int id_instruccion;
  final int id_subcategoria;
  final String nombre_instruccion;
  final String descripcion;
  final String ejemplo;
  final String fecha_creacion;
  final String fecha_actualizacion;

  // Método Constructor
  const Instrucciones({
    required this.id_instruccion,
    required this.id_subcategoria,
    required this.nombre_instruccion,
    required this.descripcion,
    required this.ejemplo,
    required this.fecha_creacion,
    required this.fecha_actualizacion,
  });

  factory Instrucciones.fromJson(Map<String, dynamic> json) {
    return Instrucciones(
      id_instruccion: json['id_instruccion'] as int,
      id_subcategoria: json['id_subcategoria'] as int,
      nombre_instruccion: json['nombre_instruccion'] as String,
      descripcion: json['descripcion'] as String,
      ejemplo: json['ejemplo'] as String,
      fecha_creacion: json['fecha_creacion'] as String,
      fecha_actualizacion: json['fecha_actualizacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_instruccion': id_instruccion,
      'id_subcategoria': id_subcategoria,
      'nombre_instruccion': nombre_instruccion,
      'descripcion': descripcion,
      'ejemplo': ejemplo,
      'fecha_creacion': fecha_creacion,
      'fecha_actualizacion': fecha_actualizacion,
    };
  }
}
