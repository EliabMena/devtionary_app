/*
* Esta clase se encarga de realizar las validaciones para el USERNAME
* isValidUsername: Verifica si el username es válido
* validateUsername: Valida el username y retorna un mensaje de error si no es válido
* @author Eliab
*/

class UsernameValidation {
  static bool isValidUsername(String username) {
    if (username.isEmpty) return false;
    
    // El username debe tener al menos 3 caracteres
    if (username.length < 3) return false;
    
    // Opcional: agregar más validaciones como caracteres permitidos
    // final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    // return usernameRegex.hasMatch(username);
    
    return true;
  }
  
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'El nombre de usuario es requerido';
    }
    
    if (username.length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    
    // Opcional: validaciones adicionales
    // if (username.length > 20) {
    //   return 'El nombre debe tener máximo 20 caracteres';
    // }
    
    // if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
    //   return 'El nombre solo puede contener letras, números y guión bajo';
    // }
    
    return null;
  }
}
