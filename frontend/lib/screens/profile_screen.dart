import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData; // On récupère les données réelles
    final theme = Theme.of(context);

    // Extraction des données avec valeurs de secours (fallback)
    final String nomComplet =
        "${user?['prenom'] ?? ''} ${user?['nom'] ?? 'Utilisateur'}";
    final String headline = user?['headline'] ?? "Nouveau membre ProLinks";
    // final String photoUrl = user?['photoUrl'] ?? "";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER : Photo de couverture + Avatar
            Stack(
              alignment: Alignment.bottomLeft,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 120,
                  color: theme.primaryColor.withOpacity(0.3),
                ),
                Positioned(
                  bottom: -50,
                  left: 20,

                  child: _buildAvatar(user, theme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // INFOS PERSONNELLES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomComplet,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    headline,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(
                        " ${user?['location'] ?? 'Cameroun'}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // BOUTON MODIFIER
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Bientôt : Navigator.push vers EditProfileScreen
                        print("Ouverture de l'édition...");
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Modifier le profil",
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              height: 40,
              thickness: 8,
              color: Color(0xFFF3F2EF),
            ), // Style LinkedIn
            // SECTION COMPÉTENCES (SKILLS)
            _buildSectionTitle("Compétences"),
            _buildSkillsList(user?['skills']),

            const Divider(height: 40, thickness: 8, color: Color(0xFFF3F2EF)),

            // SECTION EXPÉRIENCE
            _buildSectionTitle("Expérience"),
            _buildExperienceList(user?['experience']),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSkillsList(List? skills) {
    if (skills == null || skills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text("Aucune compétence ajoutée."),
      );
    }
    return Wrap(
      spacing: 8,
      children: skills.map((s) => Chip(label: Text(s.toString()))).toList(),
    );
  }

  Widget _buildExperienceList(List? experience) {
    return const ListTile(
      leading: Icon(Icons.business, size: 40),
      title: Text("Poste par défaut"),
      subtitle: Text("Entreprise • Date"),
    );
  }

  Widget _buildAvatar(Map<String, dynamic>? user, Color primaryColor) {
    final photoUrl = user?['photoUrl'];

    return CircleAvatar(
      radius: 54,
      backgroundColor: Colors.white, // Bordure blanche
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
            ? NetworkImage(photoUrl)
            : null,
        child: (photoUrl == null || photoUrl.isEmpty)
            ? Icon(
                Icons.account_circle,
                size: 100,
                color: primaryColor.withOpacity(0.5),
              )
            : null,
      ),
    );
  }
}
