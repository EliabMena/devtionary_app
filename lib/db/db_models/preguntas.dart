class Preguntas {
  final int? id_pregunta;
  final int? id_categoria;
  final int? id_subcategoria;
  final String pregunta;
  final String respuesta_correcta;
  final String respuesta_incorrecta_1;
  final String respuesta_incorrecta_2;
  final String respuesta_incorrecta_3;
  final String? fecha_creacion;
  final String? fecha_actualizacion;
  final String? nombreCategoria;

  const Preguntas({
    this.id_pregunta,
    this.id_categoria,
    this.id_subcategoria,
    required this.pregunta,
    required this.respuesta_correcta,
    required this.respuesta_incorrecta_1,
    required this.respuesta_incorrecta_2,
    required this.respuesta_incorrecta_3,
    this.fecha_creacion,
    this.fecha_actualizacion,
    this.nombreCategoria,
  });
  factory Preguntas.fromJson(Map<String, dynamic> json) {
    return Preguntas(
      id_pregunta: json['id_pregunta'] as int,
      id_categoria: json['id_categoria'] as int,
      id_subcategoria: json['id_subcategoria'] as int,
      pregunta: json['pregunta'] as String,
      respuesta_correcta: json['respuesta_correcta'] as String,
      respuesta_incorrecta_1: json['respuesta_incorrecta_1'] as String,
      respuesta_incorrecta_2: json['respuesta_incorrecta_2'] as String,
      respuesta_incorrecta_3: json['respuesta_incorrecta_3'] as String,
      fecha_creacion: json['fecha_creacion'] as String,
      fecha_actualizacion: json['fecha_actualizacion'] as String,
    );
  }

  factory Preguntas.fromJsonPreguntas(Map<String, dynamic> json) {
    return Preguntas(
      pregunta: json['pregunta'] as String,
      respuesta_correcta: json['respuesta_correcta'] as String,
      respuesta_incorrecta_1: json['respuesta_incorrecta_1'] as String,
      respuesta_incorrecta_2: json['respuesta_incorrecta_2'] as String,
      respuesta_incorrecta_3: json['respuesta_incorrecta_3'] as String,
      nombreCategoria: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pregunta': id_pregunta,
      'id_categoria': id_categoria,
      'id_subcategoria': id_subcategoria,
      'pregunta': pregunta,
      'respuesta_correcta': respuesta_correcta,
      'respuesta_incorrecta_1': respuesta_incorrecta_1,
      'respuesta_incorrecta_2': respuesta_incorrecta_2,
      'respuesta_incorrecta_3': respuesta_incorrecta_3,
      'fecha_creacion': fecha_creacion,
      'fecha_actualizacion': fecha_actualizacion,
    };
  }
}
