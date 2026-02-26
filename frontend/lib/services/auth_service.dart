// frontend/lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // C'EST ICI ! Remplace localhost par ton IP
  final String baseUrl = "http://10.43.199.128:3000/users";

  Future<bool> registerUser(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
      );

      if (response.statusCode == 201) {
        print("Utilisateur créé dans MongoDB !");
        return true;
      } else {
        print("Erreur : ${response.body}");
        return false;
      }
    } catch (e) {
      print("Impossible de joindre le serveur : $e");
      return false;
    }
  }
}
