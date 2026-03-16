import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData ?? {};
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const Color purpleDGN = Color(0xFF6A1B9A);

    final String nomComplet =
        "${user['prenom'] ?? ''} ${user['nom'] ?? 'Utilisateur'}";
    final String headline = user['headline'] ?? "Nouveau membre ProLinks";

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Stack(
              alignment: Alignment.bottomLeft,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [purpleDGN, Color(0xFF4A148C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -45,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(
                        auth.getFullImageUrl(user['photoUrl']),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 55),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomComplet,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              headline,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.edit_note,
                          color: purpleDGN,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      Text(
                        " ${user['location'] ?? 'Cameroun'}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),

            // === COMPÉTENCES ===
            _buildSectionTitle("Compétences", purpleDGN),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSkillsList(user['skills'], purpleDGN, isDark),
            ),

            const SizedBox(height: 25),

            // === EXPÉRIENCE ===
            _buildSectionTitle("Expérience", purpleDGN),
            _buildExperienceList(user['experience'], purpleDGN),

            const SizedBox(height: 25),

            // === FORMATION ===
            _buildSectionTitle("Formation", purpleDGN),
            _buildEducationList(user['education'], purpleDGN),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Compétences (simple et robuste)
  Widget _buildSkillsList(List? skills, Color primary, bool isDark) {
    if (skills == null || skills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Aucune compétence ajoutée.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills
            .map(
              (skill) => Chip(
                label: Text(skill.toString()),
                backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                labelStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // Expérience (affiche position + company)
  Widget _buildExperienceList(List? experience, Color primary) {
    if (experience == null || experience.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Aucune expérience ajoutée",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: experience.map((exp) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.work_outline, color: primary, size: 32),
            title: Text(
              exp['position'] ?? 'Poste inconnu',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              exp['company'] ?? 'Entreprise inconnue',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Text(
              "${exp['startDate'] ?? ''} – ${exp['endDate'] ?? 'Présent'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEducationList(List? education, Color primary) {
    if (education == null || education.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Aucune formation ajoutée",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: education.map((edu) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.school_outlined, color: primary, size: 32),
            title: Text(
              edu['degree'] ?? 'Diplôme inconnu',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              edu['school'] ?? 'École inconnue',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: Text(
              "${edu['startYear'] ?? ''} – ${edu['endYear'] ?? 'Présent'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }
}
