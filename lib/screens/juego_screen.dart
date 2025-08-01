import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:devtionary_app/db/db_models/preguntas.dart';
import 'package:devtionary_app/db/repositorios/preguntas_repository.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JuegoScreen extends StatefulWidget {
  final String categoria;
  const JuegoScreen({Key? key, required this.categoria}) : super(key: key);

  @override
  _JuegoScreenState createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  /// Mapea la categoría local a la categoría esperada por el backend
  String _categoriaApi(String localCategoria) {
    if (localCategoria == 'terminal') return 'comandos';
    if (localCategoria == 'lenguajes_programacion') return 'instrucciones';
    if (localCategoria == 'terminos_programacion') return 'terminos';
    return 'terminos'; // fallback seguro
  }

  Future<void> _actualizarPuntosCategoria() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;
      final url = Uri.parse(
        'https://devtionary-api-production.up.railway.app/api/user/puntos-categoria',
      );
      final categoriaApi = _categoriaApi(widget.categoria);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'categoria': categoriaApi, 'puntos': _puntos}),
      );
      if (response.statusCode == 200) {
        debugPrint('Puntos de categoría actualizados correctamente');
      } else {
        debugPrint(
          'Error al actualizar puntos de categoría: \n${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Excepción al actualizar puntos de categoría: $e');
    }
  }

  // Usar los colores de gradiente definidos en AppColors
  String? _opcionSeleccionada;
  final PreguntasRepository _repo = PreguntasRepository();
  List<Preguntas> _preguntas = [];
  int _preguntaActual = 0;
  int _puntos = 0;
  List<String> _opciones = [];
  String? _respuestaCorrecta;
  bool _respondido = false;
  Timer? _timer;
  int _tiempoRestante = 30;

  @override
  void initState() {
    super.initState();
    _cargarPreguntas();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarPreguntas() async {
    final preguntas = await _repo.getPreguntasAleatoriasPorCategoria(
      widget.categoria,
    );
    setState(() {
      _preguntas = preguntas;
    });
    _iniciarPregunta();
  }

  void _iniciarPregunta() {
    if (_preguntaActual >= _preguntas.length) return;
    final pregunta = _preguntas[_preguntaActual];
    _respuestaCorrecta = pregunta.respuesta_correcta;
    _opciones = [
      pregunta.respuesta_correcta,
      pregunta.respuesta_incorrecta_1,
      pregunta.respuesta_incorrecta_2,
      pregunta.respuesta_incorrecta_3,
    ];
    _opciones.shuffle(Random());
    _respondido = false;
    _opcionSeleccionada = null;
    _tiempoRestante = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tiempoRestante--;
        if (_tiempoRestante <= 0) {
          _timer?.cancel();
          _siguientePregunta();
        }
      });
    });
    setState(() {});
  }

  void _seleccionarOpcion(String opcion) {
    if (_respondido) return;
    _opcionSeleccionada = opcion;
    _respondido = true;
    _timer?.cancel();
    if (opcion == _respuestaCorrecta) {
      _puntos++;
    }
    setState(() {});
    Future.delayed(const Duration(seconds: 1), _siguientePregunta);
  }

  void _siguientePregunta() {
    if (_preguntaActual < _preguntas.length - 1) {
      setState(() {
        _preguntaActual++;
      });
      _iniciarPregunta();
    } else {
      _mostrarResultado();
    }
  }

  void _mostrarResultado() {
    _actualizarPuntosCategoria();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Juego terminado!'),
        content: Text('Puntaje: $_puntos de ${_preguntas.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_preguntas.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final pregunta = _preguntas[_preguntaActual];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.getPrimaryGradientColor(context),
              AppColors.getSecondaryGradientColor(context),
              Colors.black,
            ],
            stops: const [0.2, 0.4, 0.8],
            center: Alignment.bottomCenter,
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mostrar el nombre de la categoría
                Text(
                  widget.categoria,
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (_preguntaActual + 1) / _preguntas.length,
                        backgroundColor: Colors.white24,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_tiempoRestante s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Pregunta ${_preguntaActual + 1} de ${_preguntas.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    pregunta.pregunta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ..._opciones.map((opcion) {
                  Color bgColor = Colors.grey[300]!;
                  Color fgColor = Colors.black;
                  if (_respondido) {
                    if (_opcionSeleccionada == opcion &&
                        opcion == _respuestaCorrecta) {
                      // Seleccionada y es la correcta
                      bgColor = Colors.blue;
                      fgColor = Colors.white;
                    } else if (_opcionSeleccionada == opcion &&
                        opcion != _respuestaCorrecta) {
                      // Seleccionada y es incorrecta
                      bgColor = Colors.red;
                      fgColor = Colors.white;
                    } else {
                      // No seleccionada
                      bgColor = Colors.grey[800]!;
                      fgColor = Colors.white;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bgColor,
                        foregroundColor: fgColor,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _respondido
                          ? null
                          : () => _seleccionarOpcion(opcion),
                      child: Text(
                        opcion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                Text(
                  'Puntaje: $_puntos',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
