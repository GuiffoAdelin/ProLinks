import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _searchQuery = "";

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
          "Offres d'emploi",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: "Rechercher (titre, entreprise, ville...)",
                prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: auth.role == 'recruteur'
          ? FloatingActionButton(
              backgroundColor: theme.primaryColor,
              onPressed: () => _showCreateJobModal(context, auth),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: FutureBuilder<List<dynamic>>(
        future: auth.fetchJobs(query: _searchQuery),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    _searchQuery.isEmpty
                        ? "Aucune offre disponible"
                        : "Aucun résultat pour « $_searchQuery »",
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: theme.cardColor,
                child: ListTile(
                  title: Text(
                    job['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  subtitle: Text(
                    "${job['company']} • ${job['location']}",
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final success = await auth.applyToJob(job['_id']);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? "Candidature envoyée avec succès !"
                                  : "Erreur lors de la candidature",
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme
                          .primaryColor, // Couleur de fond (ex: Violet/Bleu)
                      foregroundColor:
                          Colors.white, // ← FORCE LE TEXTE EN BLANC
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Un bouton un peu plus arrondi
                      ),
                    ),
                    child: const Text("Postuler"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateJobModal(BuildContext context, AuthProvider auth) {
    // Modal inchangé (tu peux le garder tel quel)
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final locationController = TextEditingController();
    final domainController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Publier une offre",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titre du poste"),
            ),
            TextField(
              controller: companyController,
              decoration: const InputDecoration(labelText: "Entreprise"),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Localisation"),
            ),
            TextField(
              controller: domainController,
              decoration: const InputDecoration(labelText: "Domaine"),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  await auth.createJob({
                    "title": titleController.text,
                    "company": companyController.text,
                    "location": locationController.text,
                    "domain": domainController.text,
                    "description": descriptionController.text,
                    "type": "Temps plein",
                  });
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text(
                  "Publier l'offre",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
