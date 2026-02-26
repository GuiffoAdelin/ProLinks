import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();

  // URL NGROK UNIQUE (Vérifie bien que c'est la version actuelle de ton terminal)
  static const String baseUrl =
      "https://d4cf-154-72-153-61.ngrok-free.app/users";

  String? _token;
  String? _userId;
  String? _role;
  Map<String, dynamic>?
  _userData; // Stockage des infos réelles (nom, photo, etc.)

  String? get token => _token;
  String? get userId => _userId;
  String? get role => _role;
  Map<String, dynamic>? get userData =>
      _userData; // Le getter pour ton HomeScreen

  bool get isAuth => _token != null;

  Future<void> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      _userData =
          data['user']; // On récupère les infos par défaut créées par NestJS
      _userId = data['user']['id'];
      _role = data['user']['role'];

      await storage.write(key: 'token', value: _token);
      notifyListeners();
    } else {
      throw Exception('Erreur inscription : ${response.body}');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      _userData = data['user']; // Stockage des infos utilisateur
      _userId = data['user']['id'];
      _role = data['user']['role'];

      await storage.write(key: 'token', value: _token);
      notifyListeners();
    } else {
      throw Exception(
        'Erreur connexion (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _role = null;
    _userData = null;
    await storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    try {
      final savedToken = await storage
          .read(key: 'token')
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (savedToken != null) {
        _token = savedToken;
        // Note: Idéalement, il faudrait ici un appel API "profile" pour recharger _userData
        notifyListeners();
      }
    } catch (e) {
      print("Erreur auto-login: $e");
      _token = null;
    }
  }
}
