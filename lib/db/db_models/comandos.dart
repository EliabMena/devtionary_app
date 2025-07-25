class Comandos {
  final int id_comando;
  final int id_subcategoria;
  final String nombre_comando;
  final String descripcion;
  final String ejemplo;
  final String? ejemplo_2;
  final String? ejemplo_3;
  final String fecha_creacion;
  final String fecha_actualizacion;

  // Método Constructor
  const Comandos({
    required this.id_comando,
    required this.id_subcategoria,
    required this.nombre_comando,
    required this.descripcion,
    required this.ejemplo,
    this.ejemplo_2,
    this.ejemplo_3,
    required this.fecha_creacion,
    required this.fecha_actualizacion,
  });
  factory Comandos.fromJson(Map<String, dynamic> json) {
    return Comandos(
      id_comando: json['id_comando'] as int,
      id_subcategoria: json['id_subcategoria'] as int,
      nombre_comando: json['nombre_comando'] as String,
      descripcion: json['descripcion'] as String,
      ejemplo: json['ejemplo'] as String,
      ejemplo_2: json['ejemplo_2'] as String?,
      ejemplo_3: json['ejemplo_3'] as String?,
      fecha_creacion: json['fecha_creacion'] as String,
      fecha_actualizacion: json['fecha_actualizacion'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id_comando': id_comando,
      'id_subcategoria': id_subcategoria,
      'nombre_comando': nombre_comando,
      'descripcion': descripcion,
      'ejemplo': ejemplo,
      'ejemplo_2': ejemplo_2,
      'ejemplo_3': ejemplo_3,
      'fecha_creacion': fecha_creacion,
      'fecha_actualizacion': fecha_actualizacion,
    };
  }
}
