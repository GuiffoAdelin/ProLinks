import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_detail_screen.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final Set<String> _sentInvites = {};

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Réseau Professionnel",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // === COMPTEUR DE CONNEXIONS ===
          FutureBuilder<int>(
            future: auth.getConnectionCount(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: theme.primaryColor.withOpacity(0.08),
                child: Center(
                  child: Text(
                    "$count connexion${count > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),

          // === LISTE DES UTILISATEURS ===
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: auth.getDiscovery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];
                final filteredUsers = users
                    .where((u) => u['_id'] != auth.userId)
                    .toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text("Aucun professionnel disponible"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final String targetId = user['_id']?.toString() ?? '';
                    final bool alreadySent = _sentInvites.contains(targetId);

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(
                            auth.getFullImageUrl(
                              user['photoUrl'],
                            ), // ← Correction photo
                          ),
                          child: user['photoUrl'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          "${user['prenom'] ?? ''} ${user['nom'] ?? 'Utilisateur'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(user['headline'] ?? "Membre ProLinks"),
                        trailing: ElevatedButton(
                          onPressed: alreadySent || targetId.isEmpty
                              ? null
                              : () async {
                                  bool success = await auth.sendInvite(
                                    targetId,
                                  );
                                  if (success) {
                                    setState(() => _sentInvites.add(targetId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Invitation envoyée ✅"),
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: alreadySent
                                ? Colors.grey
                                : theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            alreadySent ? "En attente" : "Se connecter",
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileDetailScreen(user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
