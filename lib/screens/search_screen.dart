import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:devtionary_app/widgets/searchbar.dart';
import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/db/repositorios/terminos_repository.dart';
import 'package:devtionary_app/db/repositorios/comandos_repository.dart';
import 'package:devtionary_app/db/repositorios/instrucciones_repository.dart';
import 'package:devtionary_app/db/db_models/terminos.dart';
import 'package:devtionary_app/db/db_models/comandos.dart';
import 'package:devtionary_app/db/db_models/instrucciones.dart';
import 'package:devtionary_app/Utility/helpers/subcategoria_helper.dart';
import 'package:devtionary_app/widgets/resultado_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _currentIndex = 1;
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;

  Future<void> _searchAdvanced(String query, String tipoBusqueda) async {
    setState(() {
      _loading = true;
    });
    final terminosRepo = TerminosRepository();
    final comandosRepo = ComandosRepository();
    final instruccionesRepo = InstruccionesRepository();
    final dynamic results;
    if (tipoBusqueda == 'nombre') {
      results = await Future.wait([
        // Búsqueda en nombres
        terminosRepo.buscarTerminosPorNombre(query),
        comandosRepo.buscarComandosPorNombre(query),
        instruccionesRepo.buscarInstruccionesPorNombre(query),
      ]);
    } else if (tipoBusqueda == 'descripcion') {
      results = await Future.wait([
        terminosRepo.buscarTerminosPorDescripcion(query),
        comandosRepo.buscarComandosPorDescripcion(query),
        instruccionesRepo.buscarInstruccionesPorDescripcion(query),
      ]);
    } else if (tipoBusqueda == 'subcategoria') {
      results = await Future.wait([
        terminosRepo.getTerminosPorSubcategoria(query),
        comandosRepo.getComandosPorSubcategoria(query),
        instruccionesRepo.getInstruccionesPorSubcategoria(query),
      ]);
    } else {
      // Búsquedas paralelas en nombre Y descripción
      results = await Future.wait([
        // Búsqueda en nombres
        terminosRepo.buscarTerminosPorNombre(query),
        comandosRepo.buscarComandosPorNombre(query),
        instruccionesRepo.buscarInstruccionesPorNombre(query),
        // Búsqueda en descripciones
        terminosRepo.buscarTerminosPorDescripcion(query),
        comandosRepo.buscarComandosPorDescripcion(query),
        instruccionesRepo.buscarInstruccionesPorDescripcion(query),
      ]);
    }
    try {
      // Combinar y eliminar duplicados
      final Set<dynamic> uniqueResults = {};
      for (var resultList in results) {
        uniqueResults.addAll(resultList);
      }

      setState(() {
        _results = uniqueResults.toList();
        _loading = false;
      });
    } catch (e) {
      print('Error en búsqueda: $e');
      setState(() {
        _results = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primaryGradientColor,
              secondaryGradientColor,
              Colors.black,
            ],
            stops: [0.2, 0.4, 0.7],
            center: Alignment.bottomLeft,
            radius: MediaQuery.of(context).viewInsets.bottom > 0 ? 1 : 1.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        controller: _controller,
                        hintText: 'Buscar término, comando o instrucción',
                        onChanged: (value) {
                          // Actualiza la búsqueda en tiempo real si lo deseas
                        },
                        onSubmitted: (value) {
                          _searchAdvanced(value, ""); // Aquí we
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_loading) const CircularProgressIndicator(),
              if (!_loading)
                Expanded(
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      String tipo = item is Terminos
                          ? 'Término'
                          : item is Comandos
                          ? 'Comando'
                          : 'Instrucción';
                      String nombre = item is Terminos
                          ? item.nombre_termino
                          : item is Comandos
                          ? item.nombre_comando
                          : item.nombre_instruccion;
                      String? subcategoria =
                          item is Terminos && item.id_subcategoria != null
                          ? SubcategoriaHelper.nombrePorId(item.id_subcategoria)
                          : null;
                      int? idSubcategoria;
                      if (item is Terminos) {
                        idSubcategoria = item.id_subcategoria;
                      } else if (item is Comandos) {
                        idSubcategoria = item.id_subcategoria;
                      } else if (item is Instrucciones) {
                        idSubcategoria = item.id_subcategoria;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        child: ResultadoCard(
                          titulo: nombre,
                          subtitulo:
                              subcategoria != null && subcategoria.isNotEmpty
                              ? tipo + '\n' + subcategoria
                              : tipo,
                          idSubcategoria: idSubcategoria,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/targetas',
                              arguments: {
                                'word': nombre,
                                'subtitle': subcategoria ?? '',
                                'description': item.descripcion ?? '',
                                'isFavorite': false,
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Puedes agregar navegación aquí si lo deseas
        },
      ),
    );
  }
}
