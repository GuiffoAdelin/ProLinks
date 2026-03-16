import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PostProvider with ChangeNotifier {
  List<dynamic> _posts = [];
  bool _isLoading = false;
  List<dynamic> get posts => _posts;
  bool get isLoading => _isLoading;
  final String baseUrl = "https://3c62-154-72-153-44.ngrok-free.app";

  String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return "$baseUrl$path";
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/posts"),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        _posts = json.decode(response.body);
      }
    } catch (e) {
      debugPrint("Erreur fetchPosts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPost(String content, String token, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/posts"));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });
      request.fields['content'] = content;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // On rafraîchit la liste sans bloquer le retour de la fonction
        fetchPosts();
        return true;
      } else {
        debugPrint("ERREUR SERVEUR: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("CATASTROPHE CLIENT: $e");
      return false;
    }
  }

  Future<void> toggleLike(String postId, String token) async {
    final index = _posts.indexWhere((p) => p['_id'] == postId);
    if (index == -1) return;

    // Optionnel : On pourrait changer la couleur du coeur ici pour l'instantanéité

    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/posts/$postId/like"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedPost = json.decode(response.body);
        _posts[index] =
            updatedPost; // Le serveur renvoie le post avec le tableau 'likes' à jour
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Erreur Like: $e");
    }
  }

  // ====================== AJOUTE CETTE MÉTHODE ======================
  Future<bool> addComment(String postId, String content, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comment'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: json.encode({'content': content}),
      );

      print("📨 Réponse addComment : ${response.statusCode}"); // pour debug

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPosts(); // Rafraîchit le feed automatiquement
        return true;
      } else {
        print("Erreur serveur : ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur addComment : $e");
      return false;
    }
  }
}
