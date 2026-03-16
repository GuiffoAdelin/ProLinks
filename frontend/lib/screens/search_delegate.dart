import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomSearchDelegate extends SearchDelegate {
  final String token;
  final String baseUrl =
      "https://3c62-154-72-153-44.ngrok-free.app"; // ← mets ton ngrok actuel ici

  CustomSearchDelegate(this.token);

  // FONCTION POUR ENVOYER L'INVITATION
  Future<void> _sendInvitation(
    BuildContext context,
    String targetUserId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/invite/$targetUserId"),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (context.mounted) {
      final msg = response.statusCode == 201
          ? "Invitation envoyée !"
          : "Erreur envoi invitation (${response.statusCode})";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Tapez un nom pour chercher"));
    }

    return FutureBuilder<http.Response>(
      future: http.get(
        Uri.parse(
          "$baseUrl/users/search?q=${Uri.encodeComponent(query.trim())}",
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      ),
      builder: (context, snapshot) {
        // DEBUG : on affiche TOUT dans la console
        if (snapshot.hasData) {
          print("=== RECHERCHE DEBUG ===");
          print("URL appelée : ${snapshot.data!.request?.url}");
          print("Status : ${snapshot.data!.statusCode}");
          print("Body : ${snapshot.data!.body}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Erreur réseau : ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.statusCode != 200) {
          final errorMsg = snapshot.data != null
              ? "Erreur serveur (${snapshot.data!.statusCode}) : ${snapshot.data!.body}"
              : "Aucune réponse du serveur";
          return Center(child: Text(errorMsg, textAlign: TextAlign.center));
        }

        final List users = json.decode(snapshot.data!.body) ?? [];

        if (users.isEmpty) {
          return const Center(child: Text("Aucun résultat trouvé"));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  user['photoUrl'] ?? 'https://via.placeholder.com/150',
                ),
              ),
              title: Text(
                "${user['prenom'] ?? ''} ${user['nom'] ?? 'Utilisateur'}",
              ),
              subtitle: Text(user['headline'] ?? "Membre ProLinks"),
              trailing: IconButton(
                icon: const Icon(Icons.person_add, color: Colors.blue),
                onPressed: () => _sendInvitation(context, user['_id']),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Tapez pour chercher des utilisateurs"));
  }
}
