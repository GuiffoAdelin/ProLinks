import 'package:flutter/material.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Offres d'emploi"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un poste, une ville...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, color: Colors.blue),
            ),
            title: Text(
              "Ingénieur Logiciel Junior (H/F) $index",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Tech Solutions Inc. • Yaoundé\nTemps plein"),
            isThreeLine: true,
            trailing: const Icon(Icons.bookmark_border),
            onTap: () {
              // Plus tard : navigation vers le détail de l'offre
            },
          );
        },
      ),
    );
  }
}
