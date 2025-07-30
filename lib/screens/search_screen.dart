import 'package:flutter/material.dart';
import 'package:devtionary_app/db/repositorios/terminos_repository.dart';
import 'package:devtionary_app/db/repositorios/comandos_repository.dart';
import 'package:devtionary_app/db/repositorios/instrucciones_repository.dart';
import 'package:devtionary_app/db/db_models/terminos.dart';
import 'package:devtionary_app/db/db_models/comandos.dart';
import 'package:devtionary_app/db/db_models/instrucciones.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    setState(() { _loading = true; });
    final terminos = await TerminosRepository().getTerminosLocales();
    final comandos = await ComandosRepository().getComandosLocales();
    final instrucciones = await InstruccionesRepository().getInstruccionesLocales();

    final lowerQuery = query.toLowerCase();
    final filtered = [
      ...terminos.where((t) => t.nombre_termino.toLowerCase().contains(lowerQuery)),
      ...comandos.where((c) => c.nombre_comando.toLowerCase().contains(lowerQuery)),
      ...instrucciones.where((i) => i.nombre_instruccion.toLowerCase().contains(lowerQuery)),
    ];
    setState(() {
      _results = filtered;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar término, comando o instrucción'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
              onSubmitted: _search,
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
                    return ListTile(
                      title: Text(item.nombre),
                      subtitle: Text(tipo),
                      onTap: () {
                        //navegación a la pantalla de detalle
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
