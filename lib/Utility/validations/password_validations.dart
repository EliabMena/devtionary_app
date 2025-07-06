/*
* Esta clase se encarga de realizar las validaciones para el PASSWORD
* isValidPassword: Verifica si la contraseña es válida
* validatePassword: Valida la contraseña y retorna un mensaje de error si no es válida
* @author Eliab
*/

class PasswordValidation {
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    
    // La contraseña debe tener al menos 6 caracteres
    if (password.length < 6) return false;
    
    // Opcional: agregar más validaciones como mayúsculas, números, etc.
    // final strongPasswordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]');
    // return strongPasswordRegex.hasMatch(password);
    
    return true;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    // Opcional: validaciones adicionales
    // if (password.length > 50) {
    //   return 'La contraseña debe tener máximo 50 caracteres';
    // }
    
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
    //   return 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
    // }
    
    return null;
  }
}
