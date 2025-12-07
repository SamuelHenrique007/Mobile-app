import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final server = await HttpServer.bind(
    InternetAddress.anyIPv4, // aceita de qualquer IP
    8000,                     // porta 8000 -> http://127.0.0.1:8000
  );

  print('Servidor Dart rodando em http://localhost:8000');

  await for (HttpRequest request in server) {
    // rota base
    final path = request.uri.path;
    final method = request.method;

    // CORS simples (útil se você rodar Flutter Web)
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');

    if (method == 'OPTIONS') {
      // resposta para preflight
      request.response
        ..statusCode = HttpStatus.noContent
        ..close();
      continue;
    }

    if (path == '/api/veiculos/' && method == 'GET') {
      await _handleGetVehicles(request);
    } else if (path == '/api/summary/' && method == 'GET') {
      await _handleGetSummary(request);
    } else {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('{"detail": "Not found"}')
        ..close();
    }
  }
}

Future<void> _handleGetVehicles(HttpRequest request) async {
  // aqui você poderia ler do banco, por enquanto é mock
  final vehicles = [
    {
      "id": 1,
      "type": "car",
      "name": "Jetta - Branco",
      "brand": "Volkswagen",
      "model": "Jetta",
      "year": "2018",
      "color": "Branco",
      "plate": "ABC-1234",
      "fuel": "Gasolina",
      "tankVolume": "55",
    },
    {
      "id": 2,
      "type": "bike",
      "name": "Titan 160 - Vermelho",
      "brand": "Honda",
      "model": "Titan 160",
      "year": "2022",
      "color": "Vermelho",
      "plate": "DEF-5678",
      "fuel": "Gasolina",
      "tankVolume": "16",
    },
  ];

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(vehicles))
    ..close();
}

Future<void> _handleGetSummary(HttpRequest request) async {
  final month = request.uri.queryParameters['month'];
  final year = request.uri.queryParameters['year'];

  // por enquanto ignora month/year e manda valores fixos
  final summary = {
    "month": month ?? "6",
    "year": year ?? "2025",
    "total": 350.00,
    "perDay": 45.00,
    "perKm": 12.09,
    "kmTotal": 150,
    "kmMedia": 23,
  };

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(summary))
    ..close();
}