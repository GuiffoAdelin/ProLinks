import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();

  // ====================== UNE SEULE URL DE BASE ======================
  static const String baseUrl = "https://prolinks-uqml.onrender.com";
  //static const String ngrokUrl = "https://b881-154-72-153-37.ngrok-free.app";

  String? _token;
  String? _userId;
  String? _role;
  Map<String, dynamic>? _userData;

  String? get token => _token;
  String? get userId => _userId;
  String? get role => _role;
  Map<String, dynamic>? get userData => _userData;
  bool get isAuth => _token != null;

  // ====================== REGISTER ======================
  Future<void> register(String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      _userData = data['user'];
      _userId = data['user']['id'];
      _role = data['user']['role'];
      await storage.write(key: 'token', value: _token);
      notifyListeners();
    } else {
      throw Exception('Erreur inscription : ${response.body}');
    }
  }

  // ====================== LOGIN ======================
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _token = data['access_token'];

      // IMPORTANT : on récupère l'utilisateur COMPLET via une requête séparée
      final userResponse = await http.get(
        Uri.parse(
          '$baseUrl/users/me',
        ), // ← nouvelle route à créer si elle n'existe pas
        headers: {
          'Authorization': 'Bearer $_token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (userResponse.statusCode == 200) {
        _userData = json.decode(userResponse.body);
        _userId = _userData!['_id'];
        _role = _userData!['role'];
        await storage.write(key: 'token', value: _token);
        notifyListeners();
      } else {
        throw Exception('Impossible de récupérer le profil complet');
      }
    } else {
      throw Exception('Erreur connexion : ${response.body}');
    }
  }

  // ====================== JOBS ======================
  Future<void> createJob(Map<String, dynamic> jobData) async {
    if (_role != 'recruteur') {
      throw Exception("Seuls les recruteurs peuvent publier.");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/jobs/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({...jobData, "poster": _userId}),
    );

    if (response.statusCode != 201) {
      throw Exception("Erreur création job : ${response.body}");
    }
    notifyListeners();
  }

  Future<List<dynamic>> fetchJobs({String query = ""}) async {
    final url = query.trim().isEmpty
        ? '$baseUrl/jobs'
        : '$baseUrl/jobs?search=${Uri.encodeComponent(query.trim())}';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  // ====================== MÉTHODES QUE TU AVAIS DÉJÀ ======================
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
      final savedToken = await storage.read(key: 'token');
      if (savedToken != null) {
        _token = savedToken;
        notifyListeners();
      }
    } catch (e) {
      print("Erreur auto-login: $e");
      _token = null;
    }
  }

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }

  void updateUserLocal(Map<String, dynamic> newData) {
    _userData = newData;
    notifyListeners();
  }

  // ====================== MÉTHODES AJOUTÉES POUR LE RÉSEAU ======================
  Future<List<dynamic>> getDiscovery() async {
    final url = "$baseUrl/connections/discovery";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) return json.decode(response.body);
    return [];
  }

  Future<bool> sendInvite(String receiverId) async {
    final url = "$baseUrl/connections/invite/$receiverId";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // === NOUVELLES MÉTHODES POUR LES INVITATIONS ===
  Future<List<dynamic>> getPendingRequests() async {
    final url = "$baseUrl/connections/pending";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    return response.statusCode == 200 ? json.decode(response.body) : [];
  }

  Future<bool> acceptInvite(String inviteId) async {
    final url = "$baseUrl/connections/respond/$inviteId";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json', // AJOUT INDISPENSABLE
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({'status': 'ACCEPTED'}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> rejectInvite(String inviteId) async {
    final url = "$baseUrl/connections/respond/$inviteId";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json', // AJOUT INDISPENSABLE
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({'status': 'REJECTED'}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<int> getConnectionCount() async {
    final url = "$baseUrl/connections/count";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return 0;
  }

  // ====================== POSTULER À UNE OFFRE ======================
  Future<bool> applyToJob(String jobId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs/$jobId/apply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Erreur postuler : $e");
      return false;
    }
  }

  // ====================== NOTIFICATIONS RÉELLES ======================
  Future<List<dynamic>> getNotifications() async {
    final url = "$baseUrl/notifications";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://www.w3schools.com/howto/img_avatar.png";
    }
    if (path.startsWith("http")) return path; // déjà complète
    return "$baseUrl$path"; // ajoute ngrok + chemin relatif
  }

  static Map<String, String> getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    // Tu pourras supprimer cette ligne une fois sur Render :
    headers['ngrok-skip-browser-warning'] = 'true';
    return headers;
  }
}
