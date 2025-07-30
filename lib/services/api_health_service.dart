import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHealthService {
  static const String healthUrl = 'https://devtionary-api-production.up.railway.app/api/user/health';

  Future<String?> fetchApiVersion() async {
    try {
      final response = await http.get(Uri.parse(healthUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['version'] as String?;
      }
    } catch (e) {
      // Puedes manejar el error aquí si lo deseas
      return null;
    }
    return null;
  }
}
