class Instrucciones{
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

  factory Instrucciones.fromMap(Map<String, dynamic> map) {
    return Instrucciones(
      id_instruccion: map['id_instruccion'] as int,
      id_subcategoria: map['id_subcategoria'] as int,
      nombre_instruccion: map['nombre_instruccion'] as String,
      descripcion: map['descripcion'] as String,
      ejemplo: map['ejemplo'] as String,
      fecha_creacion: map['fecha_creacion'] as String,
      fecha_actualizacion: map['fecha_actualizacion'] as String,
    );
  }

  Map<String, dynamic> toMap() {
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