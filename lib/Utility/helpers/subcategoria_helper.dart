class SubcategoriaHelper {
  static const Map<int, String> _subcategoriaNombres = {
    1: 'Docker',
    2: 'Git Bash',
    3: 'Linux',
    4: 'MacOS',
    5: 'Windows',
    6: 'C++',
    7: 'C#',
    8: 'Java',
    9: 'Javascript',
    10: 'Python',
    11: 'Desarrollo Web',
    12: 'Herramientas y Desarrollo',
    13: 'Paradigmas de Programación',
    14: 'Programacion de Sistemas',
    15: 'Sistema y Arquitectura',
  };

  static String nombrePorId(int? id) {
    if (id == null) return '';
    return _subcategoriaNombres[id] ?? 'Subcategoría $id';
  }
}
