import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeoapifyService {
  final String apiKey = "SUA_API_KEY_AQUI";

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final url =
        "https://api.geoapify.com/v1/geocode/autocomplete?text=$query&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      data["features"].map((f) => {
            "name": f["properties"]["formatted"],
            "lat": f["properties"]["lat"],
            "lon": f["properties"]["lon"],
          }),
    );
  }

  LatLng convertToLatLng(double lat, double lon) {
    return LatLng(lat, lon);
  }
}
