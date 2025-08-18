import 'package:devtionary_app/db/database_helper.dart';
import 'package:devtionary_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:devtionary_app/widgets/nav_button.dart';
import 'package:devtionary_app/Utility/thems/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:devtionary_app/widgets/edit_profile_sheet.dart';
import 'package:devtionary_app/widgets/change_password_sheet.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);
  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Future<void> eliminarCuenta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay sesión activa.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final url = Uri.parse(
        'https://devtionary-api-production.up.railway.app/api/user',
      );
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        await prefs.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta eliminada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar cuenta: ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de red: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sincronizarDatos() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronizando datos...'),
          backgroundColor: Colors.blueAccent,
        ),
      );
      await DatabaseHelper.sincronizarDatos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Datos sincronizados!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> cambiarContrasenaDialog() async {
    final TextEditingController contrasenaController = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    bool isLoading = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ChangePasswordSheet(
              contrasenaController: contrasenaController,
              isLoading: isLoading,
              onCancel: () => Navigator.pop(context),
              onSave: () async {
                if (token == null) return;
                setSheetState(() => isLoading = true);
                final url = Uri.parse(
                  'https://devtionary-api-production.up.railway.app/api/user/password',
                );
                final body = {'password': contrasenaController.text};
                try {
                  final response = await http.patch(
                    url,
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(body),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contraseña actualizada correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    setSheetState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al actualizar contraseña: ${response.body}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  setSheetState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error de red: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> editarPerfilDialog() async {
    final TextEditingController nombreController = TextEditingController(
      text: username,
    );
    final TextEditingController correoController = TextEditingController(
      text: email,
    );
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    bool isLoading = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return EditProfileSheet(
              nombreController: nombreController,
              correoController: correoController,
              isLoading: isLoading,
              onCancel: () => Navigator.pop(context),
              onSave: () async {
                if (token == null) return;
                setSheetState(() => isLoading = true);
                final url = Uri.parse(
                  'https://devtionary-api-production.up.railway.app/api/user/update',
                );
                final body = {
                  'username': nombreController.text,
                  'email': correoController.text,
                };
                try {
                  final response = await http.patch(
                    url,
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(body),
                  );
                  if (response.statusCode == 200) {
                    await prefs.setString('username', nombreController.text);
                    await prefs.setString('email', correoController.text);
                    setState(() {
                      username = nombreController.text;
                      email = correoController.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado correctamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    setSheetState(() => isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al actualizar perfil: ${response.body}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  setSheetState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error de red: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  int _currentIndex = 4;

  String username = '';
  String email = '';
  String fechaRegistro = '';

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
  }

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Usuario';
      email = prefs.getString('email') ?? 'Sin correo';
      fechaRegistro = prefs.getString('fechaRegistro') ?? 'Sin fecha';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              primaryGradientColor,
              secondaryGradientColor,
              Colors.black,
            ],
            stops: [0.2, 0.4, 0.7],
            center: Alignment.bottomRight,
            radius: 1.7,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                // Nombre de usuario
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Correo electrónico
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Fecha de registro
                Text(
                  'Registrado: $fechaRegistro',
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
                const SizedBox(height: 24),
                // Opciones principales
                Card(
                  color: Colors.white10,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.sync,
                          color: Colors.blueAccent,
                        ),
                        title: const Text(
                          'Sincronizar datos',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: sincronizarDatos,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.edit,
                          color: Colors.tealAccent,
                        ),
                        title: const Text(
                          'Editar perfil',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: editarPerfilDialog,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.purpleAccent,
                        ),
                        title: const Text(
                          'Cambiar contraseña',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: cambiarContrasenaDialog,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Cerrar sesión',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('token');
                          await prefs.remove('username');
                          await prefs.remove('email');
                          await prefs.remove('fechaRegistro');
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Eliminar cuenta',
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: eliminarCuenta,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Extras
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navegación automática
        },
      ),
    );
  }
}
