/*
* Helper para validación general de formularios
* 
* Funcionalidades:
* - Validar que todos los campos requeridos estén completos
* - Verificar que no haya errores de validación en ningún campo
* - Métodos utilitarios para manejo de estado de formularios
* 
* @author Eliab
*/

class FormHelper {
  
  /*
   * Verifica si todos los campos de un formulario están válidos
   * 
   * @param hasErrors Map con flags de error para cada campo
   * @param controllers Map con los controladores de texto de cada campo
   * @return true si todos los campos son válidos, false en caso contrario
   */
  static bool areAllFieldsValid({
    required Map<String, bool> hasErrors,
    required Map<String, String> fieldValues,
  }) {
    // Verificar que no hay errores
    bool hasAnyError = hasErrors.values.any((hasError) => hasError);
    if (hasAnyError) return false;
    
    // Verificar que todos los campos tienen contenido
    bool hasEmptyFields = fieldValues.values.any((value) => value.isEmpty);
    if (hasEmptyFields) return false;
    
    return true;
  }
  
  /*
   * Valida todos los campos de un formulario ejecutando sus funciones de validación
   * 
   * @param validators Map con las funciones de validación para cada campo
   * @param fieldValues Map con los valores actuales de cada campo
   */
  static void validateAllFields({
    required Map<String, Function(String)> validators,
    required Map<String, String> fieldValues,
  }) {
    validators.forEach((fieldName, validator) {
      final value = fieldValues[fieldName] ?? '';
      validator(value);
    });
  }
  
  /*
   * Limpia todos los campos de un formulario
   * 
   * @param controllers Lista de controladores de texto a limpiar
   */
  static void clearAllFields(List<dynamic> controllers) {
    for (var controller in controllers) {
      if (controller.text != null) {
        controller.clear();
      }
    }
  }
}
