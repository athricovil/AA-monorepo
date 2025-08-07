import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://ayurayush.com/wp-json/wc/v3";
  final String consumerKey = "ck_c4c7b2972d01af62de8f88274bd194f0880498ac"; // Replace this
  final String consumerSecret = "cs_e1aa9a6bf9166785b52fdd0d42906084c24737af"; // Replace this


  Future<List<dynamic>> fetchProducts() async {
    try {
      final String credentials = "$consumerKey:$consumerSecret";
      final String encodedCredentials = base64Encode(utf8.encode(credentials));

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Basic $encodedCredentials',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }
}
