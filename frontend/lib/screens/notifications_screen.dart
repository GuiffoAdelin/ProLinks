import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Petite astuce : on peut forcer le refresh du FutureBuilder en changeant l'état
  Future<void> _refresh() async => setState(() {});

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
          "Notifications",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: auth.getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifs = snapshot.data ?? [];
            if (notifs.isEmpty) {
              return const Center(
                child: Text("Aucune notification pour le moment"),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifs.length,
              itemBuilder: (context, index) {
                final notif = notifs[index];
                final applicant = notif['applicant'] ?? {};
                final jobTitle = notif['job']?['title'] ?? "Offre";

                return Card(
                  elevation: 0.5,
                  color: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundImage: applicant['photoUrl'] != null
                          ? NetworkImage(applicant['photoUrl'])
                          : null,
                      child: applicant['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(
                      "${applicant['prenom'] ?? ''} ${applicant['nom'] ?? 'Inconnu'} a postulé",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("à votre offre : $jobTitle"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // FIX: On passe l'objet 'applicant' au paramètre 'user'
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfileDetailScreen(user: applicant),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                      ),
                      child: const Text("Voir"),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
