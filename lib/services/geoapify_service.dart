import 'dart:convert';
import 'package:http/http.dart' as http;

class GeoapifyService {
  static const String _apiKey = '619ba71eaac1450e9b434f7720cc4150';

  // Busca locais pelo nome (para criação de rota)
  Future<List<Map<String, dynamic>>> buscarLocaisPorNome(String query) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search'
      '?text=${Uri.encodeComponent(query)}'
      '&filter=countrycode:br'
      '&bias=proximity:-37.5,-8.5'
      '&lang=pt'
      '&limit=5'
      '&apiKey=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final features = data['features'] as List;

    return features.map((f) {
      final props = f['properties'];
      return {
        "name": props['name'] ?? props['formatted'] ?? query,
        "lat": (props['lat'] as num).toDouble(),
        "lon": (props['lon'] as num).toDouble(),
        "endereco": props['formatted'] ?? '',
      };
    }).toList();
  }

  // Geocodifica endereço completo → retorna lat/lon
  Future<Map<String, double>?> geocodificarEndereco(String endereco) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search'
      '?text=${Uri.encodeComponent(endereco)}'
      '&filter=countrycode:br'
      '&lang=pt'
      '&limit=1'
      '&apiKey=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);
    final features = data['features'] as List;
    if (features.isEmpty) return null;

    final props = features[0]['properties'];
    return {
      'lat': (props['lat'] as num).toDouble(),
      'lon': (props['lon'] as num).toDouble(),
    };
  }
}