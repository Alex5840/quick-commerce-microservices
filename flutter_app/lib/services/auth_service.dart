import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static String? currentUser;

  static const String baseUrl = "http://localhost:8001";

  static Future<bool> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      currentUser = data['access_token'];
      print("token stored: ${currentUser}");
      return true;
    }

    return false;
  }

  static Future<bool> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    return response.statusCode == 200;
  }
}
