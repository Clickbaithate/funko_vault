import 'dart:convert';
import 'package:funko_vault/models/funko.dart';
import 'package:http/http.dart' as http;

class FunkoService {
  final http.Client client;

  FunkoService(this.client);

  Future<List<Funko>> fetchFunkos(int offset) async {
  try {
    final url = "http://funkopop-api.onrender.com/funko?limit=100&offset=$offset";
    final uri = Uri.parse(url);
    final response = await client.get(uri).timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((funko) => Funko(
        id: funko["Id"],
        name: funko["Name"],
        series: funko["Series"],
        rating: funko["Rating"],
        scale: funko["Scale"],
        brand: funko["Brand"],
        type: funko["Type"],
        image: funko["Image"],
      )).toList();
    } else {
      throw Exception('Failed to load funkos');
    }
  } catch (e) {
    print("API Error: $e");
    return [];
  }
}

}
