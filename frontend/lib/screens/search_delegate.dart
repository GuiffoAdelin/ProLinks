import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomSearchDelegate extends SearchDelegate {
  final String token;
  // METS TON URL NGROK ICI (Celle qui s'affiche dans ton terminal NestJS)
  final String baseUrl = "https://b919-154-72-153-59.ngrok-free.app";

  CustomSearchDelegate(this.token);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) return const Center(child: Text("Tapez un nom..."));

    return FutureBuilder(
      future: http.get(
        Uri.parse("$baseUrl/users/search?q=$query"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning':
              'true', // CRUCIAL : Saute la page d'alerte Ngrok
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text("Erreur de connexion au serveur"));
        }

        if (snapshot.data!.statusCode != 200) {
          return Center(
            child: Text("Erreur serveur : ${snapshot.data!.statusCode}"),
          );
        }

        final List users = json.decode(snapshot.data!.body);

        if (users.isEmpty) {
          return const Center(child: Text("Aucun utilisateur trouvé"));
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
              title: Text("${user['nom']} ${user['prenom']}"),
              subtitle: Text(user['headline'] ?? "Membre ProLinks"),
              onTap: () {
                // Action quand on clique sur un résultat
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Tu peux laisser vide pour l'instant
  }
}
