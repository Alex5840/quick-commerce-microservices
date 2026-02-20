import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String baseUrl = 'http://localhost:8003';

  static Future<List<dynamic>> fetchCart(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/cart?user_id=$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<int> fetchCartCount(String userId) async {
    try {
      final items = await fetchCart(userId);
      return items.length;
    } catch (_) {
      return 0;
    }
  }
}
