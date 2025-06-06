import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

class PlantService {
  static const String _baseUrl =
      'https://6842b65de1347494c31dadea.mockapi.io/api/Plant';
  static final _logger = Logger();

  static Future<List<Map<String, dynamic>>> getAllPlant(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    _logger.i("GET $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      _logger.i("Status : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        _logger.e("Server error: ${response.statusCode}");
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e("Error fetching data: $e");
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<Map<String, dynamic>> getPlantsDetail(String id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    _logger.i("GET $uri");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      _logger.i("Status : ${response.statusCode}");
      _logger.t("Body : ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        return jsonMap;
      } else {
        _logger.e("Server error: ${response.statusCode}");
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _logger.e("Error fetching data: $e");
      throw Exception("Error fetching data: $e");
    }
  }
}