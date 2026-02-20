import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String baseUrl = "http://localhost:8002";

  /// 🔥 Fetch all products from backend
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/products"),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch products");
        return [];
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  /// 🔥 Add product to cart
   static Future<void> addToCart({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost:8003/cart/add?user_id=$userId&product_id=$productId&quantity=$quantity"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RAW BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("Failed to add to cart: ${response.statusCode}");
      }
    } catch (e) {
      print('addToCart exception: $e');
      rethrow;
    }
  }

  /// 🔥 Remove product from cart
  static Future<void> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    final response = await http.post(
      Uri.parse(
          "http://localhost:8003/cart/remove?user_id=$userId&product_id=$productId"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove from cart");
    }
  }
}
