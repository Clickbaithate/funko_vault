import 'dart:convert';
import 'package:funko_vault/models/funko.dart';
import 'package:http/http.dart' as http;

class FunkoService {
  // HTTP client to make requests
  final http.Client client;
  FunkoService(this.client);

  // Method to fetch Funko objects from the API with pagination
  Future<List<Funko>> fetchFunkos(int offset) async {
    try {
      // Preparing fetch
      final url = "http://funkopop-api.onrender.com/funko?limit=10&offset=$offset";
      final uri = Uri.parse(url);
      final response = await client.get(uri).timeout(const Duration(seconds: 10));

      // Maps JSON objects to Funko Objects and returns the list
      // Otherwise throws an exception
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
        throw Exception('Failed to load funkos!');
      }
    } catch (e) {
      // Return an empty list if an error occurs
      return [];
    }
  }

  // Method to search Funko objects by name
  Future<List<Funko>> searchFunkos(String name) async {
  try {
    final url = "http://funkopop-api.onrender.com/search?name=$name";
    final uri = Uri.parse(url);
    final response = await client.get(uri).timeout(const Duration(seconds: 10));
    
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
      throw Exception('Failed to load funkos!');
    }
  } catch (e) {
    return [];
  }
}



}
