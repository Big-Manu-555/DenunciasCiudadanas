import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/denuncia.dart';

class ApiService {
  // En el emulador Android, 10.0.2.2 apunta al localhost del equipo host.
  // Puerto configurado en backend: 8081.
  static String baseUrl = 'http://10.0.2.2:8081/denuncias';

  static const Duration timeoutDuration = Duration(seconds: 15);

  /// 1. Registrar denuncia (POST /denuncias/)
  static Future<Denuncia> registrarDenuncia(Denuncia denuncia) async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: utf8.encode(jsonEncode(denuncia.toJson())),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Denuncia.fromJson(data);
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = errorData['message'] ?? 'Error al registrar la denuncia';
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception('Error de conexión al registrar: $e');
    }
  }

  /// 2. Obtener denuncias paginadas (GET /denuncias/?offset=0&limit=5)
  static Future<List<Denuncia>> getDenunciasPaginadas({
    int offset = 0,
    int limit = 5,
  }) async {
    final url = Uri.parse('$baseUrl/?offset=$offset&limit=$limit');
    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Denuncia.fromJson(item)).toList();
      } else {
        throw Exception('Error al obtener denuncias: código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al obtener lista: $e');
    }
  }

  /// 3. Obtener denuncia por ID (GET /denuncias/{id})
  static Future<Denuncia> getDenunciaById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Denuncia.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Denuncia con código $id no encontrada');
      } else {
        throw Exception('Error al consultar denuncia: código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  /// 4. Obtener denuncias de un ciudadano por DNI (GET /denuncias/ciudadano/{dni})
  static Future<List<Denuncia>> getDenunciasByDni(String dni) async {
    final url = Uri.parse('$baseUrl/ciudadano/$dni');
    try {
      final response = await http.get(url).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Denuncia.fromJson(item)).toList();
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = errorData['message'] ?? 'Error al buscar por DNI';
        throw Exception(msg);
      }
    } catch (e) {
      throw Exception('Error de conexión al buscar por DNI: $e');
    }
  }

  /// 5. Atender denuncia (PUT /denuncias/{id})
  static Future<Denuncia> atenderDenuncia(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    try {
      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return Denuncia.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Denuncia con código $id no encontrada');
      } else {
        throw Exception('Error al atender la denuncia: código ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión al atender: $e');
    }
  }
}

