import 'package:flutter/material.dart';

class ChangePasswordSheet extends StatelessWidget {
  final TextEditingController contrasenaController;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isLoading;

  const ChangePasswordSheet({
    super.key,
    required this.contrasenaController,
    required this.onCancel,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Cambiar contraseña',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contrasenaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                  ),
                  onPressed: isLoading ? null : onSave,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
