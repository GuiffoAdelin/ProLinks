import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10, // Nombre de posts fictifs
        itemBuilder: (context, index) {
          return _buildPostCard(context, index);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
      elevation: 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              "Professionnel $index",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Développeur Fullstack • il y a 2h"),
            trailing: const Icon(Icons.more_vert),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              "Salut le réseau ! Je suis ravi de partager mon avancée sur mon projet de plateforme professionnelle. L'architecture NestJS + Flutter avance bien. 🚀 #GénieLogiciel #IUT",
              style: TextStyle(fontSize: 14),
            ),
          ),
          // Placeholder pour une image de post
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.thumb_up_off_alt, "J'aime"),
                _buildActionButton(Icons.comment_outlined, "Commenter"),
                _buildActionButton(Icons.share_outlined, "Partager"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
