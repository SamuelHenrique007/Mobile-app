import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // se for rodar Flutter Web no mesmo PC:
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // TODO: pegar esse token do login / storage
  final String authToken;

  ApiClient({required this.authToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Token $authToken',
      };

  // ====== VEÍCULOS ======
  Future<List<dynamic>> getVehicles() async {
    final url = Uri.parse('$baseUrl/veiculos/');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    } else {
      throw Exception('Erro ao carregar veículos: ${resp.statusCode}');
    }
  }

  // ====== RESUMO ======
  Future<Map<String, dynamic>> getSummary({int? month, int? year}) async {
    final queryParams = <String, String>{};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final uri = Uri.parse('$baseUrl/summary/').replace(queryParameters: queryParams);
    final resp = await http.get(uri, headers: _headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erro ao carregar resumo: ${resp.statusCode}');
    }
  }
}
