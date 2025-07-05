/*
* Esta clase se encarga de realizar las validaciones para el EMAIL
* isValidEmail: Verifica si el email es válido ccon una expresión regular
* validateEmail: Valida el email y retorna un mensaje de error si no es válido
* @author Eliab
*/

class EmailValidation {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    return emailRegex.hasMatch(email);
  }
  
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'El email es requerido';
    }
    
    if (!isValidEmail(email)) {
      return 'Ingresa un email válido';
    }
    
    return null;
  }
}